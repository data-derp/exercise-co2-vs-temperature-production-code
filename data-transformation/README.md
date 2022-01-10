# Data Transformation
This repository creates an logic (in the `/src` directory) for an AWS Glue Job which transforms the ingested files that resulted from the AWS Glue Job in `../data-ingestion`. Don't forget your tests!

## Quickstart
1. Set up your [development environment](../development-environment.md)
2. Run tests in the`data-ingestion` dir (how?)` and fix the tests!
3. If you have set up the Github Runner, you can deploy: simply push the code, Github Actions will deploy using the workflow for your branch
4. Navigate to your bucket (`s3://<project-name>-<module-name>`) in the AWS Console to verify the `main.py` and `.egg` files exist