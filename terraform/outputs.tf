output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "mongodb_ec2_public_ip" {
  description = "Public IP of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.public_ip
}

output "mongodb_ec2_private_ip" {
  description = "Private IP of the MongoDB EC2 instance (used by EKS pods)"
  value       = aws_instance.mongodb.private_ip
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "s3_backup_bucket" {
  description = "S3 bucket name for MongoDB backups"
  value       = aws_s3_bucket.mongodb_backups.bucket
}

output "mongodb_connection_string" {
  description = "MongoDB connection string for the app (use private IP)"
  value       = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${aws_instance.mongodb.private_ip}:27017/tododb?authSource=admin"
  sensitive   = true
}
