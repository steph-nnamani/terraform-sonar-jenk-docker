#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

# Update package lists
apt update

# Install Jenkins
apt install -y unzip openjdk-11-jre-headless
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | gpg --dearmor | sudo tee /usr/share/keyrings/jenkins-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-archive-keyring.gpg] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update
apt-get install -y jenkins

# Start Jenkins service
systemctl start jenkins

# Install Docker
apt install -y docker.io

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Add the current user to the Docker group
CURRENT_USER=$(whoami)
usermod -aG docker $CURRENT_USER

# Add the Jenkins user to the Docker group
JENKINS_USER="jenkins"
usermod -aG docker $JENKINS_USER

echo "Jenkins has been installed."
echo "Docker has been installed, and users $CURRENT_USER and $JENKINS_USER have been added to the Docker group."
JENKINS_INITIAL_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Jenkins Initial Admin Password: $JENKINS_INITIAL_PASSWORD"