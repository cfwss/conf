默认服务器
AdGuard DNS 拦截广告和跟踪器。

    rm /etc/v2ray-agent/xray/conf/11_dns.json --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/dns/11_dns.json
    mv 11_dns.json  /etc/v2ray-agent/xray/conf/11_dns.json --force

家庭保护服务器
AdGuard DNS 拦截广告、跟踪器、成人内容，并在可能的情况下启用安全搜索和安全模式。

    rm /etc/v2ray-agent/xray/conf/11_dns.json --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/dns/family.json
    mv family.json  /etc/v2ray-agent/xray/conf/11_dns.json --force


无过滤服务器
AdGuard DNS 不拦截广告、跟踪器或其他任何 DNS 请求。

    rm /etc/v2ray-agent/xray/conf/11_dns.json --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/dns/unfiltered.json
    mv unfiltered.json  /etc/v2ray-agent/xray/conf/11_dns.json --force
