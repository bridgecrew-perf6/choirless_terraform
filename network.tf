
resource "aws_vpc" "choirlessEFSVPC" {
  cidr_block = "10.0.0.0/16"
  #enable_dns_support = true
  #enable_dns_hostnames = true

  tags = merge(var.tags,
    map(
      "Name", "choirlessEFSVPC"
    ))
}

resource "aws_vpc_endpoint" "choirlessS3" {
  vpc_id = aws_vpc.choirlessEFSVPC.id
  service_name = "com.amazonaws.eu-west-1.s3"
}

# Subnets because Lambda recommends at least 2
resource "aws_subnet" "choirlessEFSSubnet1" {
  vpc_id = aws_vpc.choirlessEFSVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "choirlessEFSSubnet2" {
  vpc_id = aws_vpc.choirlessEFSVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
}



# route table so that there is a route to the internet and a route to the vpc endpoint
resource "aws_route_table" "choirlessEFSRT" {
  vpc_id = aws_vpc.choirlessEFSVPC.id
}

resource "aws_route_table_association" "choirlessEFSRTA1" {
  subnet_id = aws_subnet.choirlessEFSSubnet1.id
  route_table_id = aws_route_table.choirlessEFSRT.id
}

resource "aws_route_table_association" "choirlessEFSRTA2" {
  subnet_id = aws_subnet.choirlessEFSSubnet2.id
  route_table_id = aws_route_table.choirlessEFSRT.id
}

resource "aws_vpc_endpoint_route_table_association" "choirlessEFSERTA" {
  route_table_id = aws_route_table.choirlessEFSRT.id
  vpc_endpoint_id = aws_vpc_endpoint.choirlessS3.id
}
