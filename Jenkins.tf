
variable "account_id" {

}
provider "aws" {
  profile = "jitendra-awsroot"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform"
  }
}
resource "tls_private_key" "key1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair1" {
  key_name   = "JK_myKey"
  public_key = tls_private_key.key1.public_key_openssh
}

resource "aws_instance" "ec2" {
  ami = "ami-0427090fd1714168b"
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_pair1.key_name
  user_data = <<EOF
		#! /bin/bash
        sudo yum update -y
		sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
		sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
		sudo yum upgrade
		sudo dnf install java-17-amazon-corretto -y
        sudo yum install jenkins -y
        sudo systemctl enable jenkins
        sudo systemctl start jenkins
	EOF
}