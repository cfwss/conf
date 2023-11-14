使用说明：

//不解锁流媒体(适用于落地鸡)

rm /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

wget https://raw.githubusercontent.com/cfwss/conf/main/agent/10_ipv4_outbounds.json

mv 10_ipv4_outbounds.json  /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force


rm /etc/v2ray-agent/xray/conf/09_routing.json --force

wget https://raw.githubusercontent.com/cfwss/conf/main/agent/09_routing.json

mv 09_routing.json   /etc/v2ray-agent/xray/conf/09_routing.json --force



把文件名替换成对应的即可

如果需要落地解锁，使用forward里面的config。
落地机解锁的10_ipv4_outbounds.json文件，内容需要修改成你的解锁机vmess+ws节点信息。包括域名、UUID、PATH等。
如果HK鸡，请使用forHK，通过落地鸡解锁chatGPT等。
