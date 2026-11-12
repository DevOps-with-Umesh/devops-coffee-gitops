"""DevOps Coffee: a small coffee-ordering web app (Flask + Redis) for GitOps demos."""
import json
import os
import socket
import time

import redis
from flask import Flask, jsonify, render_template, request

app = Flask(__name__)

APP_VERSION = os.environ.get("APP_VERSION", "dev")
SHOP_NAME = os.environ.get("SHOP_NAME", "DevOps Coffee")
POD_NAME = socket.gethostname()

MENU = [
    {"id": "espresso", "emoji": "☕", "name": "Espresso", "price": 2.50},
    {"id": "cappuccino", "emoji": "🥛", "name": "Cappuccino", "price": 3.20},
    {"id": "matcha", "emoji": "🍵", "name": "Matcha Latte", "price": 3.80},
    {"id": "iced", "emoji": "🧊", "name": "Iced Americano", "price": 3.00},
    {"id": "croissant", "emoji": "🥐", "name": "Butter Croissant", "price": 2.20},
    {"id": "chocolate", "emoji": "🍫", "name": "Hot Chocolate", "price": 2.90},
]
MENU_BY_ID = {item["id"]: item for item in MENU}

db = redis.Redis(
    host=os.environ.get("REDIS_HOST", "redis"),
    port=int(os.environ.get("REDIS_PORT", "6379")),
    decode_responses=True,
    socket_timeout=2,
    socket_connect_timeout=2,
)


@app.get("/")
def index():
    return render_template("index.html", menu=MENU, version=APP_VERSION,
                           shop=SHOP_NAME, pod=POD_NAME)


@app.post("/api/orders")
def place_order():
    item = MENU_BY_ID.get((request.get_json(silent=True) or {}).get("item", ""))
    if item is None:
        return jsonify(error="unknown menu item"), 400
    order = {"id": db.incr("orders:count"), "item": item["name"], "emoji": item["emoji"],
             "price": item["price"], "pod": POD_NAME, "time": time.strftime("%H:%M:%S")}
    db.lpush("orders:recent", json.dumps(order))
    db.ltrim("orders:recent", 0, 9)
    db.incrbyfloat("orders:revenue", item["price"])
    return jsonify(order), 201


@app.get("/api/orders")
def list_orders():
    recent = [json.loads(o) for o in db.lrange("orders:recent", 0, 9)]
    return jsonify(total=int(db.get("orders:count") or 0),
                   revenue=round(float(db.get("orders:revenue") or 0), 2),
                   recent=recent, served_by=POD_NAME, version=APP_VERSION)


@app.get("/healthz")
def healthz():
    """Liveness: the web process is up."""
    return "ok", 200


@app.get("/readyz")
def readyz():
    """Readiness: only receive traffic when Redis answers."""
    try:
        db.ping()
        return "ready", 200
    except redis.RedisError:
        return "redis unavailable", 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
