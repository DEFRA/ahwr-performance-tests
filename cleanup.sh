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
LIVESTOCK_SBIs=$(sed '1d; s/^/sbi=/' scenarios/livestock-test-data.csv | paste -sd '&' -)
POULTRY_SBIs=$(sed '1d; s/^/sbi=/' scenarios/poultry-test-data.csv | paste -sd '&' -)

CURL_OPTS=(-s -w "%{http_code}")

# Add API key header only when running locally
if [ "$RUN_ENVIRONMENT" = "local" ]; then
    CURL_OPTS+=(-H "x-api-key: $DEVELOPER_API_KEY")
    API_URL="https://ephemeral-protected.api.$ENVIRONMENT.cdp-int.defra.cloud/ahwr-application-backend"
else
    CURL_OPTS+=(-H "x-api-key: $TESTS_UI_API_KEY")
fi

echo "API_URL in cleanup file $API_URL"

# Livestock SBIs cleanup
response=$(curl "${CURL_OPTS[@]}" -X DELETE "${API_URL}/api/cleanup?${LIVESTOCK_SBIs}")
HTTP_STATUS="${response: -3}"
if [ "$HTTP_STATUS" -ne 204 ]; then
    echo "Livestock SBIs cleanup failed (HTTP $HTTP_STATUS)"
    exit 1
fi
echo "Livestock SBIs cleanup completed successfully"

# Poultry SBIs cleanup
response=$(curl "${CURL_OPTS[@]}" -X DELETE "${API_URL}/api/cleanup?${POULTRY_SBIs}")
HTTP_STATUS="${response: -3}"
if [ "$HTTP_STATUS" -ne 204 ]; then
    echo "Poultry SBIs cleanup failed (HTTP $HTTP_STATUS)"
    exit 1
fi
echo "Poultry SBIs cleanup completed successfully"