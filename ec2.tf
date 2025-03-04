resource "aws_instance" "frontend_ec2" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Replace with latest Amazon Linux 2 AMI for your region
  instance_type          = "t3.micro"
  key_name               = "front-end-server"          # Replace with your EC2 key pair
  security_groups        = [aws_security_group.frontend_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras enable nginx1
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Frontend Server Running</h1>" | sudo tee /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "Portfolio-Frontend"
  }
}