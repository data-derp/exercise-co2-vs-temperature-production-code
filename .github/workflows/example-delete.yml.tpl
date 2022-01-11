name: 'Delete AWS Resources and Self-Destruct Github Runner'

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

      - name: Assume Role
        run: assume-role ${PROJECT_NAME}-${MODULE_NAME}-github-runner-aws

      - name: Delete S3 Bucket
        run: |
          if $(ls s3-bucket-aws-cloudformation); then
              ./s3-bucket-aws-cloudformation/delete-stack -p "${PROJECT_NAME}" "${MODULE_NAME}" "${PROJECT_AWS_REGION}"
          fi
    github-runner:
      name: 'Delete Github Runner'
      runs-on: self-hosted
      environment: production
      needs: ["base"]
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

        - name: Delete Github Runner
          run: |
            if $(ls github-runner-aws-cloudformation); then
                ./github-runner-aws-cloudformation/delete-stack.sh -p "${PROJECT_NAME}" "${MODULE_NAME}" "${PROJECT_AWS_REGION}"
            fi

