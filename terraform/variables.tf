variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cv02"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP CIDR for SSH access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local path to the private SSH key used by Ansible"
  type        = string
}
