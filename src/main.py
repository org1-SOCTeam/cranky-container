"""
Cranky Container — Simple REST API Demo
A minimal FastAPI application to demonstrate CI/CD workflow.
"""

from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import os

app = FastAPI(title="Cranky Container API", version="1.0.0")


# Health check endpoint
@app.get("/health")
def health_check():
    """
    Health check endpoint for load balancers and monitoring.
    Used to verify the app is running.
    """
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0.0"
    }


# Root endpoint
@app.get("/")
def read_root():
    """Root endpoint that returns basic info."""
    return {
        "message": "Welcome to Cranky Container",
        "api": "ready",
        "docs": "/docs"  # Link to auto-generated API docs
    }


# Simple greeting endpoint
@app.get("/greet/{name}")
def greet(name: str):
    """
    Simple endpoint that greets a user.
    Example: GET /greet/Alice → {"greeting": "Hello, Alice!"}
    """
    return {
        "greeting": f"Hello, {name}!",
        "timestamp": datetime.utcnow().isoformat()
    }


# Echo endpoint (POST)
class Message(BaseModel):
    text: str


@app.post("/echo")
def echo_message(message: Message):
    """
    Echo back a message sent via POST.
    Useful for testing request bodies.
    """
    return {
        "echo": message.text,
        "received_at": datetime.utcnow().isoformat()
    }


# Info endpoint
@app.get("/info")
def get_info():
    """Get info about the deployment environment."""
    return {
        "app_name": "Cranky Container",
        "version": "1.0.0",
        "environment": os.getenv("ENVIRONMENT", "local"),
        "deployment_time": os.getenv("DEPLOYMENT_TIME", "unknown"),
        "hostname": os.getenv("HOSTNAME", "localhost")
    }


# Metrics endpoint (simplified DORA metrics)
@app.get("/metrics")
def get_metrics():
    """
    Simple metrics endpoint showing deployment info.
    In production, this would show real DORA metrics.
    """
    return {
        "deployment_frequency": "5 times per week",
        "lead_time": "28 minutes average",
        "mttr": "20 minutes average",
        "failure_rate": "5%",
        "message": "See docs/DORA_METRICS_GUIDE.md for details"
    }


if __name__ == "__main__":
    import uvicorn
    # Run on 0.0.0.0:8000 (accessible from all interfaces)
    uvicorn.run(app, host="0.0.0.0", port=8000)
