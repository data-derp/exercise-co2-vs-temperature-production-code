# Data Ingestion
This repository creates an logic (in the `/src` directory) for an AWS Glue Job

### Goal of Exercise
It is good practice to ingest data as-is (close to) as it can be expensive to ingest all of the data for every downstream transformation. It is also easier to debug.

Ingest input csv files and output them as parquet to specified locations:
- Make sure that Spark properly uses the csv header and separator 
- Make sure that column names are compatible with Apache Parquet

## Quickstart
1. Set up your [development environment](../development-environment.md)
2. Run tests in the`data-ingestion` dir (how?)` and fix the tests!
3. If you have set up the Github Runner, you can deploy: simply push the code, Github Actions will deploy using the workflow for your branch
4. Navigate to your bucket (`s3://<project-name>-<module-name>`) in the AWS Console to verify the `main.py` and `.egg` files exist
