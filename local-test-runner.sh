#!/bin/sh
set -eux

if [ -f .env ]; then
    set -a
    . ./.env
    set +a
fi

# Cleanup of SBIs from previous runs
if [ -x "./cleanup.sh" ]; then
    ./cleanup.sh
fi

LOCAL_REPORTS_DIR="reports"
LOCAL_RESULTS_FILE="results/results.jtl"

# Clean up any existing reports and results folders before running tests
if [ -d "$LOCAL_REPORTS_DIR" ]; then
    echo "Cleaning existing reports directory..."
    rm -rf report.csv reports/* results/*
    echo "Existing reports and results folders removed successfully"
fi

# Test scenario
TEST_SCENARIO=${TEST_SCENARIO:-test}
SCENARIO_FILE="scenarios/$TEST_SCENARIO.jmx"
RESULT_JTL="results/results.jtl"
USER_PROPERTIES="user.properties"

# Target service
ENVIRONMENT=${ENVIRONMENT:-perf-test}
SERVICE_ENDPOINT=${SERVICE_ENDPOINT:-ahwr-public-user-ui.${ENVIRONMENT}.cdp-int.defra.cloud}
SERVICE_PORT=${SERVICE_PORT:-443}
SERVICE_URL_SCHEME=${SERVICE_URL_SCHEME:-https}

# Run JMeter
echo "Running in LOCAL mode"

rm -rf reports/* results/*

jmeter -n \
-t "$SCENARIO_FILE" \
-p "$USER_PROPERTIES" \
-l "$LOCAL_RESULTS_FILE" \
-e -o "$LOCAL_REPORTS_DIR" \
-Jenv="$ENVIRONMENT" \
-Jdomain="$SERVICE_ENDPOINT" \
-Jport="$SERVICE_PORT" \
-Jprotocol="$SERVICE_URL_SCHEME"

echo "JMeter run completed successfully"
exit 0
