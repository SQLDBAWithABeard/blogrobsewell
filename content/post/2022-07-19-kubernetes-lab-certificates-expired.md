---
title: "Kubernetes lab certificates expired"
date: "2022-07-19" 
categories:
  - Blog
  - Kubernetes

tags:
 - Blog
 - Community
 - Automation
 - YAML
 - docker
 - containers
 - kubernetes
 - NUC
 - certificates
 - kubelet


image: https://images.unsplash.com/photo-1494412651409-8963ce7935a7?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80
---

# It won't start!

I have a 3 node kubernetes cluster running in my office that I have used for my [Azure Arc-enabled data services](https://azure.microsoft.com/en-gb/services/azure-arc/hybrid-data-services?WT.mc_id=DP-MVP-5002693) presentations over the last year ([Side note, my presentations are here](beard.media/presentations)). A few days ago after a power cut I tried to connect to my cluster with [Lens](https://k8slens.dev/) and was not able to.

I tried to run `kubectl get nodes` but got no response.

## Try on the master node

I used my windows terminal profile that ssh's into the master node and ran  

`systemctl status kubelet`

this resulted in

>rob@beardlinux:~$ systemctl status kubelet  
● kubelet.service - kubelet: The Kubernetes Node Agent  
     Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)  
    Drop-In: /etc/systemd/system/kubelet.service.d  
             └─10-kubeadm.conf  
     Active: active (running) since Thu 2022-07-07 09:29:00 BST; 8min ago  
       Docs: https://kubernetes.io/docs/home/ 
   Main PID: 1201 (kubelet)  
      Tasks: 15 (limit: 38316)  
     Memory: 120.3M  
     CGroup: /system.slice/kubelet.service  
             └─1201 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kub>  
Jul 07 19:37:47 beardlinux kubelet[1201]: E0707 09:37:47.318044    1201 kubelet.go:2243] node "beardlinux" not found 
Jul 07 19:37:47 beardlinux kubelet[1201]: E0707 09:37:47.418240    1201 kubelet.go:2243] node "beardlinux" not found  

## How many logs?

So beardlinux is the master node that we are running on so why can it not be found?  

`journalctl -u kubelet -n 50`  

that will show me, i thought. It showed

>jrob@beardlinux:~$ journalctl -u kubelet -n 50  
-- Logs begin at Thu 2022-06-16 14:26:08 BST, end at Thu 2022-07-07 19:38:55 BST. --  
Jul 07 19:38:50 beardlinux kubelet[1201]: E0707 19:38:50.710347    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:50 beardlinux kubelet[1201]: E0707 19:38:50.810556    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:50 beardlinux kubelet[1201]: E0707 19:38:50.910804    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.011102    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.111501    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.211840    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.312180    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.412460    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.512751    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.612983    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.713231    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.813398    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:51 beardlinux kubelet[1201]: E0707 19:38:51.913647    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.013891    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.114153    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.214312    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.314439    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.414546    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.514875    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.615009    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.715310    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.815683    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:52 beardlinux kubelet[1201]: E0707 19:38:52.915917    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:53 beardlinux kubelet[1201]: E0707 19:38:53.016190    1201 kubelet.go:2243] node "beardlinux" not found  
Jul 07 19:38:53 beardlinux kubelet[1201]: E0707 19:38:53.116399    1201 kubelet.go:2243] node "beardlinux" not found  

Ah :-(

so after some investigation I found

> Jul 06 08:03:09 beardlinux kubelet[1021]: I0706 08:03:09.755007    1021 kubelet_node_status.go:71] Attempting to register node beardlinux  
Jul 06 08:03:09 beardlinux kubelet[1021]: E0706 08:03:09.755338    1021 kubelet_node_status.go:93] Unable to register node "beardlinux" with API server: Post "https://192.168.2.62:6443/api/v1/nodes": dial tcp 192.168.2.62:6443: connect: connection refused  

which lead me to an issue on GitHub where there was a [comment](https://github.com/kubernetes/kubeadm/issues/1026#issuecomment-768832968) to check for expired certificates

## Do I have expired certificates?

You can check your certificates using 

`kubeadm certs check-expiration`

which resulted in  

![expired-certs](/assets/uploads/2022/07/expired-certs.png)

## And renewing them

They are renewed using `kubeadm certs renew all`

>root@beardlinux:/home/rob# kubeadm certs renew all  
[renew] Reading configuration from the cluster...  
[renew] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'  
[renew] Error reading configuration from the Cluster. Falling back to default configuration  
>
>certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself renewed  
certificate for serving the Kubernetes API renewed  
certificate the apiserver uses to access etcd renewed  
certificate for the API server to connect to kubelet renewed  
certificate embedded in the kubeconfig file for the controller manager to use renewed  
certificate for liveness probes to healthcheck etcd renewed  
certificate for etcd nodes to communicate with each other renewed  
certificate for serving etcd renewed  
certificate for the front proxy client renewed  
certificate embedded in the kubeconfig file for the scheduler manager to use renewed  
>
>Done renewing certificates. You must restart the kube-apiserver, kube-controller-manager, kube-scheduler and etcd, so that they can use the new certificates.

stopped and started the kubelet

> root@beardlinux:/home/rob# systemctl stop kubelet
> root@beardlinux:/home/rob# systemctl start kubelet

and checked the nodes

> pwsh 7.2.5> kubectl get nodes   
NAME          STATUS     ROLES                  AGE    VERSION   
beardlinux    Ready      control-plane,master   376d   v1.20.2   
beardlinux2   Ready      <none>                 376d   v1.20.2   
beardlinux3   Ready      <none>                 376d   v1.20.2   

I also had to update my config with the new certificate data to make that work as well.
