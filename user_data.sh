#!/bin/bash
# Install Docker
apt-get update -y
apt-get install -y docker.io
systemctl start docker
usermod -aG docker ${USER}

# Install Git
apt-get install -y git

# Clone the API repository
git clone https://github.com/SethDeTable/DEVOPSTTTP

# Build and run the Docker container
cd DEVOPSTTTP
docker build -t my-api .
docker run -d -p 8080:8080 my-api

# Install Nginx
apt-get install -y nginx
systemctl start nginx

# Configure Nginx to proxy requests to the API
cat <<EOT > /etc/nginx/sites-available/api
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

ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
systemctl restart nginx
