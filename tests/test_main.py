"""
Unit tests for Cranky Container API.
These tests run automatically on every push via GitHub Actions.
"""

import pytest
from fastapi.testclient import TestClient
import sys
import os

# Add src to path so we can import main
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from main import app


@pytest.fixture
def client():
    """Create a test client for the FastAPI app."""
    return TestClient(app)


class TestHealth:
    """Health check endpoint tests."""

    def test_health_check(self, client):
        """Test that health check returns 200 OK."""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_health_contains_timestamp(self, client):
        """Test that health check includes a timestamp."""
        response = client.get("/health")
        assert "timestamp" in response.json()


class TestRoot:
    """Root endpoint tests."""

    def test_root_endpoint(self, client):
        """Test that root endpoint returns 200 OK."""
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()

    def test_root_has_welcome_message(self, client):
        """Test that root endpoint has welcome message."""
        response = client.get("/")
        assert "Cranky Container" in response.json()["message"]


class TestGreeting:
    """Greeting endpoint tests."""

    def test_greet_alice(self, client):
        """Test greeting endpoint with a name."""
        response = client.get("/greet/Alice")
        assert response.status_code == 200
        assert response.json()["greeting"] == "Hello, Alice!"

    def test_greet_returns_timestamp(self, client):
        """Test that greeting includes timestamp."""
        response = client.get("/greet/Bob")
        assert "timestamp" in response.json()

    def test_greet_with_special_characters(self, client):
        """Test greeting with special characters."""
        response = client.get("/greet/O%27Brien")
        assert response.status_code == 200
        assert "O'Brien" in response.json()["greeting"]


class TestEcho:
    """Echo endpoint tests."""

    def test_echo_message(self, client):
        """Test echo endpoint with valid message."""
        payload = {"text": "Hello, World!"}
        response = client.post("/echo", json=payload)
        assert response.status_code == 200
        assert response.json()["echo"] == "Hello, World!"

    def test_echo_empty_message(self, client):
        """Test echo endpoint with empty message."""
        payload = {"text": ""}
        response = client.post("/echo", json=payload)
        assert response.status_code == 200
        assert response.json()["echo"] == ""

    def test_echo_missing_field(self, client):
        """Test echo endpoint with missing required field."""
        response = client.post("/echo", json={})
        assert response.status_code == 422  # Validation error


class TestInfo:
    """Info endpoint tests."""

    def test_info_endpoint(self, client):
        """Test info endpoint returns required fields."""
        response = client.get("/info")
        assert response.status_code == 200
        data = response.json()
        assert "app_name" in data
        assert "version" in data
        assert "environment" in data


class TestMetrics:
    """Metrics endpoint tests."""

    def test_metrics_endpoint(self, client):
        """Test metrics endpoint returns DORA metrics."""
        response = client.get("/metrics")
        assert response.status_code == 200
        data = response.json()
        assert "deployment_frequency" in data
        assert "lead_time" in data
        assert "mttr" in data
        assert "failure_rate" in data


class TestErrorHandling:
    """Test error handling."""

    def test_nonexistent_endpoint(self, client):
        """Test that nonexistent endpoint returns 404."""
        response = client.get("/nonexistent")
        assert response.status_code == 404


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
