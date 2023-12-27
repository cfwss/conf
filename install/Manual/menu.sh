#!/bin/bash

declare -a new_uuid_array
declare -a old_uuid_array
apt install wget  > /dev/null 2>&1
generate_new_uuids() {
    new_uuid_array=()
    old_uuid_array=()
    read -p "请输入要生成新和旧的UUID数量: " count
    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        old_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
        old_uuid_array+=("$old_uuid")
        echo "生成的新UUID $i: $new_uuid，旧UUID $i: $old_uuid"
    done
    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    elif [ "$count" -ne 0 ]; then
            process_info
    fi

}

generate_new_uuid_with_manual_old() {
    new_uuid_array=()
    old_uuid_array=()

    read -p "请输入要生成新的UUID数量: " count

    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    fi

    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
    done

    echo -e "请输入UUID，每行一个，以空行结束："
    while read -r uuid_manual && [ -n "$uuid_manual" ]; do
        old_uuid_array+=("$uuid_manual")
    done

    echo -e "\n生成的新UUID："
    printf "%s\n" "${new_uuid_array[@]}"

    echo -e "\n输入的旧UUID："
    printf "%s\n" "${old_uuid_array[@]}"

    process_info
}

manual_input_uuids() {
    new_uuid_array=()
    old_uuid_array=()
    echo "请输入新的UUID，以空行结束"
    while read -r uuid && [ -n "$uuid" ]; do
        new_uuid_array+=("$uuid")
    done
    echo -e "\n输入的新UUID："
    printf "%s\n" "${new_uuid_array[@]}"
    echo "请输入旧的UUID，以空行结束"
    while read -r uuid && [ -n "$uuid" ]; do
        old_uuid_array+=("$uuid")
    done
    echo -e "\n输入的旧UUID："
    printf "%s\n" "${old_uuid_array[@]}"
    process_info
}

