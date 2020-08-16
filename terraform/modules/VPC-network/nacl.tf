locals {
  private_nacls_rules = [
    {
      from_port = 80
      to_port   = 80
      source    = "0.0.0.0/0"
    },
    {
      from_port = 443
      to_port   = 443
      source    = "0.0.0.0/0"
    },
    {
      from_port = 32768
      to_port   = 65535
      source    = "0.0.0.0/0"
    },
    {
      from_port = 3306
      to_port   = 3306
      source    = "0.0.0.0/0"
    },
    {
      from_port = 2049
      to_port   = 2049
      source    = "0.0.0.0/0"
    },
    # {
    #   from_port = 80
    #   to_port   = 80
    #   source    = "::/0"
    # },
    # {
    #   from_port = 443
    #   to_port   = 443
    #   source    = "::/0"
    # },
    # {
    #   from_port = 32768
    #   to_port   = 65535
    #   source    = "::/0"
    # }
  ]
}

# Network ACL
# 2 NACLs public/private (ALLOW ALL is not permitted)
resource "aws_network_acl" "NACL-PUB" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet-public-1.id,
    aws_subnet.subnet-public-2.id
  ]
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
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
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
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "${var.project-name}-NACL-PUB"
  }
}

resource "aws_network_acl" "NACL-PRI" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = [
    aws_subnet.subnet-private-1.id,
    aws_subnet.subnet-private-2.id
  ]

  tags = {
    Name = "${var.project-name}-NACL-PRI"
  }
}

resource "aws_network_acl_rule" "private-allow-ingress" {
  count = length(local.private_nacls_rules)

  network_acl_id = aws_network_acl.NACL-PRI.id
  rule_number    = 100 + count.index * 10
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  from_port      = local.private_nacls_rules[count.index].from_port
  to_port        = local.private_nacls_rules[count.index].to_port

  cidr_block      = local.private_nacls_rules[count.index].source == "0.0.0.0/0" ? local.private_nacls_rules[count.index].source : null
  ipv6_cidr_block = local.private_nacls_rules[count.index].source == "::/0" ? local.private_nacls_rules[count.index].source : null
}

resource "aws_network_acl_rule" "private-allow-egress" {
  count = length(local.private_nacls_rules)

  network_acl_id  = aws_network_acl.NACL-PRI.id
  rule_number     = 100 + count.index * 10
  egress          = true
  protocol        = "tcp"
  rule_action     = "allow"
  from_port       = local.private_nacls_rules[count.index].from_port
  to_port         = local.private_nacls_rules[count.index].to_port
  cidr_block      = local.private_nacls_rules[count.index].source == "0.0.0.0/0" ? local.private_nacls_rules[count.index].source : null
  ipv6_cidr_block = local.private_nacls_rules[count.index].source == "::/0" ? local.private_nacls_rules[count.index].source : null
}

