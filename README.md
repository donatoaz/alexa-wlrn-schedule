# wlrnschedule

This is an Alexa skill for WLRN radio now playing information.

## Deploy the sample application

The Serverless Application Model Command Line Interface (SAM CLI) is an extension of the AWS CLI that adds functionality for building and testing Lambda applications. It uses Docker to run your functions in an Amazon Linux environment that matches Lambda. It can also emulate your application's build environment and API.

To use the SAM CLI, you need the following tools.

- AWS CLI - [Install the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and [configure it with your AWS credentials].
- SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- Ruby - [Install Ruby 2.5](https://www.ruby-lang.org/en/documentation/installation/)
- Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

Make sure you have your credentials set up, in the examples below a profile named `wlrnsamuser` is used, as in the `~/.aws/config` has the following:

```
[profile wlrnsamuser]
aws_access_key_id = xxxx
aws_secret_access_key = yyyy
region = us-east-1
```

The SAM CLI uses an Amazon S3 bucket to store your application's deployment artifacts. If you don't have a bucket suitable for this purpose, create one. Replace `BUCKET_NAME` in the commands in this section with a unique bucket name.

```bash
wlrnschedule$ aws s3 mb s3://BUCKET_NAME --profile wlrnsamuser
```

Since this package uses vended dependencies (namely [HTTParty](https://github.com/jnunemaker/httparty)) we need to build the application with the `--use-container` option. For more details, run the command with the `--debug` flag.

```
wlrnschedule$ sam build --profile wlrnsamuser --use-container
```

To prepare the application for deployment, use the `sam package` command.

```bash
wlrnschedule$ sam package --s3-bucket BUCKET_NAME \
  --output-template-file packaged.yml --profile wlrnsamuser
```

The SAM CLI creates deployment packages, uploads them to the S3 bucket, and creates a new version of the template that refers to the artifacts in the bucket.

To deploy the application, use the `sam deploy` command.

```bash
wlrnschedule$ sam deploy \
  --template-file /Users/donato/src/study/alexa/wlrnschedule/packaged.yml \
  --stack-name STACK_NAME \
  --capabilities CAPABILITY_IAM \
  --profile wlrnsamuser \
  --role-arn arn:aws:iam::846282225459:role/WlrnScheduleSAMRole
```

After deployment you can plug in the `WlrnScheduleAlexaLambdaFunctionArn` into your Alexa Skills under Build > Endpoints

## Add a resource to your application

The application template uses AWS Serverless Application Model (AWS SAM) to define application resources. AWS SAM is an extension of AWS CloudFormation with a simpler syntax for configuring common serverless application resources such as functions, triggers, and APIs. For resources not included in [the SAM specification](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md), you can use standard [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html) resource types.

## Fetch, tail, and filter Lambda function logs

To simplify troubleshooting, SAM CLI has a command called `sam logs`. `sam logs` lets you fetch logs generated by your deployed Lambda function from the command line. In addition to printing the logs on the terminal, this command has several nifty features to help you quickly find the bug.

`NOTE`: This command works for all AWS Lambda functions; not just the ones you deploy using SAM.

```bash
wlrnschedule$ sam logs -n HelloWorldFunction --stack-name wlrnschedule --tail
```

You can find more information and examples about filtering Lambda function logs in the [SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-logging.html).

## Unit tests

**TO DO**

Tests are defined in the `tests` folder in this project.

```bash
wlrnschedule$ ruby tests/unit/test_handler.rb
```

## Cleanup

To delete the sample application and the bucket that you created, use the AWS CLI.

```bash
wlrnschedule$ aws cloudformation delete-stack --stack-name wlrnschedule
wlrnschedule$ aws s3 rb s3://BUCKET_NAME
```

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.

Next, you can use AWS Serverless Application Repository to deploy ready to use Apps that go beyond hello world samples and learn how authors developed their applications: [AWS Serverless Application Repository main page](https://aws.amazon.com/serverless/serverlessrepo/)

## TODO

- [x] Add CI
- [x] Add CD
- [] Add proper caching
- [] Add show time alerts (via alexa notifications)
- [] Add localization (know user's [local time](https://stackoverflow.com/questions/50714782/how-to-get-the-time-zone-or-local-time-of-alexa-device))
