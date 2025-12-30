#!/usr/bin/env bash
set -e

if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

API_URL="https://ahwr-application-backend.$ENVIRONMENT.cdp-int.defra.cloud"
DEVELOPER_API_KEY="${DEVELOPER_API_KEY:-}"

# to add more, keep adding &sbi=value
SBIS=""
SBIS="${SBIS}sbi=107671613&sbi=106591000&sbi=200716247&sbi=115078392&sbi=115086633"
SBIS="${SBIS}&sbi=106625328&sbi=106256479&sbi=107356780&sbi=106980820&sbi=106345911"
SBIS="${SBIS}&sbi=107314916&sbi=106501421&sbi=106438775&sbi=113212619&sbi=107190597"
SBIS="${SBIS}&sbi=106733136&sbi=106563437&sbi=106290530&sbi=106541316&sbi=113267012"
SBIS="${SBIS}&sbi=106318769&sbi=106561801&sbi=107682967&sbi=107076111&sbi=106877141"
SBIS="${SBIS}&sbi=106525577&sbi=113307704&sbi=113314656&sbi=107266781&sbi=113322075"
SBIS="${SBIS}&sbi=106801754&sbi=107262457&sbi=106835630&sbi=106829073&sbi=107064480"
SBIS="${SBIS}&sbi=107239721&sbi=106293418&sbi=106252000&sbi=107302477&sbi=106950389"

CURL_OPTS=(-s -w "%{http_code}")

# Add API key header only when running locally
if [ "$RUN_ENVIRONMENT" = "local" ]; then
    CURL_OPTS+=(-H "x-api-key: $DEVELOPER_API_KEY")
    API_URL="https://ephemeral-protected.api.$ENVIRONMENT.cdp-int.defra.cloud/ahwr-application-backend"
fi

# Run curl, append status code to body
response=$(curl "${CURL_OPTS[@]}" -X DELETE "${API_URL}/api/cleanup?${SBIS}")

# Extract last 3 digits as HTTP status
HTTP_STATUS="${response: -3}"   # last 3 characters

# Optionally trim whitespace/newlines
HTTP_BODY="$(echo -e "${HTTP_BODY}" | sed -e 's/^[[:space:]]*//;s/[[:space:]]*$//')"

if [ "$HTTP_STATUS" -ne 204 ]; then
    echo "Cleanup failed (HTTP $HTTP_STATUS)"
    exit 1
fi

echo "Cleanup completed successfully"
