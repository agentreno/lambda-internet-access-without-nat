provider "aws" {
    region = "eu-west-1"
}

resource "aws_lambda_function" "outside_vpc_test_function" {
    description = "Shows that Lambda can access the internet without a NAT gateway"
    function_name = "outside_vpc_test_function"
    handler = "index.lambda_handler"
    memory_size = "128"
    runtime = "python3.6"
    timeout = 10
    role = "${aws_iam_role.outside_vpc_test_role.arn}"

    filename = "index.zip"
    source_code_hash = "${base64sha256(file("index.zip"))}"
}

resource "aws_iam_role" "outside_vpc_test_role" {
    name = "outside_vpc_test_role"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
