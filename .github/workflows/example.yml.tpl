name: 'Build, Test, Deploy'

env:
  PROJECT_NAME: example-project
  MODULE_NAME: example1-example2
  PROJECT_AWS_REGION: project-aws-region

on:
  push:
    branches:
      - master

jobs:
  base:
    name: 'Create S3 Bucket'
    runs-on: self-hosted
    environment: production
    container:
      image: ghcr.io/kelseymok/terraform-workspace:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Assume Role
        run: assume-role ${PROJECT_NAME}-${MODULE_NAME}-github-runner-aws

      - name: Create S3 Bucket
        run: |
          curl -o template.yaml https://raw.githubusercontent.com/data-derp/bootstrap-github-runner-cloudformation/master/s3-bucket/template.yaml
          aws cloudformation create-stack --stack-name "${PROJECT_NAME}-${MODULE_NAME}-co2-tmp-s3-bucket" \
              --template-body file://./template.yaml \
              --capabilities CAPABILITY_NAMED_IAM \
              --region ${PROJECT_AWS_REGION} \
              --parameters ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} ParameterKey=ModuleName,ParameterValue=${MODULE_NAME}

  data-ingestion-test:
    name: 'Test Data Ingestion'
    runs-on: self-hosted
    environment: production
    container:
      image: ghcr.io/kelseymok/pyspark-testing-env:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Test Data Ingestion
        env:
          SUBDIR: data-ingestion
        uses: ./.github/composite-actions/pytest

  data-ingestion:
    name: 'Data Ingestion'
    runs-on: self-hosted
    environment: production
    env:
      SUBDIR: data-ingestion
    needs: ["base", "data-ingestion-test"]
    container:
      image: ghcr.io/kelseymok/terraform-workspace:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Assume Role
        run: assume-role ${PROJECT_NAME}-${MODULE_NAME}-github-runner-aws

      - name: Upload Main.py
        run: |
          cd ${SUBDIR}/src
          aws s3 cp main.py s3://${PROJECT_NAME}-${MODULE_NAME}/${SUBDIR}/main.py

      - name: Upload Data Ingestion lib
        run: |
          cd ${SUBDIR}
          python setup.py bdist_egg
          filename=$(ls dist)
          aws s3 cp dist/${filename} s3://${PROJECT_NAME}-${MODULE_NAME}/${SUBDIR}/data_ingestion-0.1-py3.egg

  data-transformation-test:
    name: 'Test Data Transformation'
    runs-on: self-hosted
    environment: production
    container:
      image: ghcr.io/kelseymok/pyspark-testing-env:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Test Data Transformation
        env:
          SUBDIR: data-transformation
        uses: ./.github/composite-actions/pytest

  data-transformation:
    name: 'Data Transformation'
    runs-on: self-hosted
    environment: production
    env:
      SUBDIR: data-transformation
    needs: ["base", "data-transformation-test"]
    container:
      image: ghcr.io/kelseymok/terraform-workspace:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Assume Role
        run: assume-role ${PROJECT_NAME}-${MODULE_NAME}-github-runner-aws

      - name: Upload Main.py
        run: |
          cd ${SUBDIR}/src
          if ! aws s3 ls "s3://${PROJECT_NAME}-${MODULE_NAME}" 2>&1 | grep -q 'NoSuchBucket'; then
            echo "Uploading s3://${PROJECT_NAME}-${MODULE_NAME}/${SUBDIR}/main.py"
            aws s3 cp main.py s3://${PROJECT_NAME}-${MODULE_NAME}/${SUBDIR}/main.py
          else
            aws s3api create-bucket --bucket s3://${PROJECT_NAME}-${MODULE_NAME} --acl private
          fi

      - name: Upload Data Transformation lib
        run: |
          cd ${SUBDIR}
          python setup.py bdist_egg
          filename=$(ls dist)
          aws s3 cp dist/${filename} s3://${PROJECT_NAME}-${MODULE_NAME}/${SUBDIR}/data_transformation-0.1-py3.egg