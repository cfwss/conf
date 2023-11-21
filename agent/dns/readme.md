    rm /etc/v2ray-agent/xray/conf/11_dns.json --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/dns/11_dns.json
    mv 11_dns.json  /etc/v2ray-agent/xray/conf/11_dns.json --force
