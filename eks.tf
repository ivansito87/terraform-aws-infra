resource "aws_eks_cluster" "portfolio_cluster" {
  name     = "portfolio-app-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }

  # Cost optimization settings
  enabled_cluster_log_types = []  # Disable logging to save costs
  version                   = "1.31"  # Latest supported version

  depends_on = [aws_iam_role_policy_attachment.eks_policy]

  tags = {
    Name = "portfolio-cluster"
  }
}

# Node group with cost-optimized settings
resource "aws_eks_node_group" "portfolio_node_group" {
  cluster_name    = aws_eks_cluster.portfolio_cluster.name
  node_group_name = "portfolio-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_subnets[*].id

  # Cost optimization settings
  instance_types = ["t3.medium"]  # Smallest instance type that works well with EKS
  capacity_type  = "ON_DEMAND"    # Use on-demand instances instead of spot

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  tags = {
    Name = "portfolio-node-group"
  }
}

# IAM role for EKS nodes
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}