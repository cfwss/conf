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
        echo -n "请输入编号 $count 的TLS证书（$(basename "$cert")）对应的域名: "
        read domain_name
        echo "$count, $(basename "$cert"), $cert, $domain_name" >> $OUTPUT_FILE

        NEW_CONF="/etc/nginx/conf.d/${domain_name}.conf"

        if [ -f "$NEW_CONF" ]; then
            echo "配置文件 ${NEW_CONF} 已存在。是否覆盖？(y/n)"
            read overwrite

            if [ "$overwrite" != "y" ]; then
                echo "跳过 ${domain_name} 的配置文件更新。"
                continue
            else
                rm "$NEW_CONF"
            fi
        fi

        cp "$NGINX_CONF_TEMPLATE" "$NEW_CONF"
        sed -i "s/server_name .*/server_name $domain_name;/g" "$NEW_CONF"

        original_port=$(sed -n -r 's/listen 127.0.0.1:([0-9]+) .*/\1/p' "$NEW_CONF" | head -n 1)
        new_port=$((original_port + num))
        num=$((num + 10))
        sed -i -r "s/(listen 127.0.0.1:)[0-9]+ /\1$new_port /" "$NEW_CONF"

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

for conf_file in /etc/nginx/conf.d/*.conf; do
    if [ -f "$conf_file" ]; then
        sed -i '/server_name/ {s/server_name .*/server_name _;/; :a; n; ba}' "$conf_file"
    fi
done

sudo systemctl restart nginx