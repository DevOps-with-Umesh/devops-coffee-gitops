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
