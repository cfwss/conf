#!/bin/bash


count=0

OUTPUT_FILE="/tmp/tls_certificates_info.txt"
echo "TLS证书信息：" > $OUTPUT_FILE
echo "数量, 名称, 路径, 域名" >> $OUTPUT_FILE

JSON_FILE="/etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json"
CERT_DIR="/etc/tls"
num=10
for cert in "$CERT_DIR"/*.crt; do
 

        jq --argjson newEntry "$new_entry" '.inbounds[0].streamSettings.tlsSettings.certificates += [$newEntry]' "$JSON_FILE" > temp.json && mv temp.json "$JSON_FILE"

done



sudo systemctl restart nginx
