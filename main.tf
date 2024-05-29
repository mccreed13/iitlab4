terraform{
 required_providers {
  aws = {
   source = "hashicorp/aws"
   version = "~> 4.16"
  }
 }
}

variable "aws_access" {
 type = string
 sensitive = true
}

variable "aws_secret" {
 type = string
 sensitive = true
}

provider "aws" {
 region = "eu-north-1"
 access_key = var.aws_access
 secret_key = var.aws_secret
}

resource "aws_instance" "web" {
 ami = "ami-0705384c0b33c194c"
 instance_type = "t3.micro"
 key_name = "keylab4"
 vpc_security_group_ids = [aws_security_group.http_server.id]
 
 tags = {
  Name = "Lab6_1"
 }
 
 user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install -y docker
  sudo docker pull mccreed13/iitlab4:latest
  sudo docker rm -f iitlab4-containter || true
  sudo docker run -d -p 80:80 --name iitlab4-containter mccreed13/iitlab4
  mkdir actions-runner && cd actions-runner
  curl -o actions-runner-linux-x64-2.316.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.316.1/actions-runner-linux-x64-2.316.1.tar.gz
  echo "d62de2400eeeacd195db91e2ff011bfb646cd5d85545e81d8f78c436183e09a8  actions-runner-linux-x64-2.316.1.tar.gz" | shasum -a 256 -c
  tar xzf ./actions-runner-linux-x64-2.316.1.tar.gz
  ./config.sh --url https://github.com/mccreed13/iitlab4 --token AYVLO2IPXAMKD53BMLDW2E3GK4YME
  ./run.sh
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
 from_port = "-1"
 to_port = "-1"
 cidr_ipv4 = "0.0.0.0/0"
 ip_protocol = "-1"
}
