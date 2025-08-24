provider "aws" {
    region = "eu-north-1"
}

# things that I remembered : 
# so creating a vpc for an eks is really different from the ec2 instances
# because we are needy for assuring scalability and high availability via replication over az and subnets

# okay so we are going to use a specific module from terraform registry that is quite similar to the aws cloudformation template 

#vpc requirement or obligatory attributes
# module source and version
# availability zones, subnet cidr_blocks(private and public),vpc name and vpc_cidr_block 
# and tags for the ccm -> tags (eks name, public, private)

# ---
# enable nate gateway also make sure that one nat gateway is the gate
# enable dns_hostname


data "aws_availability_zones" "available" {
  
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"

    name = "my-eks-vpc-terraform"
    cidr = var.vpc_cidr_block
    azs = data.aws_availability_zones.available.names

    private_subnets = var.private_subnet_cidr_blocks
    public_subnets = var.public_subnet_cidr_blocks

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true

    #--------------------------
    #tags

    tags = {
      "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    }

    public_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/elb" = 1       
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
        "kubernetes.io/role/internal-elb" = 1    
    }


}