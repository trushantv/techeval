variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "techeval"
}

variable "ssh_key_name" {
  description = "Name of the EC2 SSH key pair"
  type        = string
}

variable "mongodb_password" {
  description = "MongoDB admin password"
  type        = string
  sensitive   = true
}

variable "mongodb_username" {
  description = "MongoDB admin username"
  type        = string
  default     = "admin"
}