process_info() {
    full_uuid_array=()
    short_uuid_array=()
    base64_uuid_array=()
    old_full_uuid_array=()
    old_short_uuid_array=()
    old_base64_uuid_array=()
    method_character="chacha20-ietf-poly1305"
    old_method_character="chacha20-ietf-poly1305"
    
    for ((i=0; i<${#new_uuid_array[@]}; i++)); do
        full_uuid=${new_uuid_array[i]}
        short_uuid="${full_uuid:0:8}"
        full_uuid_array+=("$full_uuid")
        short_uuid_array+=("$short_uuid")
        base64_uuid=$(echo -n "$full_uuid" | base64 | tr -d '/+' | cut -c 1-22)
        base64_uuid+="=="
        base64_uuid_array+=("$base64_uuid")
    done
    
    for ((i=0; i<${#old_uuid_array[@]}; i++)); do
        old_full_uuid=${old_uuid_array[i]}
        old_short_uuid="${old_full_uuid:0:8}"
        old_full_uuid_array+=("$old_full_uuid")
        old_short_uuid_array+=("$old_short_uuid")
        old_base64_uuid=$(echo -n "$old_full_uuid" | base64 | tr -d '/+' | cut -c 1-22)
        old_base64_uuid+="=="
        old_base64_uuid_array+=("$old_base64_uuid")
    done
    
    vless_tcp_xtls=()  vless_tcp=() vmess_tcp=() trojan_tcp=() shadowsocks_tcp=() vless_ws=() vmess_ws=() trojan_ws=() shadowsocks_ws=() vless_gRPC=() vmess_gRPC=() trojan_gRPC=() shadowsocks_gRPC=() vless_OLD=() vmess_OLD=() trojan_OLD=() shadowsocks_OLD=()
    json_template_vless_tcp_xtls='{"id":"full_uuid","flow":"xtls-rprx-vision","email":"short_uuid-VLESS_TCP/TLS_Vision","level":0}'
    json_template_vless_tcp='{"id":"full_uuid","email":"short_uuid-VLess_TCP","level":0}'
    json_template_vmess_tcp='{"id":"full_uuid","email":"short_uuid-VMess_TCP","level":0}'
    json_template_trojan_tcp='{"password":"full_uuid","email":"short_uuid-Trojan_TCP","level":0}'
    json_template_shadowsocks_tcp='{"method":"method_character","password":"base64_uuid","level":0}'
    
    for ((i=0; i<${#full_uuid_array[@]}; i++)); do
        vless_tcp_xtls+=("$(echo "$json_template_vless_tcp_xtls" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        vless_tcp+=("$(echo "$json_template_vless_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        vmess_tcp+=("$(echo "$json_template_vmess_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        trojan_tcp+=("$(echo "$json_template_trojan_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        shadowsocks_tcp+=("$(echo "$json_template_shadowsocks_tcp" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid_array[i]}/"),")
        vless_ws+=("$(echo "$json_template_vless_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/VLess_TCP/VLess_WS/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        vmess_ws+=("$(echo "$json_template_vmess_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/VMess_TCP/VMess_WS/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        trojan_ws+=("$(echo "$json_template_trojan_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/Trojan_TCP/VMess_WS/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        shadowsocks_ws+=("$(echo "$json_template_shadowsocks_tcp" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid_array[i]}/"),")
        vless_gRPC+=("$(echo "$json_template_vless_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/VLess_TCP/VLess_gRPC/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        vmess_gRPC+=("$(echo "$json_template_vmess_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/VMess_TCP/VMess_gRPC/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        trojan_gRPC+=("$(echo "$json_template_trojan_tcp" | sed -e "s/full_uuid/${full_uuid_array[i]}/" -e "s/Trojan_TCP/Trojan_gRPC/" -e "s/short_uuid/${short_uuid_array[i]}/"),")
        shadowsocks_gRPC+=("$(echo "$json_template_shadowsocks_tcp" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid_array[i]}/"),")
    done
    
    for ((i=0; i<${#old_full_uuid_array[@]}; i++)); do
        vless_OLD+=("$(echo "$json_template_vless_tcp" | sed -e "s/full_uuid/${old_full_uuid_array[i]}/" -e "s/VLess_TCP/VLess_OLD/" -e "s/short_uuid/${old_short_uuid_array[i]}/"),")
        vmess_OLD+=("$(echo "$json_template_vmess_tcp" | sed -e "s/full_uuid/${old_full_uuid_array[i]}/" -e "s/VMess_TCP/VMess_OLD/" -e "s/short_uuid/${old_short_uuid_array[i]}/"),")
        trojan_OLD+=("$(echo "$json_template_trojan_tcp" | sed -e "s/full_uuid/${old_full_uuid_array[i]}/" -e "s/Trojan_TCP/VMess_OLD/" -e "s/short_uuid/${old_short_uuid_array[i]}/"),")
        shadowsocks_OLD+=("$(echo "$json_template_shadowsocks_tcp" | sed -e "s/method_character/$old_method_character/" -e "s/base64_uuid/${old_base64_uuid_array[i]}/"),")
    done
    
    vless_tcp_xtls[${#vless_tcp_xtls[@]}-1]="${vless_tcp_xtls[${#vless_tcp_xtls[@]}-1]%,}"
    vless_tcp[${#vless_tcp[@]}-1]="${vless_tcp[${#vless_tcp[@]}-1]%,}"
    vmess_tcp[${#vmess_tcp[@]}-1]="${vmess_tcp[${#vmess_tcp[@]}-1]%,}"
    trojan_tcp[${#trojan_tcp[@]}-1]="${trojan_tcp[${#trojan_tcp[@]}-1]%,}"
    shadowsocks_tcp[${#shadowsocks_tcp[@]}-1]="${shadowsocks_tcp[${#shadowsocks_tcp[@]}-1]%,}"
    vless_ws[${#vless_ws[@]}-1]="${vless_ws[${#vless_ws[@]}-1]%,}"
    vmess_ws[${#vmess_ws[@]}-1]="${vmess_ws[${#vmess_ws[@]}-1]%,}"
    trojan_ws[${#trojan_ws[@]}-1]="${trojan_ws[${#trojan_ws[@]}-1]%,}"
    shadowsocks_ws[${#shadowsocks_ws[@]}-1]="${shadowsocks_ws[${#shadowsocks_ws[@]}-1]%,}"
    vless_gRPC[${#vless_gRPC[@]}-1]="${vless_gRPC[${#vless_gRPC[@]}-1]%,}"
    vmess_gRPC[${#vmess_gRPC[@]}-1]="${vmess_gRPC[${#vmess_gRPC[@]}-1]%,}"
    trojan_gRPC[${#trojan_gRPC[@]}-1]="${trojan_gRPC[${#trojan_gRPC[@]}-1]%,}"
    shadowsocks_gRPC[${#shadowsocks_gRPC[@]}-1]="${shadowsocks_gRPC[${#shadowsocks_gRPC[@]}-1]%,}"
    vless_OLD[${#vless_OLD[@]}-1]="${vless_OLD[${#vless_OLD[@]}-1]%,}"
    vmess_OLD[${#vmess_OLD[@]}-1]="${vmess_OLD[${#vmess_OLD[@]}-1]%,}"
    trojan_OLD[${#trojan_OLD[@]}-1]="${trojan_OLD[${#trojan_OLD[@]}-1]%,}"
    shadowsocks_OLD[${#shadowsocks_OLD[@]}-1]="${shadowsocks_OLD[${#shadowsocks_OLD[@]}-1]%,}"
    
    {
        echo -e "\n====数据收集完毕，以下为格式化输出内容====\n"
        echo -e "\nVLess_TCP:\n        \"clients\": ["; printf '          %s\n' "${vless_tcp[@]}"; echo "         ],"
        echo -e "\nVMess_TCP:\n        \"clients\": ["; printf '          %s\n' "${vmess_tcp[@]}"; echo "         ],"
        echo -e "\nTrojan_TCP:\n        \"clients\": ["; printf '          %s\n' "${trojan_tcp[@]}"; echo "         ],"
        echo -e "\nSShadowSSocks_TCP:\n        \"clients\": ["; printf '          %s\n' "${shadowsocks_tcp[@]}"; echo "         ],"
        
        echo -e "\nVLess_WS:\n        \"clients\": ["; printf '          %s\n' "${vless_ws[@]}"; echo "         ],"
        echo -e "\nVMess_WS:\n        \"clients\": ["; printf '          %s\n' "${vmess_ws[@]}"; echo "         ],"
        echo -e "\nTrojan_WS:\n        \"clients\": ["; printf '          %s\n' "${trojan_ws[@]}"; echo "         ],"
        echo -e "\nSShadowSSocks_WS:\n        \"clients\": ["; printf '          %s\n' "${shadowsocks_ws[@]}"; echo "         ],"
        
        echo -e "\nVLess_gRPC:\n        \"clients\": ["; printf '          %s\n' "${vless_gRPC[@]}"; echo "         ],"
        echo -e "\nVMess_gRPC:\n        \"clients\": ["; printf '          %s\n' "${vmess_gRPC[@]}"; echo "         ],"
        echo -e "\nTrojan_gRPC:\n        \"clients\": ["; printf '          %s\n' "${trojan_gRPC[@]}"; echo "         ],"
        echo -e "\nSShadowSSocks_gRPC:\n        \"clients\": ["; printf '          %s\n' "${shadowsocks_gRPC[@]}"; echo "         ],"
        
        echo -e "\nVLess_OLD:\n        \"clients\": ["; printf '          %s\n' "${vless_OLD[@]}"; echo "         ],"
        echo -e "\nVMess_OLD:\n        \"clients\": ["; printf '          %s\n' "${vmess_OLD[@]}"; echo "         ],"
        echo -e "\nTrojan_OLD:\n        \"clients\": ["; printf '          %s\n' "${trojan_OLD[@]}"; echo "         ],"
        echo -e "\nSShadowSSocks_OLD:\n        \"clients\": ["; printf '          %s\n' "${shadowsocks_OLD[@]}"; echo "         ],"
    } > xRay_Conf.json
    
    echo -e "\n格式化处理结束，请使用 cat xRay_Conf.json 查看"
    echo -e "\n===========格式化输出内容结束===========\n"
    echo -e "\n=======请勿退出，继续处理相关设置=======\n"
    modify_conf
}

base64_uuids() {
    echo "请输入要转换的UUID，以空行结束"
    while read -r uuid && [ -n "$uuid" ]; do
        your_uuid_array+=("$uuid")
    done
    if [ "${#your_uuid_array[@]}" -ne 0 ]; then
        for ((i=0; i<"${#your_uuid_array[@]}"; i++)); do
            your_uuid="${your_uuid_array[i]}"
            base64_uuid=$(echo -n "$your_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            base64_uuid+="=="
            base64_uuid_array+=("    $base64_uuid")  # Add four spaces before appending to the array
        done
        echo -e "BASE64 CODEs:\n"
        for ((i=0; i<"${#base64_uuid_array[@]}"; i++)); do
            echo "${base64_uuid_array[i]}"
        done
        echo -e "\n============操作结束============\n"
        exit 0
    else
        echo -e "输入的内空为空或错误，退出，请重新选择"
    fi
    display_pause_info
}

domain_set() {
    echo "请输入你的域名，以空行结束（可以很多行，Excel可直接复制粘贴）"
    domains=()
    while read -r domain && [ -n "$domain" ]; do
        domains+=("$domain")
    done

    local_ip=$(curl -s ifconfig.me)
    matched_prefix=""
    matched_domain=""
    full_domain=""

    sudo rm -r /etc/tls/* -f
    sudo mkdir -p /etc/tls
    processed_domains=()

    for domain in "${domains[@]}"; do
        processed_domains+=("$(echo "$domain" | sed 's/^[^.]*\.//')")
    done

    unique_domains=($(echo "${processed_domains[@]}" | tr ' ' '\n' | sort -u))

    for domain in "${domains[@]}"; do
        result=$(dig +short "$domain" | tr -d '[:space:]')
        if [ "$result" == "$local_ip" ]; then
            matched_prefix=$(echo "$domain" | awk -F'.' '{print $1}')
            matched_domain=$(echo "$domain" | sed "s/$matched_prefix\.//")
            full_domain=$domain
            break
        fi
    done

    unique_domains_new=()
    unique_domains_nginx=()

    for prefix in "${unique_domains[@]}"; do
        if [ "$prefix" != "$matched_domain" ]; then
            unique_domains_new+=("$matched_prefix.$prefix")
            unique_domains_nginx+=("*.$prefix")
        fi
    done

    curl https://get.acme.sh | sh > /dev/null 2>&1

    if [ -n "$matched_domain" ]; then
        sudo ~/.acme.sh/acme.sh --register-account -m admin@$matched_domain > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 -w /var/www/letsencrypt > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --installcert -d $full_domain  --fullchainpath /etc/tls/$matched_domain.crt  --keypath /etc/tls/$matched_domain.key > /dev/null 2>&1

    else
        echo "未找到匹配的域名"
    fi

    echo -e "\n================================\n"

    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        echo "尝试通过Nginx申请证书的域名: ${unique_domains_new[i]}"
    done

    echo -e "\n================================\n"

    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        sudo ~/.acme.sh/acme.sh --issue -d ${unique_domains_new[i]} --keylength ec-256 -w /var/www/letsencrypt > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --installcert -d ${unique_domains_new[i]}  --fullchainpath /etc/tls/${unique_domains[i]}.crt  --keypath /etc/tls/${unique_domains[i]}.key > /dev/null 2>&1

    done

    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
            :
        else
            sudo rm -f "/etc/tls/${unique_domains[i]}.key" "/etc/tls/${unique_domains[i]}.crt" > /dev/null 2>&1
        fi
    done

    ls /etc/tls
    display_pause_info
}


install_xRay() {
    rm -rf /etc/nginx/conf.d/*.*
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root > /dev/null 2>&1
    # 安装XRay官方版本，使用User=root，这将覆盖现有服务文件中的User
    apt -y update
    apt -y install curl git build-essential libssl-dev libevent-dev zlib1g-dev gcc-mingw-w64 nginx > /dev/null 2>&1
    useradd nginx -s /sbin/nologin -M
    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh)
    rm -rf /usr/local/etc/sing-box/config.json config.json
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/singbox_exp.json > /dev/null 2>&1
    mv singbox_exp.json /usr/local/etc/sing-box/config.json -f
    rm -rf /etc/nginx/nginx.conf nginx.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1

    for domain in "${unique_domains_nginx[@]}"; do
        sed -i "/$domain/d" nginx.conf
    done

    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" nginx.conf
    done

    sed -i "/yourdomain.com/d" nginx.conf
    mv nginx.conf /etc/nginx/nginx.conf
    rm -rf /etc/nginx/conf.d/default.conf default.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1

    for domain in "${unique_domains_nginx[@]}"; do
        sed -i "/$domain/d" default.conf
    done

    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" default.conf
    done

    sed -i "/yourdomain.com/d" default.conf
    mv default.conf /etc/nginx/conf.d/default.conf
    sudo systemctl restart nginx xray sing-box
    systemctl status nginx
    systemctl status xray
    systemctl status sing-box
    display_pause_info
}

modify_conf() {
  rm -rf /usr/local/etc/xray/config.json config.conf
  wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/config.json > /dev/null 2>&1
  cp config.json /usr/local/etc/xray/config.json -f
  json_file="xRay_conf.json"
  config_file="/usr/local/etc/xray/config.json"
  tag_values=("VLess-TCP-xTLS" "VLess-TCP" "VMess-TCP" "Trojan-TCP" "Shadowsocks-TCP" "VLess-WS" "VMess-WS" "Trojan-WS" "Shadowsocks-WS" "VLess-gRPC" "VMess-gRPC" "Trojan-gRPC" "Shadowsocks-gRPC" "VLess-OLD" "VMess-OLD" "Trojan-OLD" "Shadowsocks-OLD")

  for tag_value in "${tag_values[@]}"; do
    array_content=""
    case "$tag_value" in
      "VLess-TCP-xTLS") array_content=("${vless_tcp_xtls[@]}") ;;
      "VLess-TCP") array_content=("${vless_tcp[@]}") ;;
      "VMess-TCP") array_content=("${vmess_tcp[@]}") ;;
      "Trojan-TCP") array_content=("${trojan_tcp[@]}") ;;
      "Shadowsocks-TCP") array_content=("${shadowsocks_tcp[@]}") ;;
      "VLess-WS") array_content=("${vless_ws[@]}") ;;
      "VMess-WS") array_content=("${vmess_ws[@]}") ;;
      "Trojan-WS") array_content=("${trojan_ws[@]}") ;;
      "Shadowsocks-WS") array_content=("${shadowsocks_ws[@]}") ;;
      "VLess-gRPC") array_content=("${vless_gRPC[@]}") ;;
      "VMess-gRPC") array_content=("${vmess_gRPC[@]}") ;;
      "Trojan-gRPC") array_content=("${trojan_gRPC[@]}") ;;
      "Shadowsocks-gRPC") array_content=("${shadowsocks_gRPC[@]}") ;;
      "VLess-OLD") array_content=("${vless_OLD[@]}") ;;
      "VMess-OLD") array_content=("${vmess_OLD[@]}") ;;
      "Trojan-OLD") array_content=("${trojan_OLD[@]}") ;;
      "Shadowsocks-OLD") array_content=("${shadowsocks_OLD[@]}") ;;
    esac

    {
      echo -e "        \"clients\": ["; printf '          %s\n' "${array_content[@]}"; echo "         ],"
    } > "$json_file"

    found=$(sed -n "/\"tag\": \"$tag_value\"/I,/]/p" "$config_file")

    if [ -n "$found" ]; then
      sed -i "/\"tag\": \"$tag_value\"/I,/]/ { 
        /\"clients\": \[/ {
          N
          r $json_file
          s/"clients": \[.*\]/"clients": \[/
          :loop
          N
          /\n\s*]/!b loop
          d
        }
      }" "$config_file"

      echo "替换完成：$tag_value"
    else
      echo "未找到符合条件的配置：$tag_value。"
    fi
  done

  {
    certname=($(ls -1 /etc/tls | sed 's/\(.*\)\..*/\1/' | sort -u))
    for ((i=0; i<${#certname[@]}; i++)); do
      cert="${certname[i]}"
      if [ $i -eq $((${#certname[@]}-1)) ]; then
        echo -e "            {\"certificateFile\": \"/etc/tls/$cert.crt\", \"keyFile\": \"/etc/tls/$cert.key\", \"ocspStapling\": 3600, \"usage\": \"encipherment\"}"
      else
        echo -e "            {\"certificateFile\": \"/etc/tls/$cert.crt\", \"keyFile\": \"/etc/tls/$cert.key\", \"ocspStapling\": 3600, \"usage\": \"encipherment\"},"
      fi
    done
  } > "$json_file"

  cert_count=$(grep -o "certificateFile" "$json_file" | wc -l)

  if grep -q '"certificates": \[' "$config_file"; then
    sed -i "/\"certificates\": \[/ r $json_file" "$config_file"
  else
    sed -i "/\"certificates\": {/ r $json_file" "$config_file"
  fi

  certificate_count=$(grep -c "certificateFile" "$config_file")
  last_line=$(grep -n "certificateFile" "$config_file" | tail -n 1 | cut -d ':' -f 1)
  start_line=$((last_line - (certificate_count - cert_count-1)))
  delete_lines=$((certificate_count - cert_count + 1))
  sed -i "${start_line},${last_line}d" "$config_file"

  echo -e "\n========xRar内容替换完成，重启xRay========\n"
  sudo systemctl restart xray 
  systemctl status xray
  display_pause_info
}

show_info() {
    acme=($(ls -I '*.conf' -I 'acme.sh' -I 'acme.sh.env' -I 'ca' -I 'deploy' -I 'dnsapi' -I 'http.header' -I 'notify' ~/.acme.sh))
    acme_new=()
    for item in "${acme[@]}"; do
        acme_new+=("${item%_ecc}")
    done

    local_ip=$(curl -s ifconfig.me)

    for acme_d in "${acme_new[@]}"; do
        result=$(dig +short "$acme_d" | tr -d '[:space:]')
        if [ "$result" == "$local_ip" ]; then
            matched_prefix=$(echo "$acme_d" | awk -F'.' '{print $1}')
            matched_domain=$(echo "$acme_d" | sed "s/$matched_prefix\.//")
            full_domain=$acme_d
            break
        fi
    done

    config_file="/usr/local/etc/sing-box/config.json"
    sb_sn=($(grep -oP '"server_name": "\K[^"]+' "$config_file"))
    sbsn_new=($(echo "${sb_sn[@]}" | tr ' ' '\n' | sort -u))

    for sn in "${sbsn_new[@]}"; do
        matched=false
        for ((i=0; i<${#full_domain[@]}; i++)); do
            if [[ "${full_domain[$i]}" == *"$sn"* ]]; then
                matched=true
                break
            fi
        done

        if [ "$matched" = false ]; then
            echo -e "================================="
            echo -e "  \e[91m不正域的域名配置:\e[0m"
            printf "%s\n" "   ${sbsn_new[@]}"
            sed -i "s/$sn/$matched_domain/g" "$config_file"
            echo -e "================================="
            echo -e " \e[92m已完成Sing-Box的Server_Name更新\e[0m"
            sed -i '/"certificate_path"/d' "$config_file"
            sed -i "/\"key_path\"/i \\\t\"certificate_path\": \"/etc/tls/$matched_domain.crt\"," "$config_file"
            sed -i '/"key_path"/d' "$config_file"
            sed -i "/\"certificate_path\"/a \\\t\"key_path\": \"/etc/tls/$matched_domain.key\"," "$config_file"
            echo -e " \e[92m已完成Sing-Box证书路径更新\e[0m"
            curl -s https://get.acme.sh | sh > /dev/null 2>&1
            mkdir -p /etc/tls/
            sudo ~/.acme.sh/acme.sh --register-account -m admin@$matched_domain > /dev/null 2>&1
            sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 -w /var/www/letsencrypt > /dev/null 2>&1
            sudo ~/.acme.sh/acme.sh --installcert -d $full_domain  --fullchainpath /etc/tls/$matched_domain.crt  --keypath /etc/tls/$matched_domain.key > /dev/null 2>&1
            echo -e " \e[92mTLS证书已正确配置\e[0m"
            echo -e "================================="
        else
            echo -e "\n  \e[92mSing-Box证书和域名配置正确，无需操作\n\e[0m"
        fi
    done

    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' | cut -c 1-5))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' | sed 's/-in//'))
    listen_ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"listen_port": \K[^,]+'))

    type2=()
    path_t=()
    echo -e "=================================================================="
    printf "%20s""Sing-Box配置清单"
    echo -e "\n------------------------------------------------------------------"
    printf "\e[1;32m%-4s %-15s %-10s %-15s %-20s \e[0m\n" "No." "Type" "Ports" "Transport" "path"
    echo -e "------------------------------------------------------------------"

    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]}
        next_tag=${tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi

        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$config_file")
        path_t=$(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n1)
        type_t=$(echo "$content" | grep -oP '"type": "\K[^\"]+' | sed -n '2p')

        if echo "$content" | grep -q '"transport"'; then
            type2+="1"
            if [ -z "$type_t" ]; then
                type_t=" "
            fi
        else
            type2+=" "
            type_t=" "
        fi

        printf "%-4s " "$((i+1))."
        printf "%-15s " "${type[i]}"
        printf "%-10s " "${listen_ports[i]}"
        printf "%-15s " "$type_t"
        printf "%-20s\n" "$path_t"
    done

    config_file="/usr/local/etc/xray/config.json"

    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"protocol": "\K[^"]+'))
    listen_ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"port": \K[^,]+'))

    type2=()
    path_t=()
    echo -e "=================================================================="

    printf "%22s""xRay配置清单"
    echo -e "\n------------------------------------------------------------------"
    printf "\e[1;32m%-4s %-18s %-17s %-5s %-20s \e[0m\n" "No." "Name" "Type" "Port" "path"
    echo -e "------------------------------------------------------------------"

    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]}
        next_tag=${tags[$((i+1))]}

        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi

        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$config_file")

        path_t=$(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n1)
        type_t=$(echo "$content" | grep -oP '"type": "\K[^\"]+' | sed -n '2p')

        if [[ "$current_tag" == *gRPC ]]; then
            path_g=($(echo "$content" | grep -oP '"serviceName": "\K[^"]+' | sed 's/,//g'))
            path_t=$path_g
        fi

        if echo "$content" | grep -q '"transport"'; then
            type2+="1"
            [ -z "$type_t" ] && type_t=" "
        else
            type2+=" "
            type_t=" "
        fi

        [ "${type[i]}" != "dokodemo-door" ] && listen_ports[i]="443"

        printf "%-4s " "$((i+1))."
        printf "%-18s " "${tags[i]}"
        printf "%-17s " "${type[i]}"
        printf "%-5s " "${listen_ports[i]}"
        printf "%-20s\n" "$path_t"
    done

    echo -e "================================================================"
    
    display_pause_info
}

domain_set() {
    echo "请输入你的域名，以空行结束（可以很多行，Excel可直接复制粘贴）"
    domains=()
    while read -r domain && [ -n "$domain" ]; do
        domains+=("$domain")
    done
    local_ip=$(curl -s ifconfig.me)
    matched_prefix=""
    matched_domain=""
    full_domain=""
    sudo rm -r /etc/tls/* -f
    sudo mkdir -p /etc/tls
    processed_domains=()
    for domain in "${domains[@]}"; do
        processed_domains+=("$(echo "$domain" | sed 's/^[^.]*\.//')")
    done
    unique_domains=($(echo "${processed_domains[@]}" | tr ' ' '\n' | sort -u))
    for domain in "${domains[@]}"; do
        result=$(dig +short "$domain" | tr -d '[:space:]')  
        if [ "$result" == "$local_ip" ]; then
            matched_prefix=$(echo "$domain" | awk -F'.' '{print $1}')
            matched_domain=$(echo "$domain" | sed "s/$matched_prefix\.//")
            full_domain=$domain
            break  
        fi
    done
    unique_domains_new=()    unique_domains_nginx=()
    for prefix in "${unique_domains[@]}"; do
        if [ "$prefix" != "$matched_domain" ]; then
            unique_domains_new+=("$matched_prefix.$prefix")
            unique_domains_nginx+=("*.$prefix")

        fi
    done
    if ! command -v acme.sh &> /dev/null; then
        echo "acme.sh 未安装，正在安装..."
        curl https://get.acme.sh | sh > /dev/null 2>&1
    else
        echo "acme.sh 已安装，跳过安装步骤"
    fi
    if [ -n "$matched_domain" ]; then
        sudo ~/.acme.sh/acme.sh --register-account -m admin@$matched_domain > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 -w /var/www/letsencrypt > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --installcert -d $full_domain  --fullchainpath /etc/tls/$matched_domain.crt  --keypath /etc/tls/$matched_domain.key > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --installcert -d ${unique_domains_new[i]}  --fullchainpath /etc/tls/${unique_domains[i]}.crt  --keypath /etc/tls/${unique_domains[i]}.key > /dev/null 2>&1
    done
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
        	:
        else
            sudo rm -f "/etc/tls/${unique_domains[i]}.key" "/etc/tls/${unique_domains[i]}.crt"
        fi
    done
    rm -rf /etc/nginx/nginx.conf nginx.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
    for domain in "${unique_domains_nginx[@]}"; do
      sed -i "/$domain/d" nginx.conf
    done
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" nginx.conf
    done
    sed -i "/yourdomain.com/d" nginx.conf
    mv nginx.conf /etc/nginx/nginx.conf
    rm -rf /etc/nginx/conf.d/default.conf default.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
    for domain in "${unique_domains_nginx[@]}"; do
      sed -i "/$domain/d" default.conf
    done
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" default.conf
    done
    sed -i "/yourdomain.com/d" default.conf
    mv default.conf /etc/nginx/conf.d/default.conf
    if [ -n "$matched_domain" ]; then
      sudo sed -i 's/exp\.domain\.com/'"$domain"'/g' /usr/local/etc/sing-box/config.json
      sudo sed -i 's/domain\.com/'"$matched_domain"'/g' /usr/local/etc/sing-box/config.json
    fi 
    ls /etc/tls
    display_pause_info
}

xray_info() {
    config_file="/usr/local/etc/xray/config.json"
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' ))

    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${tags[$((i+1))]}

        if [ -z "$next_tag" ]; then
            current_tag=${tags[-1]}
            next_tag="outbounds"
            current_tag=${tags[-1]}
            ids=($(sed -n "/\"$current_tag\"/,/\"outbounds\"/ { /\"id\"/p }" "$config_file"))
            passwords=($(sed -n "/\"$current_tag\"/,/\"outbounds\"/ { /\"password\"/p }" "$config_file"))

            printf "Tags: %s" "${tags[i]}_"
            printf "IDs:\n"

            if [ ${#passwords[@]} -gt 0 ]; then
                printf "%s\n" "${passwords[@]}"
            else
                printf "%s\n" "${ids[@]}"
            fi

            printf "%s\n"

        else 
            ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$config_file"))

            if [[ "${tags[i]}" =~ "Trojan" || "${tags[i]}" =~ "ShadowSocks" ]]; then
                passwords=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$config_file"))
            else
                passwords=()
            fi

            printf "Tags: %s" "${tags[i]}_"
            printf "IDs:\n"

            if [ ${#passwords[@]} -gt 0 ]; then
                printf "%s\n" "${passwords[@]}"
            else
                printf "%s\n" "${ids[@]}"
            fi

            printf "%s\n" 
        fi
    done

    display_pause_info
}

display_pause_info() {
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

sing_info() {
    config_file="/usr/local/etc/sing-box/config.json"

    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }

    uuid_to_base64() {
        local uuid=$1
        local base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid"
    }

    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))

    # Reformat UUIDs to standard format
    names=($(echo "${names[@]}" | awk '{gsub(/(.{8})(.{4})(.{4})(.{4})(.{12})/, "\\1-\\2-\\3-\\4-\\5")}1'))

    # Filter out elements that do not conform to the UUID format and remove duplicates
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))

    # Convert UUIDs to base64 format for shadowsocks type
    for tag in "vless" "shadowsocks"; do
        if [[ "$tag" == "shadow"* ]]; then
            names=($(for uuid in "${names[@]}"; do uuid_to_base64 "$uuid"; done))
        fi

        printf "Tags: %s" "${tag}_"
        printf "IDs:\n"
        printf "%s\n" "${names[@]}"
    done

    display_pause_info
}

while true; do
    clear
    echo -e "\n\e[93m=========xRay/Sing-box批量管理=========\e[0m\n"
    echo -e "\e[92m     仅适用于Debian 12的全新机\e[0m\n"
    echo -e "   1. 自动生成新UUID和旧UUID\n"
    echo -e "   2. 自动生成新UUID，手动输入旧UUID\n"
    echo -e "   3. 手动输入新UUID和旧UUID\n"
    echo -e "   4. 将UUID转换为SS认可的BASE64格式\n"
    echo -e "   5. 安装Nginx/Sing-box/xRay\n"
    echo -e "   6. 域名检查，重新生成Let's证书\n"
    echo -e "   7. 显示Sing-box/xRay配置\n"
    echo -e "   8. 显示xRay用户信息\n"
    echo -e "   9. 显示Sing-box用户信息\n"
    echo -e "   0. 退出\n"
    echo -e "\e[37m            www.nruan.com\e[0m"
    echo -e "\e[93m======================================\e[0m\n"
    read -p "选择操作（0-9）: " choice

    case $choice in
        1)
            generate_new_uuids
            ;;
        2)
            generate_new_uuid_with_manual_old
            ;;
        3)
            manual_input_uuids
            ;;
        4)
            base64_uuids
            ;;
        5)
            install_xRay
            ;;
        6)
            domain_set
            ;;
        7)
            show_info
            ;;
        8)
            xray_info
            ;;
        9)
            sing_info
            ;;
        0)
            echo "退出菜单。"
            exit 0
            ;;
        *)
            echo "无效选择，请重新输入。"
            ;;
    esac
done
