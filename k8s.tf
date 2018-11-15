# Create a single master node and floating IP
resource "openstack_compute_instance_v2" "k8s-master" {
  count           = "${var.master_count}"
  name            = "k8s-master-${count.index}"
  image_id        = "${var.image_id}"
  flavor_name     = "${var.image_flavor}"
  key_pair        = "${var.key_pair}"
  security_groups = ["${split(",", var.security_groups)}"]

  network {
    name = "${var.network_name}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "k8s-master-ip" {
  count       = "${var.master_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.k8s-master-ip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.k8s-master.*.id, count.index)}"
}

resource "openstack_networking_floatingip_v2" "k8s-master-ip" {
  count = "${var.master_count}"
  pool  = "${var.floating_ip_pool}"
}

# Create desired number of k8s nodes
resource "openstack_compute_instance_v2" "k8s-node" {
  count           = "${var.node_count}"
  name            = "k8s-node-${count.index}"
  image_id        = "${var.image_id}"
  flavor_name     = "${var.image_flavor}"
  key_pair        = "${var.key_pair}"
  security_groups = ["${split(",", var.security_groups)}"]

  network {name = "${var.network_name}"
  }
}

resource "local_file" "test" {
  filename = "${path.module}/${var.inventory_path}/hosts.ini"

  content = <<EOF
bastion ansible_host=142.1.177.99 ansible_user=ubuntu

${join("\n",formatlist("%s ansible_host=%s", openstack_compute_instance_v2.k8s-master.*.name, openstack_compute_instance_v2.k8s-master.*.network.0.fixed_ip_v4))}

[kube-master]
${join("\n",formatlist("%s", openstack_compute_instance_v2.k8s-master.*.name))}

[etcd]
${join("\n",formatlist("%s", openstack_compute_instance_v2.k8s-master.*.name))}
${element(openstack_compute_instance_v2.k8s-node.*.name, 0)}

[kube-node]
${join("\n",formatlist("%s ansible_host=%s", openstack_compute_instance_v2.k8s-node.*.name, openstack_compute_instance_v2.k8s-node.*.network.0.fixed_ip_v4))}

[k8s-cluster:children]
kube-node
kube-master
EOF
}
