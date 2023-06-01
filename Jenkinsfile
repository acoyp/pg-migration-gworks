

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
                        env.SOURCE_PASSWORD = source_secretJson.POSTGRES__PASSWORD
                        env.TARGET_SERVER_NAME = target_secretJson.POSTGRES_HOST
                        env.TARGET_DATABASE_NAME = target_secretJson.POSTGRES_DATABASE
                        env.TARGET_USERNAME = target_secretJson.POSTGRES_USER
                        env.TARGET_PASSWORD = target_secretJson.POSTGRES__PASSWORD

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
                        def source_server_name = env.SOURCE_SERVER_NAME 
                        def source_database_name = env.SOURCE_DATABASE_NAME
                        def source_username = env.SOURCE_USERNAME
                        def source_password = env.SOURCE_PASSWORD 
                        def target_server_name = env.TARGET_SERVER_NAME
                        def target_database_name = env.TARGET_DATABASE_NAME
                        def target_username = env.TARGET_USERNAME
                        def target_password = env.TARGET_PASSWORD
                        sh '''
                            DB_DATA=\$(cat compareDBs.json)
                            echo ${source_password}
                            DB_DATA=\$(jq '.connection1.host = ${source_server_name}' <<< "$DB_DATA")
                            DB_DATA=\$(jq '.connection1.database = ${source_database_name}' <<< "$DB_DATA")
                            DB_DATA=\$(jq '.connection1.user = ${source_username}' <<< "$DB_DATA") 
                            DB_DATA=\$(jq '.connection1.password = ${source_password}' <<< "$DB_DATA") 
                            DB_DATA=\$(jq '.connection2.host = ${target_server_name}' <<< "$DB_DATA") 
                            DB_DATA=\$(jq '.connection2.database = ${target_database_name}' <<< "$DB_DATA") 
                            DB_DATA=\$(jq '.connection2.user = ${target_username}' <<< "$DB_DATA") 
                            DB_DATA=\$(jq '.connection2.password = ${target_password}' <<< "$DB_DATA" > compareDBs.json) 
                            cat compareDBs.json
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
