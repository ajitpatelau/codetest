# Create Primary VPC
resource "aws_vpc" "primary_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "primary"
  }
}

# Create subnet for each availability zone
resource "aws_subnet" "subnets" {
    count = length(var.subnet_cidrs)
    vpc_id = aws_vpc.primary_vpc.id
    availability_zone = var.subnet_azs[count.index]
    cidr_block = var.subnet_cidrs[count.index]
    tags = {
        Name = var.subnet_names[count.index]
    }
}

# Creating internet Gateway
resource "aws_internet_gateway" "ntier_igw" {
  vpc_id = aws_vpc.primary_vpc.id

  tags = {
    Name = "ntier-igw"
  }
}

# Create Router table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.primary_vpc.id
  tags = {
    Name = "public"
  }
  route {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.ntier_igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.primary_vpc.id
  tags = {
    Name = "private"
  }
  
}

# Associate public route table with subnets

resource "aws_route_table_association" "web_public_association" {
  route_table_id  = aws_route_table.public_rt.id
  subnet_id       = aws_subnet.subnets[0].id
}

# Web Security Groups
resource "aws_security_group" "websg" {
  vpc_id = aws_vpc.primary_vpc.id
  tags = {
    Name = "Web Sg"
  }
  ingress {
    description = "Opne SSH for all"
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp
    cidr_blocks = [ local.anywhere ]
  }
  
  ingress {
    description = "Opne HTTP for all"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp
    cidr_blocks = [local.anywhere ]
  }
  
  ingress {
    description = "Opne HTTPs for all"
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = local.tcp
    cidr_blocks = [ local.anywhere ]
  }
  
  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [ local.anywhere ]
    ipv6_cidr_blocks  = [ "::/0" ]
  }
  
  
}

# database Security Groups

resource "aws_security_group" "dbsg" {
  vpc_id      = aws_vpc.primary_vpc.id
  description = "Allow traffic from public subnet"
  tags = {
    Name = "DB Sg"
  }
  ingress {
    description = "Opne trafic mysql within VPC "
    from_port   = local.mysql_port
    to_port     = local.mysql_port
    protocol    = local.tcp
    cidr_blocks = [ var.vpc_cidr ]
  }
  
  ingress {
    description = "Opne SSH for all"
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp
    cidr_blocks = [ local.anywhere ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks = [ "::/0" ]
  }
}


