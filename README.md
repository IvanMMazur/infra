# express42-test_infra
express42-test Infra repository
10.128.0.2 - someinternalhost_ip
35.239.44.197 - bastion_ip
way to connect to sominternal in one command from your 
    localhost: ssh -i ~/.ssh/ivanmazur -A ivanmazur@35.239.44.197 ssh 10.128.0.2
alias from .bashrc
    echo "alias someinternalhost=\"ssh -i~/.ssh/ivanmazur -A ivanmazur@
        35.239.44.197 ssh ivanmazur@10.128.0.2\"">> ~/.bashrc
    source ~/.bashrc
Port_pritunl: 18195/udp
Checked the connection to the vpn server
I made sure that it is possible to connect someinternalhost via int.IP
    ssh -i ~/.ssh/ivanmazur ivanmazur@10.128.0.2
add cetrtificates letsencrypt