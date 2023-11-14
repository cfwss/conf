//FOR HK 通过落地鸡分流（vmess+ws)

rm /etc/v2ray-agent/xray/conf/09_routing.json --force

wget https://raw.githubusercontent.com/cfwss/conf/main/agent/forHK/09_routing.json

mv 09_routing.json   /etc/v2ray-agent/xray/conf/09_routing.json --force


//FOR HK 通过落地鸡分流（vmess+ws)
