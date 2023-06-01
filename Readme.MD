# Jenkins Project README

## Project Overview

This Jenkins project is designed to automate the migration process for a source and a target DB. It utilizes Jenkins pipelines to define the stages and steps required for checkout, pre-build and build of this migration idea.

The project contains Jenkinsfile, shell script and replacement package for the pg-compare tool to implement the AWS Migration using AWS DMS as main Migration tool.

## Prerequisites

Before setting up the Jenkins project, ensure that you have the following prerequisites:

- Jenkins server installed and running.
- Access to the Jenkins server with appropriate administrative privileges.
- Access to the Github repository with appropriate administrative privileges. (Configure proper credentials)
- Access to the AWS Account with with appropriate privileges. (Configure proper credentials)
- Install the required plugins in your Jenkins instance:
  - CloudBees AWS Credentials Plugin
  - Pipeline: AWS Steps
  - Credentials Plugin
  - Git Plugin

## Configuration Steps

Follow the steps below to configure the Jenkins project:

1. **Clone the project**: Clone the project repository to your local machine or Jenkins server.

2. **Create Jenkins credentials**: Create the necessary credentials in Jenkins to access external systems such as source code repositories, Docker registries, or AWS services. To create credentials:

   - Navigate to Jenkins dashboard.
   - Click on "Credentials" in the left-hand menu.
   - Click on "Global credentials" or "System" depending on your Jenkins version.
   - Click on "Add Credentials" to create a new set of credentials.
   - Follow the prompts to specify the credential type, such as username/password, SSH key, or AWS access key.

3. **Configure project parameters**: The Jenkins project may have configurable parameters that allow you to customize the build and deployment process. These parameters were configured in the Jenkinsfile and should be defined the default value fo each one by code or in the Jenkins Console:

   1. **REPOSITORY_URL:** Description of parameter
   2. **AWS_CREDENTIALS_ID:** AWS Credentials ID configured on Jenkins
   3. **GITHUB_CREDENTIALS_ID:** GITHUB Credentials ID configured on Jenkins
   4. **SOURCE_SECRETS_ID:** Source DB Secret Name configured on AWS Secrets Manager service
   5. **TARGET_SECRETS_ID:** Target DB Secret Name configured on AWS Secrets Manager service
   6. **SOURCE_DB_ENGINE:** (List) mysql" , "oracle" , "postgres" , "mariadb" , "aurora" , "aurora-postgresql" ,"db2"
   7. **TARGET_DB_ENGINE:** (List) mysql" , "oracle" , "postgres" , "mariadb" , "aurora" , "aurora-postgresql" ,"db2"

4. **Update Jenkinsfile**: The Jenkinsfile defines the pipeline stages and steps for your project. Open the Jenkinsfile in your project repository and update it to reflect the specific stages, steps, and configuration for your application. Make sure to include references to the defined parameters and credentials.

5. **Configure Jenkins job**: In the Jenkins dashboard, create a new Jenkins job and configure it as follows:

   - Set the appropriate project name and description.
   - Specify the repository URL or reference the Jenkinsfile directly in the project's repository.
   - Configure any additional settings required for your project, such as build triggers, notifications, or post-build actions.
   - Save the job configuration.

6. **Build the project**: Trigger the Jenkins job to start the build process. Monitor the console output and logs to ensure the build and deployment stages are executed successfully.

## Usage

To use the Jenkins project:

1. Open the Jenkins dashboard and navigate to the project.
2. Provide the required parameters when starting a build.
3. Monitor the build progress and review the console output for any errors or warnings regarding to AWS DMS or the Secrets Manager service.
4. Access to the AWS DMS service and take a look of the Target DB where is pointed the Migration.

## Troubleshooting

If you encounter any issues during the setup or execution of the Jenkins project, refer to the following troubleshooting steps:

- Check the Jenkins server logs for any error messages or exceptions.
- Review the project configuration and ensure that all required parameters and credentials are properly set.
- Verify the Jenkinsfile to ensure it accurately reflects the desired build and deployment stages.
- Ensure that the Jenkins server has appropriate permissions and access to AWS services or Github Credentials.

## License
