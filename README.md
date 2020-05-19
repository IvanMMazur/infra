
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

## HW7. Infrastructure management models.

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

## HW8. Infrastructure as a Code (IaC).

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