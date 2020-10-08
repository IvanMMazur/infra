## test_infra
Infra repository
10.132.15.193 - someinternalhost_ip
34.78.92.29 - bastion_ip
- way to connect to sominternal in one command from your 
    localhost: ssh -J  appuser@34.78.92.29 appuser@10.132.15.193
- alias from .bashrc
    echo "alias someinternalhost=\"ssh -i~/.ssh/ivanmazur -A ivanmazur@
        34.78.92.29 ssh ivanmazur@10.132.15.193\"">> ~/.bashrc
    source ~/.bashrc
    add to ~/.ssh/config
- Port_pritunl: 10000/udp
- Checked the connection to the vpn server
- I made sure that it is possible to connect someinternalhost via int.IP
    ssh -i ~/.ssh/ivanmazur ivanmazur@10.132.15.193

### Configuring Pritunl VPN

- Added rules for **bastion** allowing HTTP/HTTPS
- Created setupvpn.sh script

<details>
  <summary>setupvpn.sh</summary>##

```bash
cat <<EOF> setupvpn.sh
#!/bin/bash
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.4.list
echo "deb http://repo.pritunl.com/stable/apt xenial main" > /etc/apt/sources.list.d/pritunl.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 0C49F3730359A14518585931BC711F9BA15703C6
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
apt-get --assume-yes update
apt-get --assume-yes upgrade
apt-get --assume-yes install pritunl mongodb-org
systemctl start pritunl mongod
systemctl enable pritunl mongod
EOF
```

</details>

- Completed installation of MongoDB and Pritunl 'sudo bash setupvpn.sh'
- Created rule vpn-10000 allowing connections from 0.0.0.0/0 to UDP 10000
- Added setupcertbot.sh script

<details>
  <summary>setupcertbot.sh</summary>

```bash
cat <<EOF> setupcertbot.sh
#!/bin/bash
apt-get update
apt-get install software-properties-common -y
add-apt-repository universe -y
add-apt-repository ppa:certbot/certbot -y
apt-get update
apt-get install certbot -y
EOF
```

</details>

- Install certbot 'sudo bash setupcertbot.sh'
- Create a certificate 'sudo certbot certonly' using address: ***.sslip.io
- Through the web interface, in the servr setting, specified Let Encrypt Domain - ***.sslip.io