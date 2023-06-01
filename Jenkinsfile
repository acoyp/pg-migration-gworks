

pipeline {
    agent any
    parameters {
        string(name: 'REPOSITORY_URL', defaultValue: 'https://github.com/acoyp/pg-migration-gworks.git', description: 'repository url that contains this project')
        string(name: 'AWS_CREDENTIALS_ID', defaultValue: 'aws-fercho', description: 'aws credentials for CLI')
        string(name: 'SOURCE_SECRETS_ID', defaultValue: 'mydb0-credentials2', description: 'aws secrets name for Source DB')
        string(name: 'TARGET_SECRETS_ID', defaultValue: 'mydb1-credentials2', description: 'aws secrets name for Target DB')
        choice(name: 'SOURCE_DB_ENGINE', choices: ['postgres' , 'mysql' , 'oracle' , 'mariadb' , 'aurora' , 'aurora-postgresql' ,'db2'], description: '')
        choice(name: 'TARGET_DB_ENGINE', choices: ['postgres' , 'mysql' , 'oracle' , 'mariadb' , 'aurora' , 'aurora-postgresql' ,'db2'], description: '')
    }
    environment{
        AWS_REGION = 'us-east-1'
        PROJECT_NAME = 'gworksdbmigration'
        INSTANCE_IDENTIFIER = "replication-instance-gworks"
        INSTANCE_CLASS = "dms.t3.micro"
        STORAGE_SIZE = "50"
        SOURCE_ENGINE_NAME = "${params.SOURCE_DB_ENGINE}"
        TARGET_ENGINE_NAME = "${params.TARGET_DB_ENGINE}"

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
                        env.SOURCE_PASSWORD = source_secretJson.POSTGRES_PASSWORD
                        env.TARGET_SERVER_NAME = target_secretJson.POSTGRES_HOST
                        env.TARGET_DATABASE_NAME = target_secretJson.POSTGRES_DATABASE
                        env.TARGET_USERNAME = target_secretJson.POSTGRES_USER
                        env.TARGET_PASSWORD = target_secretJson.POSTGRES_PASSWORD

                        env.SOURCE_ENDPOINT_IDENTIFIER = "${env.PROJECT_NAME}source01endpoint"



                        env.TARGET_ENDPOINT_IDENTIFIER = "${env.PROJECT_NAME}target01endpoint"

                        
                        echo "The value of POSTGRES_HOST_DB1 is: ${TARGET_ENDPOINT_IDENTIFIER}"
                        echo "The value of POSTGRES_HOST_DB2 is: ${SOURCE_ENDPOINT_IDENTIFIER}"       
                    }
                }
            }
        }
        stage('PG Compare validation') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${params.AWS_CREDENTIALS_ID}",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    script {
                        sh 'npm install -g pg-compare'
                        echo 'Modifying pg-compare Schema... '
                        sh 'sudo cp -r pg-compare/Schema.js /usr/local/lib/node_modules/pg-compare/lib'
                        sh 'cat ./compareDBs.json'
                        def JSON = sh(
                            script: 'cat ./compareDBs.json',
                            returnStdout: true
                        ).trim()
                        def MODIFIED_JSON = sh(
                            script: """
                                echo '${JSON}' |
                                jq --arg source_host "${env.SOURCE_SERVER_NAME}" '.connection1.host = \$source_host' |
                                jq --arg source_db "${env.SOURCE_DATABASE_NAME}" '.connection1.database = \$source_db' |
                                jq --arg source_user "${env.SOURCE_USERNAME}" '.connection1.user = \$source_user' |
                                jq --arg source_pw "${env.SOURCE_PASSWORD}" '.connection1.password = \$source_pw' |
                                jq --arg target_host "${env.TARGET_SERVER_NAME}" '.connection2.host = \$target_host' |
                                jq --arg target_db "${env.TARGET_DATABASE_NAME}" '.connection2.database = \$target_db' |
                                jq --arg target_user "${env.TARGET_USERNAME}" '.connection2.user = \$target_user' |
                                jq --arg target_pw "${env.TARGET_PASSWORD}" '.connection2.password = \$target_pw' |
                                jq
                                """,
                            returnStdout: true
                        ).trim()
                        writeFile file: './compareDBs.json', text: MODIFIED_JSON
                        sh 'pg-compare ./compareDBs.json'

                        sh '''
                            echo PG COMPARE RESULTS:...
                            cat ./delta.sql
                        '''
                    }
                    }
            }
        }
        stage('Build') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${params.AWS_CREDENTIALS_ID}",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    script {
                        echo "AWD DMS Migration..."  
                        sh """
                           # sh aws_dms_migration.sh
                        """    
                    }
                }
            }
        }
    }
}
