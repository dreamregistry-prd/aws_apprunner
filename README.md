# AWS APP RUNNER

A DReAM deploy package for deploying an application to AWS App Runner.
This package requires `aws` cli to be present.
It uses codebuild to build and push the image to ECR private registry, and
then it uses apprunner to deploy the image.

The project must be a `git` repository and the `git` cli must be present.
