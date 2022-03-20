# Creating Ec2 instance

resource "aws_instance" "web_instance_1" {
    ami                         = var.ami
    associate_public_ip_address = true
    instance_type               = "t2.micro"
    key_name                    = "jenkin"
    vpc_security_group_ids      = [aws_security_group.websg.id]
    subnet_id                   = aws_subnet.subnets[0].id
    tags = {
      Name = "webserver"
    }
}

resource "aws_instance" "db_instance_1" {
    ami                         = var.ami
    associate_public_ip_address = false
    instance_type               = "t2.micro"
    key_name                    = "jenkin"
    vpc_security_group_ids      = [aws_security_group.dbsg.id]
    subnet_id                   = aws_subnet.subnets[1].id
    tags = {
      Name = "database"
    }
}
