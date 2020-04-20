
Infra repository
# HW5. Introduction in GCP

IP addresses of virtual machines:

``` text
<10.128.0.2 - someinternalhost_ip>
<10.128.0.3 - bastion_internal_ip>
<35.239.44.197 - bastion_ip>
```
Connectiong to the bastion using SSH Agent Forwarding

way to connect to sominternal in one command from your 
``` bash
    localhost: ssh -i ~/.ssh/ivanmazur -A ivanmazur@35.239.44.197 ssh 10.128.0.2
alias from .bashrc
    echo "alias someinternalhost=\"ssh -i~/.ssh/ivanmazur -A ivanmazur@
        35.239.44.197 ssh ivanmazur@10.128.0.2\"">> ~/.bashrc
    source ~/.bashrc
```
Using aliases in ~/.ssh/config I DONT UNDERSTAND
``` text
# for bastion
Host otus-bastion
    Hostname 35.239.44.197
    User ivanmazur
    ForwardAgent yes

Host internal
    Hostname 10.128.0.2
    ProxyJump ivanmazur@35.239.44.197
    User ivanmazur
```
Check the work command
``` bash
ssh bastion
ssh 10.128.0.2
ssh internal
```

If you do not have a domain
- http://xip.io/ - normal
- https://sslip.io/faq.html - has wildcard certificate

Port_pritunl: 18195/udp

Checked the connection to the vpn server

I made sure that it is possible to connect someinternalhost via int.IP
``` bash
    ssh -i ~/.ssh/ivanmazur ivanmazur@10.128.0.2
```

Add cetrtificates letsencrypt

# HW6. Main services GCP

Installation GCP according to the instructions
- https://cloud.google.com/sdk/docs/

Quick launch of a ready-made instance with the PUMA service from express42 / reddit using a [startup script](https://cloud.google.com/compute/docs/startupscript):
``` bash
$ gcloud compute instances create reddit-pp-autofile \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --zone=us-central1-a \
    --restart-on-failure \
    --metadata-from-file startup-script=startup_script.sh
```

Using URL instead of local file
``` bash
$ gcloud compute instances create reddit-app-autourl \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --zone=us-central1-a \
    --restart-on-failure \
    --metadata=startup-script-url=https://drive.google.com/open?id=10poex4HuOAKy6gO6-Ve9r4cLd5utNtWe
```

Creating a firewall rule for the application
``` bash
$ gcloud compute firewall-rules create default-puma-server\
    --network default \
    --priority 1000 \
    --direction ingress \
    --action allow \
    --target-tags puma-server \
    --source-ranges 0.0.0.0/0 \
    --rules TCP:9292
```

``` text
testapp_IP = 34.66.131.215

testapp_port = 9292
```
