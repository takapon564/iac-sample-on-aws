provider "aws" {
  profile = "default"
  region = "ap-northeast-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "tf-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "tf-gw" {
  vpc_id = "${aws_vpc.tf-vpc.id}"
  
}

# piblic subnet
resource "aws_subnet" "tf-public-subnet" {
  vpc_id = "${aws_vpc.tf-vpc.id}"
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
}

# route table
resource "aws_route_table" "tf-pub-rt" {
  vpc_id = "${aws_vpc.tf-vpc.id}"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tf-gw.id}"
  }
}

#  An association between a route table and a subnet.
resource "aws_route_table_association" "tf-public_subnet" {
  subnet_id = "${aws_subnet.tf-public-subnet.id}"
  route_table_id = "${aws_route_table.tf-pub-rt.id}"
}

# EC2 instance
resource "aws_instance" "tf-ec2" {
  ami = "ami-068a6cefc24c301d2" # Amazon linux2
  instance_type = "t2.medium"
  key_name = "${aws_key_pair.tf-sample-key.id}"
  vpc_security_group_ids = ["${aws_security_group.tf-sg.id}"]
  subnet_id = "${aws_subnet.tf-public-subnet.id}"
  associate_public_ip_address = "true"
  tags = {
    Name = "tf-ec2"
  }
}

# key-pair
resource "aws_key_pair" "tf-sample-key" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# security group
resource "aws_security_group" "tf-sg" {
  name = "tf-sg"
  description = "tf test"
  vpc_id = "${aws_vpc.tf-vpc.id}"
}


resource "aws_security_group_rule" "http-port" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.tf-sg.id}"
}

resource "aws_security_group_rule" "out-bound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.tf-sg.id}"
}




