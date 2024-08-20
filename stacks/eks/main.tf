module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.5.0"

  cluster_name = "test_cluster"
  cluster_version = "1.30"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = var.eks_public_access

}
