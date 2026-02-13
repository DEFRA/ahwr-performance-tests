/* groovylint-disable DuplicateStringLiteral, UnnecessaryGroovyImport, VariableTypeRequired */
import groovy.json.JsonOutput
import java.net.HttpURLConnection

/* groovylint-disable-next-line CompileStatic */
def env = System.getenv('ENVIRONMENT') ?: 'perf-test'
def runEnv = System.getenv('RUN_ENVIRONMENT') ?: 'perf-test'

log.info("status update env is : ${env}")
log.info("status update runEnv is : ${runEnv}")

// Use DEVELOPER_API_KEY only for local
def apiKeyHeader = ''
def apiUrl = "https://ahwr-application-backend.${env}.cdp-int.defra.cloud"

if (runEnv == 'local') {
    def devApiKey = System.getenv('DEVELOPER_API_KEY') ?: ''
    apiKeyHeader = devApiKey
    apiUrl = "https://ephemeral-protected.api.${env}.cdp-int.defra.cloud/ahwr-application-backend"
} else {
    def testsUiApiKey = System.getenv('TESTS_UI_API_KEY') ?: ''
    apiKeyHeader = testsUiApiKey
}

log.info("The status update apiUrl is : ${apiUrl}")

// Get claimReference from previous extractor
def reference = vars.get('claimReference') ?: props.get('claimReference')
log.info("The claim reference to update status for is : ${reference}")

if (!reference || reference == 'NOT_FOUND') {
    log.warn('claimReference is missing for this iteration, skipping status change request')
    return
}

// Prepare payload
def payload = [
    reference: reference,
    status: 'READY_TO_PAY',
    user: 'admin'
]

// Open HTTP connection
def url = new URL("${apiUrl}/api/claims/update-by-reference")
def connection = (HttpURLConnection) url.openConnection()
/* groovylint-disable-next-line UnnecessarySetter */
connection.setRequestMethod('PUT')
connection.setRequestProperty('Content-Type', 'application/json')

if (apiKeyHeader) {
    connection.setRequestProperty('x-api-key', apiKeyHeader)
}

/* groovylint-disable-next-line UnnecessarySetter */
connection.setDoOutput(true)

// Send JSON payload
def writer = new OutputStreamWriter(connection.outputStream)
writer.write(JsonOutput.toJson(payload))
writer.flush()
writer.close()

// Read response
def responseCode = connection.responseCode
def responseBody = (responseCode >= 400) ? connection.errorStream?.text : connection.inputStream.text

log.info("Updated claimReference: ${reference}, Response code: ${responseCode}")
log.info("Response body: ${responseBody}")
