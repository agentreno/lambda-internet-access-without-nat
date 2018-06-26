provider "aws" {
    region = "eu-west-1"
}

# VPC stuff
resource "aws_vpc" "lambda_testing_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "lambda_testing_vpc"
    }
}

resource "aws_internet_gateway" "lambda_testing_inet_gw" {
    vpc_id = "${aws_vpc.lambda_testing_vpc.id}"
}

resource "aws_route_table" "lambda_testing_public_routes" {
    vpc_id = "${aws_vpc.lambda_testing_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.lambda_testing_inet_gw.id}"
    }
}

resource "aws_subnet" "lambda_testing_public_subnet" {
    vpc_id = "${aws_vpc.lambda_testing_vpc.id}"
    cidr_block = "10.0.0.0/24"
    availability_zone = "eu-west-1a"
    map_public_ip_on_launch = true

    tags {
        Name = "lambda-testing-public-subnet"
    }
}

resource "aws_route_table_association" "lambda_testing_public_subnet" {
    subnet_id = "${aws_subnet.lambda_testing_public_subnet.id}"
    route_table_id = "${aws_route_table.lambda_testing_public_routes.id}"
}

resource "aws_security_group" "lambda_testing_outbound_only" {
    vpc_id = "${aws_vpc.lambda_testing_vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Lambda stuff
resource "aws_lambda_function" "vpc_public_subnet_test_function" {
    description = "Shows that Lambda cannot use a public subnet alone and requires NAT"
    function_name = "vpc_public_subnet_test_function"
    handler = "index.lambda_handler"
    memory_size = "128"
    runtime = "python3.6"
    timeout = 10
    role = "${aws_iam_role.vpc_public_subnet_test_role.arn}"

    filename = "index.zip"
    source_code_hash = "${base64sha256(file("index.zip"))}"


    vpc_config {
        subnet_ids = [
            "${aws_subnet.lambda_testing_public_subnet.id}"
        ]
        security_group_ids = [
            "${aws_security_group.lambda_testing_outbound_only.id}"
        ]
    }

}

resource "aws_iam_role" "vpc_public_subnet_test_role" {
    name = "vpc_public_subnet_test_role"

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

resource "aws_iam_role_policy" "vpc_public_subnet_test_role_policy" {
    name = "vpc_public_subnet_test_role_policy"
    role = "${aws_iam_role.vpc_public_subnet_test_role.id}"

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "xray:PutTelemetryRecords",
                "xray:PutTraceSegments"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

