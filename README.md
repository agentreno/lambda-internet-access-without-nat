# lambda-internet-access-without-nat

## Description

Yep, you can just create a Lambda outside of a VPC and it gets internet access.

~~You can also put it in a public subnet and if the subnet has the terraform
`map_public_ip_on_launch` set to true for the function, it can also get
internet access this way (no NAT, IGW only access).~~

Unfortunately you can't have it both ways (a VPC but no NAT instance). Trying
to put a Lambda into a public subnet with an IGW and no NAT doesn't work, as
the example in `vpc_public_subnet/` proves. If you create an EC2 instance, it
works! But not Lambda.

Here are some conditions under which you might want to put it in a VPC:

- You need to access other stuff that is already in a VPC.

- You need to use resources which must be created in a VPC (e.g. Elasticache
  cache.t2.micro instance type must be launched in a VPC).

- You need your Lambda function to have a static IP for some reason.

- You want to future proof your Lambda function when the above might apply.

But if you do end up having a NAT instance, it'll cost a minimum of 35 dollars
a month before data transfer costs.
