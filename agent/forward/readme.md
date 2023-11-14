使用说明：

//不解锁流媒体(适用于落地鸡)

rm /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

wget https://raw.githubusercontent.com/cfwss/conf/main/agent/forward/10_ipv4_outbounds.json

mv 10_ipv4_outbounds.json /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

rm /etc/v2ray-agent/xray/conf/09_routing.json --force

wget https://raw.githubusercontent.com/cfwss/conf/main/agent/forward/09_routing.json

mv 09_routing.json /etc/v2ray-agent/xray/conf/09_routing.json --force

把文件名替换成对应的即可，落地机解锁的10_ipv4_outbounds.json文件，内容需要修改成你的解锁机vmess+ws节点信息。包括域名、UUID、PATH等。
