#!/usr/bin/env bash
set -e

# Mise a jour du systeme
apt-get update -y
apt-get upgrade -y

# Dependances pour installer Docker proprement
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Ajout de la cle GPG officielle de Docker
mkdir -p /etc/apt/keyrings
rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --yes --batch --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajout du depot Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation de Docker Engine + Compose plugin
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Permettre a l'utilisateur vagrant d'utiliser Docker sans sudo
usermod -aG docker vagrant

# Verification
docker --version
docker compose version

echo "Docker installe avec succes dans la VM."