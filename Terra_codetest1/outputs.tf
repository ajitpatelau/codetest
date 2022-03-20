output "web1_publicip" {
  value = aws_instance.web_instance_1.public_ip
}

output "vpc_id" {
    value = aws_vpc.primary_vpc.id
}

output "web1_subnet_id" {
    value = aws_subnet.subnets[0].id
}

output "web_security_group_ids" {
    value = aws_security_group.websg.id
}

output "db_security_group_ids" {
    value = aws_security_group.dbsg.id
}

output "web_url" {
    value = format("http://%s", aws_instance.web_instance_1.public_ip)
}

output "ssh_command" {
    value = format("ssh -i %s.pem ubuntu@%s", "terraform", aws_instance.web_instance_1.public_ip)
}
