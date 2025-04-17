---
- name: Install Kubernetes and Docker on EC2 instances
  hosts: all
  become: yes
  tasks:
    - name: Update the apt package index
      apt:
        update_cache: yes

    - name: Install Docker
      apt:
        name: docker.io
        state: present

    - name: Add Kubernetes apt repository
      apt_repository:
        repo: "deb https://apt.kubernetes.io/ kubernetes-xenial main"
        state: present

    - name: Install Kubernetes packages
      apt:
        name:
          - kubelet
          - kubeadm
          - kubectl
        state: present

    - name: Disable swap
      command: swapoff -a

    - name: Initialize Kubernetes Cluster
      command: kubeadm init --pod-network-cidr=10.244.0.0/16
      when: inventory_hostname == groups['k8s_master'][0]

    - name: Set up kubeconfig for root user
      command: "{{ item }}"
      with_items:
        - "mkdir -p $HOME/.kube"
        - "cp -i /etc/kubernetes/admin.conf $HOME/.kube/config"
        - "chown $(id -u):$(id -g) $HOME/.kube/config"

    - name: Install Flannel CNI
      command: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

    - name: Join worker nodes to the cluster
      command: "{{ hostvars[groups['k8s_master'][0]]['kubeadm_join_command'] }}"
      when: inventory_hostname != groups['k8s_master'][0]
