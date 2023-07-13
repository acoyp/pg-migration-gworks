# Schema migration RDS - Postgres

To execute this migration it ought to follow the following steps to create and configure the **AWS CodeBuild Service**

## AWS CodeBuild Configuration

### Step 1: Set Up Your Environment

1. Open the AWS Management Console and navigate to the AWS CodeBuild service.
2. Click on "Create build project" to start creating your CodeBuild project.

### Step 2: Configure Your Build Project

1. **Project Configuration**

   - Provide a meaningful name for your build project.
   - Optionally, add a description to provide more details.
   - Choose the source provider where your application's source code is hosted (e.g., CodeCommit, GitHub, Bitbucket, etc.).
     > Connect using OAuth or Github PAT
   - Connect your source provider and select the repository and branch/tag to build.

2. **Environment Configuration**

   - Select the runtime environment for your build.
     > Ubuntu OS - Standard Runtime - aws/codebuild/standard:5.0
   - Choose the desired compute type and image for your build environment.
   - Define ENV Vars
     This credentials must be stored as is shown
     - SOURCE_DB_SECRETS = The ARN of the Secrets that contains SOURCE_PG_DATABASE credentials
     - TARGET_DB_SECRETS = The ARN of the Secrets that contains TARGET_PG_DATABASE credentials
   - Logs configuration (Optional)

3. **Buildspec Configuration**

   - The `buildspec.yml` file is in the repo, 'll be automatically consumed by the service

4. **Artifacts Configuration** (OPTIONAL)

   - Specify how CodeBuild should package and provide the build output artifacts.
   - Choose the desired artifact type, such as S3, CodeDeploy, or No artifacts.
   - Configure the necessary settings based on the chosen artifact type.

5. **Logs Configuration**

   - Choose the desired CloudWatch Logs settings for your build logs.
   - Configure log group and stream settings to capture build logs.

6. **Additional Configurations**
   - Review and configure any other advanced settings or optional features as per your project requirements.

### Step 3: Start Your Build

1. Review the project configuration and ensure all settings are correct.
2. Click on "Create build project" to create your AWS CodeBuild project.

### Step 4: Monitor Your Build

1. After starting a build, you can monitor its progress from the CodeBuild console.
2. Once the build completes, you can view the build logs and any associated artifacts.

## PG Compare Logic

For this procedure the pg compare will work as is shown in the next flow diagram:

[!Alt Text](assets/pg_compare_flow.png "PG Compare Flow")

An the entire Build Project logic will work as is shown in the next illustration:

[!Alt Text](assets/codebuild_flow.png "CodeBuild Diagram")
