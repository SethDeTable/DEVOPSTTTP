#!/bin/bash
# Install Docker
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user

# Install Git
yum install git -y

# Clone the API repository
git clone https://github.com/yourusername/your-api-repo.git /home/ec2-user/api

# Build and run the Docker container
cd /home/ec2-user/api
docker build -t my-api .
docker run -d -p 8080:8080 my-api

# Install Nginx
amazon-linux-extras install nginx1.12 -y
service nginx start

# Configure Nginx to proxy requests to the API
cat <<EOT > /etc/nginx/conf.d/api.conf
server {
    listen 80;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT

# Restart Nginx to apply the configuration
service nginx restart
