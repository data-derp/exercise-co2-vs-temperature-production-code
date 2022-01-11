# CO2 vs. Temperature Exercise (Production Code)
This repository contains the production code contained in the associated [Databricks exercise](https://github.com/data-derp/exercise-co2-vs-temperature-databricks). The goal is to demonstrate what that logic would look like in production code, with tests, along with a pipeline to deploy it to a target.

To recall, the relevant questions that this code aims to answer are the following:
* Which countries are worse-hit (higher temperature anomalies)?
* Which countries are the biggest emitters?
* What are some attempts of ranking “biggest polluters” in a sensible way?

For more information on the data sources, please visit the [associated Databricks exercise](https://github.com/data-derp/exercise-co2-vs-temperature-databricks).

This code is designed to be deployed as an AWS Glue Job.

## Prerequisites
* Basic knowledge of Python, Spark, Docker, Terraform
* Access to an AWS account (Optional)

## Quickstart
1. [Mirror this repo](#mirror-the-repository) in your account as a **PRIVATE** repo (since you're running your own self-hosted Github Runners, you'll want to ensure your project is Private)
2. Set up your [Development Environment](./development-environment.md)
3. Fetch input data: `./go fetch-data`
4. **Optionally** set up the [pipeline](#pipeline-optional)
5. **Sort of optional.** If you set up the pipeline in (4), you'll need to set up an AWS bucket to interact with
   * Simply run: `git submodule add git@github.com:data-derp/s3-bucket-aws-cloudformation.git` and the pipeline will take care of [setting up the bucket](https://github.com/data-derp/s3-bucket-aws-cloudformation#setup) for you
6. Fix the tests in `data-ingestion/` and `data-transformation/` (in that order). See [Development Environment](./development-environment.md) for tips and tricks on running python/tests in the dev-container.

## Mirror the Repository
1. Start importing a repository in your Github account:  
   ![import-menu](./assets/import-menu.png)

2. Import the `https://github.com/data-derp/exercise-co2-vs-temperature-production-code` as a **PRIVATE** repo called `exercise-co2-vs-temperature-production-code`:
   ![import-form](./assets/import-form.png)

3. Clone the new repo locally and add the original repository as a source:
```bash
git clone git@github.com:<your-username>/exercise-co2-vs-temperature-production-code.git
cd ./exercise-co2-vs-temperature-production-code
git remote add source git@github.com:data-derp/exercise-co2-vs-temperature-production-code.git 
```

4. To pull in new changes:
```bash
git fetch source
git rebase source/master
```
## Pipeline (optional)
In this step, we will bootstrap a Self-Hosted Github Runner. [What is a Github Self-hosted Runner?](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners)

1. Set up a [Github Runner](https://github.com/data-derp/github-runner-aws-cloudformation#setup)
2. Set up workflows:
```bash
./setup-workflows -p <your-project-name> -m <your-module-name> -r <aws-region>
```
3. Commit the new workflow template and push to see your changes.
4. Fix the tests in `data-ingestion/` and `data-transformation/` (in that order) and push to see your changes run in the pipeline. See [Development Environment](./development-environment.md) for tips and tricks on running python/tests in the dev-container.

## Future Development
- [x] Script to pull in data
- [ ] Dockerise `./setup-workflows`
- [ ] Option for running Github Runner locally in a Docker container
- [ ] Manual workflow to delete S3 Bucket and contents
- [ ] Manual workflow to delete Github Runner Cloudformation Stack (and Github Runner Reg Token)
