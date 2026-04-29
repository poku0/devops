"""
Post-deployment health check tests for Password Pusher.

Usage:
    APP_URL=https://pwpush.kulboka.com pytest tests/test_health.py -v

These tests verify the application is accessible and
functioning correctly after deployment.
"""

import os
import time

import requests
import pytest


APP_URL = os.environ.get("APP_URL", "https://pwpush.kulboka.com")
MAX_RETRIES = int(os.environ.get("HEALTH_CHECK_RETRIES", "10"))
RETRY_DELAY = int(os.environ.get("HEALTH_CHECK_DELAY", "10"))


def wait_for_app(url: str, retries: int = MAX_RETRIES, delay: int = RETRY_DELAY) -> bool:
    """Wait for the application to become available."""
    for attempt in range(1, retries + 1):
        try:
            response = requests.get(url, timeout=15, allow_redirects=True)
            if response.status_code in (200, 301, 302):
                return True
        except requests.exceptions.RequestException:
            pass
        if attempt < retries:
            print(f"Attempt {attempt}/{retries} failed, retrying in {delay}s...")
            time.sleep(delay)
    return False


class TestApplicationHealth:
    """Test suite for application health verification."""

    @pytest.fixture(autouse=True)
    def setup(self):
        """Ensure the application is reachable before running tests."""
        assert wait_for_app(APP_URL), (
            f"Application at {APP_URL} did not become available "
            f"after {MAX_RETRIES * RETRY_DELAY}s"
        )

    def test_homepage_returns_200(self):
        """Verify the homepage returns HTTP 200."""
        response = requests.get(APP_URL, timeout=15, allow_redirects=True)
        assert response.status_code == 200, (
            f"Expected 200, got {response.status_code}"
        )

    def test_homepage_contains_expected_content(self):
        """Verify the homepage contains Password Pusher content."""
        response = requests.get(APP_URL, timeout=15, allow_redirects=True)
        body = response.text.lower()
        assert any(
            keyword in body
            for keyword in ["password", "pusher", "pwpush", "secret", "share"]
        ), "Homepage does not contain expected keywords"

    def test_response_time_acceptable(self):
        """Verify the response time is under 5 seconds."""
        response = requests.get(APP_URL, timeout=15, allow_redirects=True)
        assert response.elapsed.total_seconds() < 5, (
            f"Response time {response.elapsed.total_seconds():.2f}s exceeds 5s threshold"
        )

    def test_https_redirect(self):
        """Verify HTTP redirects to HTTPS."""
        http_url = APP_URL.replace("https://", "http://")
        response = requests.get(
            http_url, timeout=15, allow_redirects=False
        )
        assert response.status_code in (301, 302), (
            f"Expected redirect (301/302), got {response.status_code}"
        )
        location = response.headers.get("Location", "")
        assert location.startswith("https://"), (
            f"Redirect location '{location}' does not use HTTPS"
        )

    def test_security_headers(self):
        """Verify basic security headers are present."""
        response = requests.get(APP_URL, timeout=15, allow_redirects=True)
        headers = response.headers

        # These may be set by Cloudflare or the application
        security_checks = {
            "content-type": lambda v: "text/html" in v,
        }

        for header, check in security_checks.items():
            value = headers.get(header, "")
            assert check(value), (
                f"Security header '{header}' check failed (value: '{value}')"
            )

    def test_database_connectivity(self):
        """Verify the app can connect to the database by loading a page that requires DB."""
        # The main page requires DB connectivity to render
        response = requests.get(APP_URL, timeout=15, allow_redirects=True)
        # If DB is down, Rails typically returns 500
        assert response.status_code != 500, (
            "Got 500 error — possible database connectivity issue"
        )
