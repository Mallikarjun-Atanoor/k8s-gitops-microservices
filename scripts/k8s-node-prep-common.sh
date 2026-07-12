#!/bin/bash

###############################################################################
# Script Name : common.sh
# Description : k8s-node-prep-common

set -euo pipefail

echo "=================================================="
echo " Kubernetes Node Preparation Started"
echo "=================================================="

############################################
# Root Check
############################################

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

############################################
# OS Verification
############################################

echo "Verifying Operating System..."

if ! grep -q "Ubuntu" /etc/os-release; then
    echo "ERROR: Unsupported Operating System."
    exit 1
fi

echo "Operating System Verified."

############################################
# System Update
############################################

echo "Updating packages..."

apt-get update -y
apt-get upgrade -y

############################################
# Required Packages
############################################

apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gpg \
software-properties-common \
lsb-release

############################################
# Disable Swap
############################################

echo "Disabling swap..."

swapoff -a

sed -i '/ swap / s/^/#/' /etc/fstab

echo "Swap Status"

swapon --show

############################################
# Kernel Modules
############################################

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "Loaded Kernel Modules"

lsmod | grep overlay
lsmod | grep br_netfilter

############################################
# Sysctl Parameters
############################################

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

echo "Verifying Sysctl"

sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward

############################################
# Install Containerd
############################################

echo "Installing Containerd..."

apt-get install -y containerd

mkdir -p /etc/containerd

containerd config default > /etc/containerd/config.toml

############################################
# Configure Systemd Cgroup
############################################

echo "Configuring Systemd Cgroup..."

sed -i \
's/SystemdCgroup = false/SystemdCgroup = true/' \
/etc/containerd/config.toml

systemctl daemon-reload

systemctl enable containerd

systemctl restart containerd

############################################
# Verify Containerd
############################################

echo "Containerd Status"

systemctl is-active containerd

echo "Checking Cgroup Driver"

containerd config dump | grep SystemdCgroup

############################################
# Kubernetes Repository
############################################

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
| gpg --dearmor \
-o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' \
| tee /etc/apt/sources.list.d/kubernetes.list

############################################
# Install Kubernetes Packages
############################################

apt-get update

apt-get install -y \
kubelet \
kubeadm \
kubectl

apt-mark hold \
kubelet \
kubeadm \
kubectl

############################################
# Enable Kubelet
############################################

systemctl enable kubelet

############################################
# Version Verification
############################################

echo
echo "========================================="
echo " Installed Versions"
echo "========================================="

containerd --version

kubeadm version

kubectl version --client

kubelet --version

############################################
# Final Verification
############################################

echo
echo "========================================="
echo " Verification"
echo "========================================="

echo
echo "Swap"

swapon --show

echo
echo "Containerd"

systemctl is-active containerd

echo
echo "Kubelet"

systemctl is-enabled kubelet

echo
echo "Kernel Modules"

lsmod | grep overlay

lsmod | grep br_netfilter

echo
echo "Systemd Cgroup"

containerd config dump | grep SystemdCgroup

echo
echo "IP Forward"

sysctl net.ipv4.ip_forward

echo
echo "========================================="
echo " Node Preparation Completed Successfully"
echo "========================================="
