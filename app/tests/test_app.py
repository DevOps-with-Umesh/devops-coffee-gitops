from app import app


def test_healthz():
    client = app.test_client()
    assert client.get("/healthz").status_code == 200


def test_home_page_shows_menu():
    client = app.test_client()
    page = client.get("/").get_data(as_text=True)
    assert "DevOps Coffee" in page
    assert "Espresso" in page


def test_unknown_item_is_rejected():
    client = app.test_client()
    assert client.post("/api/orders", json={"item": "pizza"}).status_code == 400


def test_metrics_endpoint_counts_requests():
    client = app.test_client()
    client.post("/api/orders", json={"item": "pizza"})
    text = client.get("/metrics").get_data(as_text=True)
    wanted = ('endpoint="/api/orders"', 'method="POST"', 'status="400"')
    assert any(l.startswith("http_requests_total{") and all(w in l for w in wanted)
               for l in text.splitlines())
    assert "coffee_orders_total" in text
