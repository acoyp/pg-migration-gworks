

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
                        env.SOURCE_SERVER_NAME = source_secretJson.POSTGRES_HOST
                        env.SOURCE_DATABASE_NAME = source_secretJson.POSTGRES_DATABASE
                        env.SOURCE_USERNAME = source_secretJson.POSTGRES_USER
                        env.SOURCE_PASSWORD = source_secretJson.POSTGRES__PASSWORD
                        env.TARGET_SERVER_NAME = target_secretJson.POSTGRES_HOST
                        env.TARGET_DATABASE_NAME = target_secretJson.POSTGRES_DATABASE
                        env.TARGET_USERNAME = target_secretJson.POSTGRES_USER
                        env.TARGET_PASSWORD = target_secretJson.POSTGRES__PASSWORD
                        
                        echo "The value of POSTGRES_HOST_DB1 is: ${SOURCE_SERVER_NAME}"
                        echo "The value of POSTGRES_HOST_DB2 is: ${TARGET_SERVER_NAME}"       
                    }
                }
            }
        }
        stage('Subnets Validation (TERRAFORM)') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${params.AWS_CREDENTIALS_ID}",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    script {
                        sh """
                            terraform -chdir=terraform init -backend-config="bucket=pg-compare-terraform" -backend-config="key=my-state-file.tfstate" -backend-config="region=us-east-1"
                            terraform -chdir=terraform apply --auto-approve
                        """      
                        env.TF_OUTPUT = sh(script: "terraform -chdir=terraform output -json", returnStdout: true)
                        env.SUBNET_ID_1 = sh(script: "echo \"${TF_OUTPUT}\" | jq -r '.subnet_a.value'", returnStdout: true)
                        env.SUBNET_ID_1 = sh(script: "echo \"${TF_OUTPUT}\" | jq -r '.subnet_b.value'", returnStdout: true)

                        echo "${SUBNET_ID_1} and ${SUBNET_ID_1}"
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
