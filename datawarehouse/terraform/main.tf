resource "aws_iam_role" "redshift_s3_readonly" {
    name = var.redshift_iam_role_name

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Principal = {
                    Service = "redshift.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "attach_s3_readonly_policy" {
    role       = aws_iam_role.redshift_s3_readonly.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_vpc" "default" {
    default = true
}

resource "aws_security_group" "redshift_sg" {
    name        = "redshift_sg"
    description = "Allow inbound access to Redshift port from all IP addresses"
    vpc_id      = data.aws_vpc.default.id

    ingress {
        from_port   = 5439
        to_port     = 5439
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_redshift_cluster" "dwh" {
    cluster_identifier         = var.dwh_cluster_identifier
    database_name              = var.dwh_database_name
    master_username            = var.dwh_master_username
    master_password            = var.dwh_master_password
    node_type                  = var.dwh_node_type
    cluster_type               = var.dwh_cluster_type
    number_of_nodes            = var.dwh_node_count
    publicly_accessible        = true
    iam_roles                  = [aws_iam_role.redshift_s3_readonly.arn]
    vpc_security_group_ids     = [aws_security_group.redshift_sg.id]
    skip_final_snapshot        = true
    final_snapshot_identifier  = "redshift-cluster-final-snapshot"
}

output "dwh_cluster_endpoint" {
    value = aws_redshift_cluster.dwh.endpoint       
}

output "dwh_cluster_role_arn" {
    value = aws_iam_role.redshift_s3_readonly.arn
}