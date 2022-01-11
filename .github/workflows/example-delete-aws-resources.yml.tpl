name: 'Delete AWS Resources'

env:
  PROJECT_NAME: example-project
  MODULE_NAME: example1-example2
  PROJECT_AWS_REGION: project-aws-region

on: [workflow_dispatch]

jobs:
  base:
    name: 'Delete S3 Bucket'
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
        with:
          submodules: recursive

      - name: Assume Role
        run: assume-role ${PROJECT_NAME}-${MODULE_NAME}-github-runner-aws

      - name: Delete S3 Bucket
        run: |
          if [ -d "s3-bucket-aws-cloudformation" ]; then
              ./s3-bucket-aws-cloudformation/delete-stack -p "${PROJECT_NAME}" -m "${MODULE_NAME}" -r "${PROJECT_AWS_REGION}"
          fi