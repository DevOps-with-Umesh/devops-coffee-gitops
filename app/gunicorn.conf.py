"""Gunicorn settings. Each worker is its own process, so Prometheus metrics are written to a shared
folder (PROMETHEUS_MULTIPROC_DIR) and merged at /metrics."""
import os
import shutil

from prometheus_client import multiprocess

bind = "0.0.0.0:8080"
workers = 2
accesslog = "-"


def on_starting(server):
    folder = os.environ.get("PROMETHEUS_MULTIPROC_DIR")
    if folder:
        shutil.rmtree(folder, ignore_errors=True)  # start clean on every container start
        os.makedirs(folder, exist_ok=True)


def child_exit(server, worker):
    multiprocess.mark_process_dead(worker.pid)
