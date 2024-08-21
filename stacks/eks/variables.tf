variable "eks_public_access" {
  type    = bool
  default = false
}

variable "stack" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "eks_users" {
  type    = list(string)
  default = []
}

variable "eks_roles" {
  type    = list(string)
  default = []
}

variable "node_groups" {
  type = map(object({
    instance_types = string
    desired_size   = number
    min_size       = optional(number, 1)
    max_size       = number
    taint          = optional(bool, false)
  }))
}
