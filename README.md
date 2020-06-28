
Infra repository
# 5. Introduction in GCP

IP addresses of virtual machines:

``` text
someinternalhost_ip>
bastion_internal_ip>
bastion_ip>
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

# 6. Main services GCP

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

## 7. Infrastructure management models.

Setting Application Default Credentials(ADC)
``` text
gcloud auth application-default login
```

Create an image with ruby and mongo, and the application is deployed via startup-script, for the VM to work continously, replace 'premptible' with 'restart-on-failure'
- packer/imutable.sh

To transfer the file to the server use the utility
``` text
- scp /opt/file.file root@11.22.33.44:/home/user
```

Start instance from the baked image
- config-sh/create-puma-vm.sh

## 8. Infrastructure as a Code (IaC).

- Note: git is already installed in standard Ubuntu images.
- Renoved ivanmazur SSH key from Compute Engine - Metadata - SSH keys
- Installed Terraform 0.11.11
- Added **terraform-related** exceptions to **.gitignore**
- **main.tf** added description of GCP provider
- Initialized Terraform modules `cd terraform && terraform init`
- **google_compute_instance** resource added for **main.tf** to create vm in GCP
- Validation of planned changes of `terraform plan`
- Applied planned changes to `terraform apply`
- Obtained th IP address of the instance from the tfstate file `terraform show | grep nat_ip`
- An attempt was made to connect to the instance via SSH `ssh ivanmazur@1.1.1.1`, connection failed
- In **main.tf**, the metadata section containing the path to the public key has been added to the resource description

<details>
    <summary>ssh metadata</summary>

```bash
metadata {
    ssh-keys = "ivanmazur:${file("~/.ssh/ivanmazur.pub")}"
}
```

</details>

- Changes checked and applied to the instance of `terraform plan && terraform apply -auto-approve`
- Checked connection to the instance via SSH, the connection was successful
- Added file of output variables **outputs.tf**
- Added output variable app_external_ip `google_compute_instance.app.network_interface.0.access_config.0.nat_ip`
- The value of the variable is obtained after executing `terraform refresh` and `terraform output`
- Added desctiption of google_compute_firewall resource creating a rule that allows access to port 9292
- Changes applied, created rule for firewall in GCP
- Added tag `tags = ["reddit-app"]` for instance **google_compute_instance.app**

### Provisioners

- For resource **google_compute_instance.app** added provisioner of type file, which will copy the file from the local machine to the created instance

<details>
    <summary>file provisioner</summary>

```ruby
provisioner "file" {
    source = "files/puma.service"
    destination = "/tmp/puma.service"
}
```

</details>

- For resource **google_compute_instance.app** added provisioner of type remote_exec, which will run bash-script on the created instance

<details>
    <summary>remote_exec provisioner</summary>

```ruby
provisioner "remote-exec" {
    script = "file/deploy.sh"
}
```

</details>

- Inside the resource description **google_compute_instance.app** added section connection, which determines the connection parameters to the instance for launching provisioning

<details>
    <summary>provisioner connection</summary>

```ruby
  connection {
    type  = "ssh"
    user  = "ivanmazur"
    agent = false

    # Private key path
    private_key = "${file(var.private_key_path)}"
  }
```


</details>

- Because Provisionaries are launched only when a new resource is created (or when deleted), then, to execute provisioning sections, the resource **google_compute_instance.app** is marked for re-creation when the following changes are applied: `terraform taint google_compute_instance.app`
- After applying the changes, you can make sure that the reddit application is available at <http://your-vm-ip:9292>

### Input Vars

- Added file under input vars - **variables.tf**
- Added variables to the terraform variables file: project, region, public_key_path, disk_image
- In the file **main.tf** the values of the parameters project, region, public_key_path. disk_image changed to variables
- The values of variables that do not have a default value are defined in the **terraform.tfvars** file
- The infrastructure was recreated by executing the commands `terrafrm destroy -auto-approve && terraform plan && terraform apply -auto-approve`
- After re-creating the application, it is available at <http://your-vm-ip:9292>


## 9. The principles of organization of infrastructure code and work on infrastructure in a team using the example of Terraform

- In **main.tf** added **google_compute_firewall.firewall_ssh** to create an access rule on port 22
- An error occured while trying to execute `terraform apply` since a rule with such parameters already exists in GCP
- Existion rule information **default-allow-ssh** added to state terraform `terraform import google_compute_firewall.firewall_ssh default-allow-ssh`
- In **main.tf** added resource **google_compute_address.app_ip**
- For the created application instance, ip_address is defined as a link to the created resource `nat_ip ="${google_comopute_address.app_ip.address}"`

### Resource structuring

- Using Packer prepared **reddit-app-base** and **reddit-db-base** images
- Created new **add.tf** files with a description of resources for an instance with an application and **db.tf** with a description of resources for an instance with MongoDB
- Created **vpc.tf** with description of resources appplicable for all instances
- Changes planned and successfully applied

### Modules

- Based on **app.tf**, **db.tf** created Terraform modules
- Added sections for calling app and db modules to **main.tf**
- Modules loaded into Terraform cache (.terraform) `terraform get`
- In **terraform/outputs.tf** the output app_external_ip has been changed to a variable obtained from the app module `value="${module.app.app_external_ip}"`

## 10 - Configuration management. Basic DevOps tools. Introducing Ansible

- Installed Ansible

<details>
    <summary>ansible --version</summary>

```bash
ansible 2.9.10
  config file = /home/ivanmazur/CICD/infra/ansible/ansible.cfg
  configured module search path = [u'/home/ivanmazur/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /home/ivanmazur/.local/lib/python2.7/site-packages/ansible
  executable location = /home/ivanmazur/.local/bin/ansible
  python version = 2.7.16 (default, Oct 10 2019, 22:02:15) [GCC 8.3.0]
```

</details>

- Stage infrastructure deployed bia Terraform
- Created inventory **ansible/inventory** with a description of the appserver machine
- Checked the ability to connect ansible to the appserver host

<details>
    <summary> ansible appserver -m ping -i inventory</summary>

```bash
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```
</detaile>

- The dbserver host has been added to ansible/inventory, the ability to connect Ansible to the dbserver host `ansible dbserver -m ping -i inventory` has been verified
- Configured ansible.cfg
- Receined data about uptime of the database server `ansible dbserver -m command -a uptime`
- In the inventory added host groups app and db
- Added yaml-inventory, checked abailability of hosts in groups
- The operation of shell and command modules was investigated
- Investigated the operation of systemd and service modules
- Investigated the operation of the git module in comparison with the command module
- Added clone.yml playbook
- Result of the launch

<details>
    <summary>ansible-playbook clone.yml</summary>

```bash
PLAY [Clone] ***************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [appserver]

TASK [Clone repo] **********************************************************************
changed: [appserver]

PLAY RECAP *****************************************************************************
appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
</details>