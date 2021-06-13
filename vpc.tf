resource "aws_vpc" "main_vpc" {
  cidr_block = "192.168.0.0/16"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_subnet" "main_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main subnet 1 (public)"
  }
}

resource "aws_subnet" "main_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[1]
  cidr_block              = "192.168.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main subnet 2 (public)"
  }
}

resource "aws_subnet" "main_subnet_3" {
  vpc_id                  = aws_vpc.main_vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[2]
  cidr_block              = "192.168.5.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main subnet 3 (public)"
  }
}

resource "aws_internet_gateway" "main_ig" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_ig.id
  }

  tags = {
    Name = "Main"
  }
}

resource "aws_eip" "nat" {

}

resource "aws_nat_gateway" "main_ng" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main_subnet_1.id

  tags = {
    Name = "Main"
  }
}

resource "aws_route_table" "nat_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_ng.id
  }
}

resource "aws_route_table_association" "public_subnet_1_rt_assoc" {
  subnet_id      = aws_subnet.main_subnet_1.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_route_table_association" "public_subnet_2_rt_assoc" {
  subnet_id      = aws_subnet.main_subnet_2.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = "192.168.1.0/24"

  tags = {
    Name = "Subnet 1"
  }
}

resource "aws_route_table_association" "subnet_1_rt_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.nat_rt.id
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[1]
  cidr_block        = "192.168.2.0/24"

  tags = {
    Name = "Subnet 2"
  }
}

resource "aws_route_table_association" "subnet_2_rt_assoc" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.nat_rt.id
}

resource "aws_subnet" "subnet_3" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = data.aws_availability_zones.azs.names[2]
  cidr_block        = "192.168.3.0/24"

  tags = {
    Name = "Subnet 3"
  }
}

resource "aws_route_table_association" "subnet_3_rt_assoc" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.nat_rt.id
}

resource "aws_key_pair" "ssh_key" {
  public_key = file(var.public_key_location)
  key_name   = "sshkey"
}