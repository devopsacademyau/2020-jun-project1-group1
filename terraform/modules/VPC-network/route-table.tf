# Route tables and assosications
# public
resource "aws_route_table" "route-table-PUB" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "${var.project-name}-route-table-PUB"
  }
}
# private
resource "aws_route_table" "route-table-PRI" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project-name}-route-table-PRI"
  }

}

resource "aws_route" "private-nat-route" {
  count                  = var.deploy_nat ? 1 : 0
  route_table_id         = aws_route_table.route-table-PRI.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.NAT-GW[count.index].id
}

# route table associations
# public route tables
resource "aws_route_table_association" "public-1" {
  subnet_id      = aws_subnet.subnet-public-1.id
  route_table_id = aws_route_table.route-table-PUB.id
}

resource "aws_route_table_association" "public-2" {
  subnet_id      = aws_subnet.subnet-public-2.id
  route_table_id = aws_route_table.route-table-PUB.id
}

# private route tables
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.subnet-private-1.id
  route_table_id = aws_route_table.route-table-PRI.id
}

resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.subnet-private-1.id
  route_table_id = aws_route_table.route-table-PRI.id
}

