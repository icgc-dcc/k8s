# ICGC-DCC k8s

This repository contains all the code to deploy Kubernetes on OICR's OpenStack

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

1. Terraform
   Set up OpenStack infrastructure declaratively.

2. Ansible
   Set up OpenStack VMs to be part of the Kubernetes system.

```
sudo pacman -Syu terraform ansible # install Terraform and Ansible on Arch Linux
```

## Deployment

``` shell
git submodule init # Init kubespray
git submodule update # Clone kubespray
terraform apply # Set up openstack resources
cp -rfp kubespray/inventory/sample/* kubespray/inventory/$your-inventory-name # Create inventory for kubespray
ansible-playbook -i kubespray/inventory/hosts.ini -u ubuntu -b kubespray/cluster.ym # Deploy kubespray to OpenStack
```

## Trouble shooting
- Ingress nginx does not work after openstack VMs restarting

  It's caused by flannel and kube proxy. Restart the related pods will fix the issue, i.e. `kubectl -n kube-system delete pod -l k8s-app=flannel`. Replace flannel in the command with kube-proxy to restart kube-proxy.
