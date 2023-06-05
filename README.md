# AWS APP RUNNER

A DReAM deploy package for deploying an application to AWS App Runner.
This package requires `aws` cli to be present.
It uses codebuild to build and push the image to ECR private registry, and
then it uses apprunner to deploy the image.

The project must be a `git` repository and the `git` cli must be present.

## Testing locally

Comment backend config in `main.tf`.

Initialize `myapp` subdirectory with git and perform an initial commit:

```bash
cd myapp
git init
git add .
git commit -m "Initial commit"
```

From the root of the project, run:

```bash
dream run -tDp -- bash test.sh
```

After the test is done, you can clean up the resources:

```bash
dream run -tDp -- bash test-destroy.sh

cd myapp
rm -rf .git
```
Uncomment backend config in `main.tf`.