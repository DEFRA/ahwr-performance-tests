#!/usr/bin/env bash
set -e

if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

echo "ENVIRONMENT in cleanup file $ENVIRONMENT"

API_URL="https://ahwr-application-backend.$ENVIRONMENT.cdp-int.defra.cloud"
DEVELOPER_API_KEY="${DEVELOPER_API_KEY:-}"
TESTS_UI_API_KEY="${TESTS_UI_API_KEY:-}"

#  retrieve SBIs from scenarios/test-data.csv
SBIS=$(sed '1d; s/^/sbi=/' scenarios/test-data.csv | paste -sd '&' -)

CURL_OPTS=(-s -w "%{http_code}")

# Add API key header only when running locally
if [ "$RUN_ENVIRONMENT" = "local" ]; then
    CURL_OPTS+=(-H "x-api-key: $DEVELOPER_API_KEY")
    API_URL="https://ephemeral-protected.api.$ENVIRONMENT.cdp-int.defra.cloud/ahwr-application-backend"
else
    CURL_OPTS+=(-H "x-api-key: $TESTS_UI_API_KEY")
fi

echo "API_URL in cleanup file $API_URL"

# Run curl, append status code to body
response=$(curl "${CURL_OPTS[@]}" -X DELETE "${API_URL}/api/cleanup?${SBIS}")

# Extract last 3 digits as HTTP status
HTTP_STATUS="${response: -3}"   # last 3 characters

if [ "$HTTP_STATUS" -ne 204 ]; then
    echo "Cleanup failed (HTTP $HTTP_STATUS)"
    exit 1
fi

echo "Cleanup completed successfully"
