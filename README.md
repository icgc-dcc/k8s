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

## Authors

* **Xu Deng** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* George Mihaiescu for the early Kubernetes work.
