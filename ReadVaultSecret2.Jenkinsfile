pipeline {
    agent any

    environment {
        VAULT_ADDR = 'https://your-vault-server:8200'
        VAULT_SECRET_PATH = 'secret/data/myapp'
        VAULT_TOKEN = credentials('vault-token')
    }

    stages {
        stage('Read Secrets from Vault') {
            steps {
                script {
                    def vaultResponse = bat(script: """
                        curl --silent --header "X-Vault-Token: ${VAULT_TOKEN}" \\
                            ${VAULT_ADDR}/v1/${VAULT_SECRET_PATH}
                    """, returnStdout: true).trim()
                    
                    // Extract the JSON portion of the response using Groovy's JsonSlurper
                    def jsonSlurper = new groovy.json.JsonSlurper()
                    def secretsJson = jsonSlurper.parseText(vaultResponse)

                    // Access secrets from the parsed JSON
                    def mySecret = secretsJson.data.data['my-secret']
                    echo "My secret: ${mySecret}"
                }
            }
        }
    }
}
