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
  type = list(string)
  default = []
}

variable "eks_roles" {
  type = list(string)
  default = []
}
