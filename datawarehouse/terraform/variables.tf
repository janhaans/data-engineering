variable "region" {
  description = "The AWS region"
  type        = string
}

variable "profile" {
  description = "The AWS profile"
  type        = string
}

variable "redshift_iam_role_name" {
  description = "The name of the IAM role for Redshift"
  type        = string
}

variable "dwh_cluster_type" {
  description = "The type of Redshift cluster"
  type        = string
}

variable "dwh_node_type" {
  description = "The node type of the Redshift cluster"
  type        = string
}

variable "dwh_node_count" {
  description = "The number of nodes in the Redshift cluster"
  type        = number
}

variable "dwh_cluster_identifier" {
  description = "The identifier of the Redshift cluster"
  type        = string
}

variable "dwh_database_name" {
  description = "The name of the Redshift database"
  type        = string
}

variable "dwh_master_username" {
  description = "The master username for the Redshift cluster"
  type        = string
}

variable "dwh_master_password" {
  description = "The master password for the Redshift cluster"
  type        = string
}

