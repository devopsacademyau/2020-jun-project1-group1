# Network ACL
# 2 NACLs public/private (ALLOW ALL is not permitted)
resource "aws_network_acl" "NACL-PUB" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet-public-1.id, aws_subnet.subnet-public-2.id]
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  # TODO: remove the following line
  ingress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "${var.project-name}-NACL-PUB"
  }
}
resource "aws_network_acl" "NACL-PRI" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet-private-1.id, aws_subnet.subnet-private-2.id]
  ingress {
    protocol   = "tcp"
    rule_no    = 90
    action     = "allow"
    cidr_block = var.vpcCIDR
    from_port  = 22
    to_port    = 22
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 95
    action     = "allow"
    cidr_block = cidrsubnet(var.vpcCIDR, 8, 1)
    from_port  = 3306
    to_port    = 3306
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 96
    action     = "allow"
    cidr_block = cidrsubnet(var.vpcCIDR, 8, 3)
    from_port  = 3306
    to_port    = 3306
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = var.vpcCIDR
    from_port  = 443
    to_port    = 443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 95
    action     = "allow"
    cidr_block = cidrsubnet(var.vpcCIDR, 8, 1)
    from_port  = 3306
    to_port    = 3306
  }
  egress {
    protocol   = "tcp"
    rule_no    = 96
    action     = "allow"
    cidr_block = cidrsubnet(var.vpcCIDR, 8, 3)
    from_port  = 3306
    to_port    = 3306
  }
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # TODO: remove the following line
  ingress {
    protocol   = "-1"
    rule_no    = 50
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 50
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project-name}-NACL-PRI"
  }
}
