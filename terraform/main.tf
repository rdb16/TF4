terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    key = "aws/ec2-deploy/terraform.tfstate"
  }
}
provider "aws" {
  region                   = var.region
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile                  = "default"
}

resource "aws_instance" "ec2-docker" {
    ami = "ami-0493936afbe820b28" # Ubuntu LTS 22-04
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.main_group.id]
    iam_instance_profile = aws_instance_profile.ec2-profile.name
    key_name =  aws_key_pair.deployer_key.key_name
    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = var.private_key
        timeout = "4m"
    }
    tags = {
        name = "Deploy-ec2-docker"
    }
}
resource "aws_security_group" "main_group"{

    egress = [
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 0
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "-1"
            security_groups = []
            self = false
            to_port = 0
        }
    ]

    ingress = [
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 22
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "tcp"
            security_groups = []
            self = false
            to_port = 22
        },
        {
            cidr_blocks = ["0.0.0.0/0"]
            description = ""
            from_port = 80
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            protocol = "tcp"
            security_groups = []
            self = false
            to_port = 80

        }
    ]
    
}

resource "aws_instance_profile" "ec2-profile" {
    name = "ec2-profile"
    role = "EC2-ECR-AUTH"
}
resource "aws_key_pair" "deployer-key" {
    key_name = var.key_name
    public_key = var.public_key
}

output "instance_public_ip" {
    value = aws_instance.ec2_docker.public_ip
    sensitive = true
}


