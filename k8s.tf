# Create a single master node and floating IP
resource "openstack_compute_instance_v2" "k8s-master" {
  name = "k8s-master"
  image_name = "${var.image-name}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]

  network {
    name = "${var.network-name}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "k8s-master-ip" {
  floating_ip = "${openstack_networking_floatingip_v2.k8s-master-ip.address}"
  instance_id = "${openstack_compute_instance_v2.k8s-master.id}"
  fixed_ip = "${openstack_compute_instance_v2.k8s-master.network.0.fixed_ip_v4}"
}

resource "openstack_networking_floatingip_v2" "k8s-master-ip" {
  pool = "${var.floating-ip-pool}"
}

# Create desired number of k8s nodes
resource "openstack_compute_instance_v2" "k8s-node" {
  count = "${var.node-count}"
  name = "k8s-node-${count.index}"
  image_name = "${var.image-name}"
  flavor_name = "${var.image-flavor}"
  key_pair = "${var.key-pair}"
  security_groups = ["${split(",", var.security-groups)}"]

  network {
    name = "${var.network-name}"
  }
}

resource "local_file" "test" {
  filename="${path.module}/${var.inventory-path}/hosts.ini"
  content = <<EOF
bastion ansible_host=142.1.177.99 ansible_user=ubuntu

${openstack_compute_instance_v2.k8s-master.name} ansible_host=${openstack_compute_instance_v2.k8s-master.network.0.fixed_ip_v4}

[kube-master]
${openstack_compute_instance_v2.k8s-master.name}

[etcd]
${openstack_compute_instance_v2.k8s-master.name}

[kube-node]
${join("\n",formatlist("%s ansible_host=%s", openstack_compute_instance_v2.k8s-node.*.name, openstack_compute_instance_v2.k8s-node.*.network.0.fixed_ip_v4))}

[k8s-cluster:children]
kube-node
kube-master
EOF
}
