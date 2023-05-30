

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
                        def SOURCE_SERVER_NAME = source_secretJson.POSTGRES_HOST
                        def SOURCE_DATABASE_NAME = source_secretJson.POSTGRES_DATABASE
                        def SOURCE_USERNAME = source_secretJson.POSTGRES_USER
                        def SOURCE_PASSWORD = source_secretJson.POSTGRES__PASSWORD
                        def TARGET_SERVER_NAME = target_secretJson.POSTGRES_HOST
                        def TARGET_DATABASE_NAME = target_secretJson.POSTGRES_DATABASE
                        def TARGET_USERNAME = target_secretJson.POSTGRES_USER
                        def TARGET_PASSWORD = target_secretJson.POSTGRES__PASSWORD
                        
                        echo "The value of POSTGRES_HOST_DB1 is: ${SOURCE_SERVER_NAME}"
                        echo "The value of POSTGRES_HOST_DB2 is: ${TARGET_SERVER_NAME}"       
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
                        sh """
                            chmod 777 aws_dms_migration.sh
                            sh ./aws_dms_migration.sh
                            """    
                    }
                }
            }
        }
    }
}
