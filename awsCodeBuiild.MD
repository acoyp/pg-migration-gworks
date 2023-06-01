# Schema migration RDS - Postgres

To execute this migration it ought to follow the following steps as pre-requisites:

1. Create CodeBuild project

- Define the next **build project** properties
  - Source 1: Github --> Connect using OAuth or Github PAT
  - Environment: Managed image --> Ubuntu OS - Standard Runtime - aws/codebuild/standard:5.0
- Define ENV Vars
  - SECRET_ARN_1 = The ARN of the Secret that contains PG_DATABASE_1 parameters
  - SECRET_ARN_2 = The ARN of the Secret that contains PG_DATABASE_2 parameters
- Logs configuration (Optional)

2. Create Pipeline in AWS CodePipeline

- Define **Pipeline name**
- Select **New Service Role**
- In the source page define as **Source Provider** as **Github (Version 2)**
  - Create new Github Connection and follow the **pop-up configuration**
- In the Build Configuration define the codebuild project created before

3.
