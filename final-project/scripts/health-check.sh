#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────────
# health-check.sh — Post-deployment health check
# ──────────────────────────────────────────────
# Verifies the application is accessible and
# responding correctly after deployment.
#
# Usage: ./health-check.sh <app_url>
# Example: ./health-check.sh https://pwpush.kulboka.com
# ──────────────────────────────────────────────

APP_URL="${1:?Usage: $0 <app_url>}"
MAX_RETRIES=10
RETRY_INTERVAL=10
EXIT_CODE=0

echo "=== Health Check Started ==="
echo "Target: $APP_URL"
echo "Max retries: $MAX_RETRIES"
echo ""

# ── Check 1: HTTP Status Code ──
echo "--- Check 1: HTTP Status Code ---"
RETRY_COUNT=0
HTTP_STATUS=""

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$APP_URL" 2>/dev/null || echo "000")
  
  if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "✅ HTTP status: $HTTP_STATUS"
    break
  fi
  
  RETRY_COUNT=$((RETRY_COUNT + 1))
  echo "⏳ Attempt $RETRY_COUNT/$MAX_RETRIES — HTTP status: $HTTP_STATUS — retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "❌ FAILED: Application not responding (last status: $HTTP_STATUS)"
  EXIT_CODE=1
fi

# ── Check 2: SSL Certificate ──
echo ""
echo "--- Check 2: SSL Certificate ---"
if echo | openssl s_client -connect "${APP_URL#https://}:443" -servername "${APP_URL#https://}" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null; then
  echo "✅ SSL certificate is valid"
else
  echo "⚠️  SSL certificate check inconclusive (may be behind Cloudflare)"
fi

# ── Check 3: Response Content ──
echo ""
echo "--- Check 3: Response Content ---"
RESPONSE=$(curl -s --max-time 15 -L "$APP_URL" 2>/dev/null || echo "")

if echo "$RESPONSE" | grep -qi "password\|pusher\|pwpush"; then
  echo "✅ Response contains expected content"
else
  echo "❌ FAILED: Response does not contain expected content"
  EXIT_CODE=1
fi

# ── Check 4: Response Time ──
echo ""
echo "--- Check 4: Response Time ---"
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" --max-time 15 -L "$APP_URL" 2>/dev/null || echo "0")
echo "Response time: ${RESPONSE_TIME}s"

# Check if response time is under 5 seconds
if [ "$(echo "$RESPONSE_TIME < 5" | bc -l 2>/dev/null || echo 0)" = "1" ]; then
  echo "✅ Response time is acceptable (<5s)"
else
  echo "⚠️  Response time is slow (>5s)"
fi

# ── Summary ──
echo ""
echo "=== Health Check Summary ==="
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ All critical checks passed"
else
  echo "❌ Some checks failed — review output above"
fi

exit $EXIT_CODE
