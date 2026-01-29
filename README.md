# ahwr-performance-tests

This repository contains the performance test suite for AHWR public ui service. 
Tests are executed using a JMeter-based runner within the CDP Platform.

- [Licence](#licence)
- [About the licence](#about-the-licence)

## Build

Test suites are built automatically by the [.github/workflows/publish.yml](.github/workflows/publish.yml) action whenever a change are committed to the `main` branch.
A successful build results in a Docker container that is capable of running your tests on the CDP Platform and publishing the results to the CDP Portal.

## Run

The performance test suites are designed to be run from the CDP Portal.
The CDP Platform runs test suites in much the same way it runs any other service, it takes a docker image and runs it as an ECS task, automatically provisioning infrastructure as required.

**Environment variables and their values set in CDP portal for a standard run:**
```bash
THREAD_COUNT=40
RAMPUP_SECONDS=10
DURATION_SECONDS=240
USER_PAGE_DELAY=3500
LOOP_COUNT=1
CSV_RECYCLE_ON_EOF=false
CSV_STOP_ON_EOF=true
```
These values can be adjusted to support different load profiles, including load and soak testing scenarios.

## Local test execution for an environment
Install Jmeter on the local machine if you need to open and edit the jmx file from this repo in Jmeter UI.

Make sure the following environments values are set in the .env file:

- ENVIRONMENT=perf-test
- RUN_ENVIRONMENT=local
- DEVELOPER_API_KEY = API key value for the logged-in user from CDP portal
- TEST_SCENARIO=ahwr-performance-tests (This is the jmx file name present in scenarios folder)
- THREAD_COUNT=1
- RAMPUP_SECONDS=1
- DURATION_SECONDS=30
- USER_PAGE_DELAY=500
- LOOP_COUNT=1
- CSV_RECYCLE_ON_EOF=false
- CSV_STOP_ON_EOF=true

Now run the command in a terminal from the project directory

```bash
sh ./local-test-runner.sh
```

The test runs locally for 30 seconds with a single user, based on the configuration above. High-load testing is not recommended in a local environment; local execution should be used only for scripting and debugging purposes. Once the test finishes, an HTML report is generated in the reports folder.

# The sections below are not relevant to AHWR performance tests and come from the template repository.

## Local Testing with Docker Compose - Not applicable for ahwr-performance tests

You can run the entire performance test stack locally using Docker Compose, including LocalStack, Redis, and the target service. This is useful for development, integration testing, or verifying your test scripts **before committing to `main`**, which will trigger GitHub Actions to build and publish the Docker image.

### Build the Docker image

```bash
docker compose build --no-cache development
```

This ensures any changes to `entrypoint.sh` or other scripts are picked up properly.

---

### Start the full test stack

```bash
docker compose up --build
```

This brings up:

* `development`: the container that runs your performance tests
* `localstack`: simulates AWS S3, SNS, SQS, etc.
* `redis`: backing service for cache
* `service`: the application under test

Once all services are healthy, your performance tests will automatically start.

---

### Replace `service-name` in Compose File

In the `docker-compose.yml`, make sure to replace:

```yaml
image: defradigital/service-name:${SERVICE_VERSION:-latest}
```

with the actual name of your service’s image.

This is the service under test, which must expose a `/health` endpoint and listen on port `3000`.

---

### Notes

* S3 bucket is expected to be `s3://test-results`, automatically created inside LocalStack.
* Logs and reports are written to `./reports` on your host.
* `entrypoint.sh` should contain the logic to wait for dependencies and kick off the test run.
* The `depends_on` healthchecks ensure services like `localstack` and `service` are ready before tests start.
* If you make changes to test scripts or entrypoints, rerun with:

```bash
docker compose up --build
```

## Local Testing with LocalStack - Not applicable for ahwr-performance tests

### Build a new Docker image
```
docker build . -t my-performance-tests
```
### Create a Localstack bucket
```
aws --endpoint-url=localhost:4566 s3 mb s3://my-bucket
```

### Run performance tests

```
docker run \
-e S3_ENDPOINT='http://host.docker.internal:4566' \
-e RESULTS_OUTPUT_S3_PATH='s3://my-bucket' \
-e AWS_ACCESS_KEY_ID='test' \
-e AWS_SECRET_ACCESS_KEY='test' \
-e AWS_SECRET_KEY='test' \
-e AWS_REGION='eu-west-2' \
my-performance-tests
```

docker run -e S3_ENDPOINT='http://host.docker.internal:4566' -e RESULTS_OUTPUT_S3_PATH='s3://cdp-infra-dev-test-results/cdp-portal-perf-tests/95a01432-8f47-40d2-8233-76514da2236a' -e AWS_ACCESS_KEY_ID='test' -e AWS_SECRET_ACCESS_KEY='test' -e AWS_SECRET_KEY='test' -e AWS_REGION='eu-west-2' -e ENVIRONMENT='perf-test' my-performance-tests


## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
