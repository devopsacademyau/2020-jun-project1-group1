
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = [
    {
      id                = aws_subnet.subnet-public-1.id
      availability_zone = aws_subnet.subnet-public-1.availability_zone
      cidr_block        = aws_subnet.subnet-public-1.cidr_block
      arn               = aws_subnet.subnet-public-1.arn
    },
    {
      id                = aws_subnet.subnet-public-2.id
      availability_zone = aws_subnet.subnet-public-2.availability_zone
      cidr_block        = aws_subnet.subnet-public-2.cidr_block
      arn               = aws_subnet.subnet-public-2.arn
    }
  ]
}

output "private_subnets" {
  value = [
    {
      id                = aws_subnet.subnet-private-1.id
      availability_zone = aws_subnet.subnet-private-1.availability_zone
      cidr_block        = aws_subnet.subnet-private-1.cidr_block
      arn               = aws_subnet.subnet-private-1.arn
    },
    {
      id                = aws_subnet.subnet-private-2.id
      availability_zone = aws_subnet.subnet-private-2.availability_zone
      cidr_block        = aws_subnet.subnet-private-2.cidr_block
      arn               = aws_subnet.subnet-private-2.arn
    }
  ]
}

output "subnet-public-1" {
  value = aws_subnet.subnet-public-1.id
}
output "subnet-public-2" {
  value = aws_subnet.subnet-public-2.id
}
