resource "aws_db_instance" "portfolio_db" {
  identifier            = "portfolio-db"
  allocated_storage     = 20
  engine               = "postgres"
  engine_version       = "12.18"
  instance_class       = "db.t3.micro"
  username            = "portfolio_admin"
  password            = "YourSecurePassword"
  publicly_accessible  = false
  skip_final_snapshot  = true
  
  # Cost optimization settings
  multi_az               = false
  storage_encrypted      = false
  backup_retention_period = 0
  backup_window          = null
  maintenance_window     = null
  auto_minor_version_upgrade = false
  performance_insights_enabled = false
  monitoring_interval    = 0
                      
  # Security settings
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  
  tags = {
    Name = "portfolio-db"
  }
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_sg.id]  # Allow access from EKS cluster
  }

  tags = {
    Name = "rds-security-group"
  }
}

# DB subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.eks_subnets[*].id

  tags = {
    Name = "rds-subnet-group"
  }
}

# Security group for EKS cluster
resource "aws_security_group" "eks_sg" {
  name        = "eks-security-group"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-security-group"
  }
}