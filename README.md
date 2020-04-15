# aws-demo-cloudone
AWS - Cloud One Demo (Including Deep Security, TippingPoint, Smart Check and App Protect)

## Requirements
- AWS Account
- Linux EC2 Instance (tested with Ubuntu)
- AWS CLI v2 Installed on the  Linux Instance (authenticated)

## How to demo
### Phase1 - Demo Preparation
- Create one Linux Instance in EC2;
- Follow the instructions described in this file: https://raw.githubusercontent.com/andrefernandes86/aws-demo-cloudone/master/instructions.txt

### Phase2 - Additional Configurations
- After you get the username, password and Smart Check URL, access the URL and change the password;
- Get the ECR ID from your AWS Account - https://console.aws.amazon.com/ecr/repositories?region=us-east-1
- Register the ECR into Smart Check Management Console;
- Start a new scan;
