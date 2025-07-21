#!/bin/bash

set -e

echo "🛠️ Updating system..."
apt-get update -y
apt-get upgrade -y

echo "🐳 Installing Docker..."
apt-get install -y docker.io docker-compose
systemctl enable docker
usermod -aG docker vagrant

echo "📦 Creating SonarQube setup..."
mkdir -p /home/vagrant/sonarqube
cat <<EOF > /home/vagrant/sonarqube/docker-compose.yml
version: "3"
services:
  sonarqube:
    image: sonarqube:10.4.1-community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      SONAR_JAVA_OPTS: "-Xms512m -Xmx1024m"
      SONAR_ES_BOOTSTRAP_CHECKS_DISABLE: "true"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
    restart: unless-stopped

volumes:
  sonarqube_data:
  sonarqube_extensions:
EOF

echo "🚀 Starting SonarQube..."
cd /home/vagrant/sonarqube
docker-compose up -d

chown -R vagrant:vagrant /home/vagrant/sonarqube

echo "✅ SonarQube is running at http://192.168.56.20:9000 (user: admin / admin)"
