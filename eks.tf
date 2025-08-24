
# -2- we want to establish authentication to the eks cluster
# in order to talk to k8s and provision eks resources 


#k8s api server needs tree things to trust terraform
#1- host : api server endpoint 
#2- cluster_ca_certificate : to establish TLs trust 
#3- token/credentials : authentication token 

provider "kubernetes" {
    host = data.aws_eks_cluster.eks.endpoint
    client_certificate = base64decode(data.aws_eks_cluster_auth.eks.certificate_authority[0].data)
#   token =  deprecated
# use aws cli
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
    }

}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}


#1- we want to create the eks cluster using module
module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "21.1.0"

  # cluster name and k8s version
    name = "eks-app"
    kubernetes_version = "1.27"
  # cluster tags 
    tags = {
        "environment": "development"
        "application": "my_app"
    }

  # vpc & subnet
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # which one (public or private) --> we are creating control plan not worker node so the worker must be private and ccp public.
  
  
  # worker group --> nodes
  eks_managed_node_groups = {
    dev = {
        min_size     = 1
        max_size     = 3
        desired_size = 3

        instance_types = ["t2.small"]
    }
  }

  # configure cluster endpoint : 
  endpoint_private_access = false
  endpoint_public_access = true

}