FROM defradigital/cdp-perf-test-docker:latest

WORKDIR /opt/perftest

COPY scenarios/ ./scenarios/
COPY .groovylintrc.json .
COPY cleanup.sh .
COPY entrypoint.sh .
COPY user.properties .

ENV S3_ENDPOINT=https://s3.eu-west-2.amazonaws.com
ENV TEST_SCENARIO=ahwr-performance-tests

ENTRYPOINT [ "./entrypoint.sh" ]
