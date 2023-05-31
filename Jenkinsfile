

pipeline {
    agent any
    parameters {
        string(name: 'REPOSITORY_NAME', defaultValue: 'java-spring-demo-tb', description: '')
        string(name: 'AWS_CREDENTIALS_ID', defaultValue: 'aws-fercho', description: 'aws credentials for CLI')
        string(name: 'SOURCE_SECRETS_ID', defaultValue: 'mydb0-credentials2', description: 'aws secrets for Source DB')
        string(name: 'TARGET_SECRETS_ID', defaultValue: 'mydb1-credentials2', description: 'aws secrets for Target DB')
    }
    environment{
        AWS_REGION = 'us-east-1'
        PROJECT_NAME = 'gworksdbmigration'
        INSTANCE_IDENTIFIER = "replication-instance-gworks"
        INSTANCE_CLASS = "dms.t3.micro"
        STORAGE_SIZE = "50"
    }
    stages {
        stage('checkout') {
            steps {
                git branch: 'dev', credentialsId: 'github-tb-org', url: 'https://github.com/acoyp/pg-migration-gworks.git'
                sh 'ls'
                sh 'java -version'
            }
        }
        stage('Pre Build') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${params.AWS_CREDENTIALS_ID}",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    script {
                        def source_secretValue = sh(script: "aws secretsmanager get-secret-value --secret-id ${params.SOURCE_SECRETS_ID} --query 'SecretString' --output text", returnStdout: true).trim()
                        def target_secretValue = sh(script: "aws secretsmanager get-secret-value --secret-id ${params.TARGET_SECRETS_ID} --query 'SecretString' --output text", returnStdout: true).trim()
                        
                        // Parse the secret value as JSON
                        def source_secretJson = readJSON text: source_secretValue
                        def target_secretJson = readJSON text: target_secretValue
                        
                        // Get the specific key from the secret
                        env.SOURCE_SERVER_NAME = source_secretJson.POSTGRES_HOST
                        env.SOURCE_DATABASE_NAME = source_secretJson.POSTGRES_DATABASE
                        env.SOURCE_USERNAME = source_secretJson.POSTGRES_USER
                        env.SOURCE_PASSWORD = source_secretJson.POSTGRES__PASSWORD
                        env.TARGET_SERVER_NAME = target_secretJson.POSTGRES_HOST
                        env.TARGET_DATABASE_NAME = target_secretJson.POSTGRES_DATABASE
                        env.TARGET_USERNAME = target_secretJson.POSTGRES_USER
                        env.TARGET_PASSWORD = target_secretJson.POSTGRES__PASSWORD

                        env.SOURCE_ENDPOINT_IDENTIFIER = "${PROJECT_NAME}SourceEndpoint"
                        env.SOURCE_ENGINE_NAME = "postgres"


                        env.TARGET_ENDPOINT_IDENTIFIER = "${PROJECT_NAME}TargetEndpoint"
                        env.TARGET_ENGINE_NAME = "postgres"
                        
                        echo "The value of POSTGRES_HOST_DB1 is: ${TARGET_ENDPOINT_IDENTIFIER}"
                        echo "The value of POSTGRES_HOST_DB2 is: ${SOURCE_ENDPOINT_IDENTIFIER}"       
                    }
                }
            }
        }
        stage('Endpoint Validation') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${params.AWS_CREDENTIALS_ID}",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    script {
                        env.SOURCE_VALIDATION = sh(script: """"
                            aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='${SOURCE_ENDPOINT_IDENTIFIER}'].EndpointIdentifier" --output text
                            """, returnStdout: true).trim()
                        env.TARGET_VALIDATION = sh(script: """"
                            aws dms describe-endpoints --query "Endpoints[?EndpointIdentifier=='${TARGET_ENDPOINT_IDENTIFIER}'].EndpointIdentifier" --output text
                            """, returnStdout: true).trim()
                        if (env.SOURCE_VALIDATION != null){
                            echo "AWS DMS Endpoint already exists..."
                        }
                        else{
                            echo "AWS DMS doesn't exists..."
                            sh """"
                                aws dms create-endpoint \
                                    --endpoint-identifier "${SOURCE_ENDPOINT_IDENTIFIER}" \
                                    --endpoint-type "source" \
                                    --engine-name "${SOURCE_ENGINE_NAME}" \
                                    --server-name "${SOURCE_SERVER_NAME}" \
                                    --port "5432" \
                                    --database-name "${SOURCE_DATABASE_NAME}" \
                                    --username "${SOURCE_USERNAME}" \
                                    --password "${SOURCE_PASSWORD}"
                                fi
                            """
                        if (env.TARGET_VALIDATION != null){
                            echo "AWS DMS Endpoint already exists..."
                        }
                        else{
                            echo "AWS DMS doesn't exists..."
                            sh """"
                                aws dms create-endpoint \
                                    --endpoint-identifier "${TARGET_ENDPOINT_IDENTIFIER}" \
                                    --endpoint-type "TARGET" \
                                    --engine-name "${TARGET_ENGINE_NAME}" \
                                    --server-name "${TARGET_SERVER_NAME}" \
                                    --port "5432" \
                                    --database-name "${TARGET_DATABASE_NAME}" \
                                    --username "${TARGET_USERNAME}" \
                                    --password "${TARGET_PASSWORD}"
                                fi
                            """
                          
                    }
                }
            }
        }
    }
}
