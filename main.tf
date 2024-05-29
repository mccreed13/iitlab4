terraform{
 required_providers {
  aws = {
   source = "hashicorp/aws"
   version = "~> 4.16"
  }
 }
}

provider "aws" {
 region = "eu-north-1"
 access_key = ${{ AWS_ACCESS_KEY }}
 secret_key = ${{ AWS_SECRET_KEY }}
}

resource "aws_instance" "web" {
 ami = "ami-0705384c0b33c194c"
 instance_type = "t3.micro"
 key_name = "keylab4"
 vpc_security_group_ids = [aws_security_group.http_server.id]
 
 tags = {
  Name = "Lab6"
 }
 
 user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install -y docker
  sudo docker pull mccreed13/iitlab4:latest
  sudo docker rm -f iitlab4-containter || true
  sudo docker run -d -p 80:80 --name iitlab4-containter mccreed13/iitlab4
 EOF 
}

resource "aws_security_group" "http_server"{
 name = "web_server"
 description = "Inbound and outbound traffic"
 vpc_id = "vpc-06412e926c584167b"
 
 tags = {
  Name = "web-server"
 }
}

resource "aws_vpc_security_group_ingress_rule" "http_server_http_rule" {
 security_group_id = aws_security_group.http_server.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = 80
 ip_protocol = "tcp"
 to_port = 80
}


resource "aws_vpc_security_group_ingress_rule" "http_server_ssh_rule" {
 security_group_id = aws_security_group.http_server.id
 cidr_ipv4 = "0.0.0.0/0"
 from_port = 22
 ip_protocol = "tcp"
 to_port = 22
}


resource "aws_vpc_security_group_egress_rule" "http_server_outbound_rule" {
 security_group_id = aws_security_group.http_server.id
 from_port = 0
 to_port = 0
 cidr_ipv4 = "0.0.0.0/0"
 ip_protocol = "-1"
}
