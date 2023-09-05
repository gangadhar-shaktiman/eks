provider "aws" {
  region = "ap-south-1" 
}

resource "aws_iam_role" "offsetmax_cluster" {
  name = "eks-offsetmax_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "offsetmax_cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.offsetmax_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role       = aws_iam_role.offsetmax_cluster.name
}

resource "aws_eks_cluster" "offsetmax_cluster" {
  name     = "offsetmax-cluster"
  role_arn = aws_iam_role.offsetmax_cluster.arn

  vpc_config {
    subnet_ids = [var.subnet_id_1, var.subnet_id_2]
  }

  depends_on = [
    aws_iam_role_policy_attachment.offsetmax_cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-EKS
  ]
  
}
resource "aws_security_group" "eks_node_group_sg" {
  name        = "eks-node-group-sg"
  description = "Security Group for EKS Node Group"
  vpc_id      = var.vpc_id  # Define your VPC ID here

  # Define inbound rule for port 9443
  ingress {
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict the source IP range if needed
  },
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict the source IP range if needed
  }
}


resource "aws_iam_role" "offsetmax_nodes" {
  name = "eks-node-group-offsetmax_nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "offsetmax_nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.offsetmax_nodes.name
}

resource "aws_iam_role_policy_attachment" "offsetmax_nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.offsetmax_nodes.name
}

resource "aws_iam_role_policy_attachment" "offsetmax_nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.offsetmax_nodes.name
}

resource "aws_eks_node_group" "offsetmax_nodes" {
  cluster_name    = aws_eks_cluster.offsetmax_cluster.name
  node_group_name = "offsetmax_nodes"
  node_role_arn   = aws_iam_role.offsetmax_nodes.arn
  subnet_ids      = [var.subnet_id_1, var.subnet_id_2]
  instance_types  = ["t3.xlarge"]
  capacity_type   = "ON_DEMAND"

  labels = {
    "Name" = "offsetmax"
  }

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Attach the Security Group to the EKS node group
  remote_access {
    ec2_ssh_key = "your-key-pair-name"
    source_security_group_ids = [aws_security_group.eks_node_group_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.offsetmax_nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.offsetmax_nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.offsetmax_nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}


