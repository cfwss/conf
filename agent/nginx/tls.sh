#!/bin/bash

CERT_DIR="/etc/tls"
NGINX_CONF_TEMPLATE="/etc/nginx/conf.d/alone.conf"

if [ ! -d "$CERT_DIR" ]; then
    echo "目录不存在: $CERT_DIR"
    exit 1
fi

if [ ! -f "$NGINX_CONF_TEMPLATE" ]; then
    echo "Nginx配置模板不存在: $NGINX_CONF_TEMPLATE"
    exit 1
fi

count=0

OUTPUT_FILE="/tmp/tls_certificates_info.txt"
echo "TLS证书信息：" > $OUTPUT_FILE
echo "数量, 名称, 路径, 域名" >> $OUTPUT_FILE

JSON_FILE="/etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json"
CERT_DIR="/etc/tls"
num=10
for cert in "$CERT_DIR"/*.crt; do
    if [ -f "$cert" ]; then
        let count=count+1


        cert_base_name=$(basename "$cert" .crt)
        new_entry=$(jq -n --arg certFile "$CERT_DIR/$cert_base_name.crt" \
                          --arg keyFile "$CERT_DIR/$cert_base_name.key" \
                          '{
                              "certificateFile": $certFile,
                              "keyFile": $keyFile,
                              "ocspStapling": 3600,
                              "usage": "encipherment"
                            }')

        jq --argjson newEntry "$new_entry" '.inbounds[0].streamSettings.tlsSettings.certificates += [$newEntry]' "$JSON_FILE" > temp.json && mv temp.json "$JSON_FILE"
    fi
done

echo "检测到 $count 个TLS证书。"
echo "详细信息已保存到 $OUTPUT_FILE"



cat /etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json

