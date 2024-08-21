data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  node_groups = {
    for name, props in var.node_groups : name => {
      desired_size = props.desired_size
      max_size     = props.max_size
      min_size     = props.min_size

      instance_types              = [props.instance_types]
      create_iam_instance_profile = true
      iam_role_name               = "${var.stack}-eks-${name}-group"
      iam_role_use_name_prefix    = false
      iam_role_description        = "EKS managed node group - ${var.stack} - ${name}"
      labels = {
        node_group = name
      }
      taints = !props.taint ? [] : [{
        key    = "node_group",
        value  = name,
        effect = "NO_SCHEDULE"
      }]
    }
  }

  eks_principals = concat(
    [for user in var.eks_users : "arn:aws:iam::${local.account_id}:user/${user}"],
    [for role in var.eks_roles : "arn:aws:iam::${local.account_id}:role/${role}"]
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.5.0"

  cluster_name                    = "test_cluster"
  cluster_version                 = "1.30"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.eks_public_access

  subnet_ids = var.private_subnets
  vpc_id     = var.vpc_id

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  eks_managed_node_groups = local.node_groups

  access_entries = {
    for v in local.eks_principals : v => {
      principal_arn = v
      policy_associations = {
        admin = {
          # Make these principals cluster admins
          # https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html#access-policy-permissions
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
