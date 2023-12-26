#!/bin/bash

# 创建新数组用于存储new_uuid和old_uuid
declare -a new_uuid_array
declare -a old_uuid_array
apt install wget
generate_new_uuids() {
    # 生成新UUID并打印，同时存储到数组中
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
    # 自动生成新UUID，手动输入旧UUID，并显示，同时存储到数组中
    read -p "请输入要生成新的UUID数量: " count
    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
    done

    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    elif [ "$count" -ne 0 ]; then
        echo "请输入UUID，每行一个，以空行结束："
    	    # 提示用户输入UUID，以空行结束循环
        while read -r uuid && [ -n "$uuid" ]; do
            old_uuid_array+=("$uuid")
        done
        
        # 显示数组内容
        echo -e "\n生成的新UUID："
        printf "%s\n" "${old_uuid_array[@]}"
        echo -e "\n输入的旧UUID："
        printf "%s\n" "${old_uuid_array[@]}"
    
        process_info
    fi
}

manual_input_uuids() {
    # 手动输入新UUID和旧UUID，并显示，同时存储到数组中
    echo "请输入新的UUID，以空行结束"
    # 提示用户输入UUID，以空行结束循环
    while read -r uuid && [ -n "$uuid" ]; do
        new_uuid_array+=("$uuid")
    done

    # 显示数组内容
    echo -e "\n输入的新UUID："
    printf "%s\n" "${new_uuid_array[@]}"
    
    
    echo "请输入旧的UUID，以空行结束"
    # 提示用户输入UUID，以空行结束循环
    while read -r uuid && [ -n "$uuid" ]; do
        old_uuid_array+=("$uuid")
    done

    # 显示数组内容
    echo -e "\n输入的旧UUID："
    printf "%s\n" "${old_uuid_array[@]}"
    
    process_info
}

process_info() {
    
     # 处理输入的UUID并存入数组
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


# 替换JSON字符串中的uuid字段
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

# 去掉最后一行末尾的逗号
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
    
     # 打印数组内容
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
   } > xRay_Format.json
     echo -e "\n格式化处理结束，请使用 cat xRay_Format.json 查看"
     echo -e "\n===========格式化输出内容结束===========\n"
     echo -e "\n========请勿退出，继续处理第6项=========\n"
}
base64_uuids() {
    # 提示用户输入UUID，以空行结束循环
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

        # Print the contents of base64_uuid_array
        echo -e "BASE64 CODEs:\n"
        for ((i=0; i<"${#base64_uuid_array[@]}"; i++)); do
            echo "${base64_uuid_array[i]}"
        done
        echo -e "\n============操作结束============\n"
        exit 0
    else
        echo -e "输入的内空为空或错误，退出，请重新选择"
    fi
}
domain_set() {
    #!/bin/bash

    # 声明域名数组
    echo "请输入你的域名，以空行结束（可以很多行，Excel可直接复制粘贴）"

    domains=()

    while read -r domain && [ -n "$domain" ]; do
        domains+=("$domain")
    done

    # 获取本机IP地址
    local_ip=$(curl -s ifconfig.me)

    # 初始化变量
    matched_prefix=""
    matched_domain=""
    full_domain=""

    sudo rm -r /etc/tls/* -f

    sudo mkdir -p /etc/tls

    # 处理所有域名，去掉前缀并存储到新数组
    processed_domains=()
    for domain in "${domains[@]}"; do
        processed_domains+=("$(echo "$domain" | sed 's/^[^.]*\.//')")
    done

    # 去重
    unique_domains=($(echo "${processed_domains[@]}" | tr ' ' '\n' | sort -u))

    # 遍历域名数组
    for domain in "${domains[@]}"; do
        result=$(dig +short "$domain" | tr -d '[:space:]')  # 移除空格
        if [ "$result" == "$local_ip" ]; then
            # 匹配成功，提取前缀和去掉前缀的域名
            matched_prefix=$(echo "$domain" | awk -F'.' '{print $1}')
            matched_domain=$(echo "$domain" | sed "s/$matched_prefix\.//")
            full_domain=$domain
            break  # 只需要一个结果，所以匹配成功后退出循环
        fi
    done

    unique_domains_new=()    unique_domains_nginx=()
    for prefix in "${unique_domains[@]}"; do
        # 排除掉matched_domain
        if [ "$prefix" != "$matched_domain" ]; then
            unique_domains_new+=("$matched_prefix.$prefix")
            unique_domains_nginx+=("*.$prefix")

        fi
    done

    if ! command -v acme.sh &> /dev/null; then
        echo "acme.sh 未安装，正在安装..."
        curl https://get.acme.sh | sh
    else
        echo "acme.sh 已安装，跳过安装步骤"
    fi

    # 如果未找到匹配的域名，不显示任何内容
    if [ -n "$matched_domain" ]; then
        echo "匹配成功的域名: $full_domain"
        echo "匹配成功的前缀: $matched_prefix"
        echo "去掉前缀的域名: $matched_domain"
        # 使用去重后的带前缀域名数组进行证书颁发
        sudo ~/.acme.sh/acme.sh --register-account -m admin@$matched_domain
        sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 -w /var/www/letsencrypt
        sudo ~/.acme.sh/acme.sh --installcert -d $full_domain --key-file /etc/tls/$matched_domain.key --fullchain-file /etc/tls/$matched_domain.crt
    else
        echo "未找到匹配的域名"
    fi
    
        echo -e "\n================================\n"
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        echo "尝试通过Nginx申请证书的域名: ${unique_domains_new[i]}"
    done
        echo -e "\n================================\n"
        
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
    	  echo "${unique_domains_new[i]}"
        sudo ~/.acme.sh/acme.sh --issue -d ${unique_domains_new[i]} --keylength ec-256 -w /var/www/letsencrypt
        sudo ~/.acme.sh/acme.sh --installcert -d ${unique_domains_new[i]} --key-file /etc/tls/${unique_domains[i]}.key --fullchain-file /etc/tls/${unique_domains[i]}.crt
    done

    # 检查证书有效性，删除多余无用信息
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
        	:
        else
            # 删除无关的 key 和 crt 文件
            sudo rm -f "/etc/tls/${unique_domains[i]}.key" "/etc/tls/${unique_domains[i]}.crt"
        fi
    done

    ls /etc/tls
}
install_xRay() {
	
    rm -rf /etc/nginx/conf.d/*.*

    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
    # 安装XRay官方版本，使用User=root，这将覆盖现有服务文件中的User

    apt -y update
    apt -y install curl git build-essential libssl-dev libevent-dev zlib1g-dev gcc-mingw-w64 nginx

    useradd nginx -s /sbin/nologin -M

    bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh)

    rm -rf /usr/local/etc/sing-box/config.json  config.json 
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/singbox_exp.json
    mv singbox_exp.json /usr/local/etc/sing-box/config.json -f
    
    rm -rf /etc/nginx/nginx.conf nginx.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf

    for domain in "${unique_domains_nginx[@]}"; do
        sed -i "/$domain/d" nginx.conf
    done

    # 通过 sed 在指定位置追加 server_name 条目
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" nginx.conf
    done

    sed -i "/yourdomain.com/d" nginx.conf
    mv nginx.conf /etc/nginx/nginx.conf

    rm -rf /etc/nginx/conf.d/default.conf default.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf
    
   
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i "/$domain/d" default.conf
    done

    # 通过 sed 在指定位置追加 server_name 条目
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" default.conf
    done

    sed -i "/yourdomain.com/d" default.conf
    mv default.conf /etc/nginx/conf.d/default.conf


    sudo systemctl restart nginx xray sing-box
    
    systemctl status  nginx
 
    systemctl status  xray
  
    systemctl status  sing-box
}
modify_conf() {
  # JSON 文件路径
  
  rm -rf /usr/local/etc/xray/config.json config.conf
  wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/config.conf
  cp config.conf /usr/local/etc/xray/config.json -f
    
  json_file="xRay_conf.json"
  config_file="/usr/local/etc/xray/config.json"

  # 假设 tag_values 是一个包含多个标签的数组
  tag_values=("VLess-TCP-xTLS" "VLess-TCP" "VMess-TCP" "Trojan-TCP" "Shadowsocks-TCP" "VLess-WS" "VMess-WS" "Trojan-WS" "Shadowsocks-WS" "VLess-gRPC" "VMess-gRPC" "Trojan-gRPC" "Shadowsocks-gRPC" "VLess-OLD" "VMess-OLD" "Trojan-OLD" "Shadowsocks-OLD")

  # 遍历标签数组
  for tag_value in "${tag_values[@]}"; do
    # 生成 xRay_conf.json 的逻辑
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

    # 生成 xRay_conf.json
    {
      echo -e "        \"clients\": ["; printf '          %s\n' "${array_content[@]}"; echo "         ],"
    } > "$json_file"

    # 使用 sed 查找并替换配置文件中匹配到的内容
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

  # 生成 tls_config.json 文件
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

  # 查找 "certificateFile" 出现的次数并记录
  certificate_count=$(grep -c "certificateFile" "$config_file")

  # 记录最后一次出现的行数
  last_line=$(grep -n "certificateFile" "$config_file" | tail -n 1 | cut -d ':' -f 1)

  # 计算起始删除行和删除行数
  start_line=$((last_line - (certificate_count - cert_count-1)))
  delete_lines=$((certificate_count - cert_count + 1))

  # 删除行
  sed -i "${start_line},${last_line}d" "$config_file"

  echo -e "\n========xRar内容替换完成，重启xRay========\n"
  sudo systemctl restart xray 

  systemctl status xray

  exit 0
}
domain_set() {
    #!/bin/bash

    # 声明域名数组
    echo "请输入你的域名，以空行结束（可以很多行，Excel可直接复制粘贴）"

    domains=()

    while read -r domain && [ -n "$domain" ]; do
        domains+=("$domain")
    done

    # 获取本机IP地址
    local_ip=$(curl -s ifconfig.me)

    # 初始化变量
    matched_prefix=""
    matched_domain=""
    full_domain=""

    sudo rm -r /etc/tls/* -f

    sudo mkdir -p /etc/tls

    # 处理所有域名，去掉前缀并存储到新数组
    processed_domains=()
    for domain in "${domains[@]}"; do
        processed_domains+=("$(echo "$domain" | sed 's/^[^.]*\.//')")
    done

    # 去重
    unique_domains=($(echo "${processed_domains[@]}" | tr ' ' '\n' | sort -u))

    # 遍历域名数组
    for domain in "${domains[@]}"; do
        result=$(dig +short "$domain" | tr -d '[:space:]')  # 移除空格
        if [ "$result" == "$local_ip" ]; then
            # 匹配成功，提取前缀和去掉前缀的域名
            matched_prefix=$(echo "$domain" | awk -F'.' '{print $1}')
            matched_domain=$(echo "$domain" | sed "s/$matched_prefix\.//")
            full_domain=$domain
            break  # 只需要一个结果，所以匹配成功后退出循环
        fi
    done

    unique_domains_new=()    unique_domains_nginx=()
    for prefix in "${unique_domains[@]}"; do
        # 排除掉matched_domain
        if [ "$prefix" != "$matched_domain" ]; then
            unique_domains_new+=("$matched_prefix.$prefix")
            unique_domains_nginx+=("*.$prefix")

        fi
    done

    if ! command -v acme.sh &> /dev/null; then
        echo "acme.sh 未安装，正在安装..."
        curl https://get.acme.sh | sh
    else
        echo "acme.sh 已安装，跳过安装步骤"
    fi

    # 如果未找到匹配的域名，不显示任何内容
    if [ -n "$matched_domain" ]; then
        echo "匹配成功的域名: $full_domain"
        echo "匹配成功的前缀: $matched_prefix"
        echo "去掉前缀的域名: $matched_domain"
        # 使用去重后的带前缀域名数组进行证书颁发
        sudo ~/.acme.sh/acme.sh --register-account -m admin@$matched_domain
        sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 -w /var/www/letsencrypt
        sudo ~/.acme.sh/acme.sh --installcert -d $full_domain --key-file /etc/tls/$matched_domain.key --fullchain-file /etc/tls/$matched_domain.crt
    else
        echo "未找到匹配的域名"
    fi
    
        echo -e "\n================================\n"
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        echo "尝试通过Nginx申请证书的域名: ${unique_domains_new[i]}"
    done
        echo -e "\n================================\n"
        
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
    	  echo "${unique_domains_new[i]}"
        sudo ~/.acme.sh/acme.sh --issue -d ${unique_domains_new[i]} --keylength ec-256 -w /var/www/letsencrypt
        sudo ~/.acme.sh/acme.sh --installcert -d ${unique_domains_new[i]} --key-file /etc/tls/${unique_domains[i]}.key --fullchain-file /etc/tls/${unique_domains[i]}.crt
    done

    # 检查证书有效性，删除多余无用信息
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
        	:
        else
            # 删除无关的 key 和 crt 文件
            sudo rm -f "/etc/tls/${unique_domains[i]}.key" "/etc/tls/${unique_domains[i]}.crt"
        fi
    done

    rm -rf /etc/nginx/nginx.conf nginx.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf
    for domain in "${unique_domains_nginx[@]}"; do
      sed -i "/$domain/d" nginx.conf
    done

    # 通过 sed 在指定位置追加 server_name 条目
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" nginx.conf
    done
    sed -i "/yourdomain.com/d" nginx.conf
    mv nginx.conf /etc/nginx/nginx.conf

    rm -rf /etc/nginx/conf.d/default.conf default.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf
    for domain in "${unique_domains_nginx[@]}"; do
      sed -i "/$domain/d" default.conf
    done

    # 通过 sed 在指定位置追加 server_name 条目
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" default.conf
    done
    sed -i "/yourdomain.com/d" default.conf
    mv default.conf /etc/nginx/conf.d/default.conf
    
   # 如果未找到匹配的域名，不显示任何内容
if [ -n "$matched_domain" ]; then
    # 使用sed替换文件中的字符串
    sudo sed -i 's/exp\.domain\.com/'"$domain"'/g' /usr/local/etc/sing-box/config.json
    sudo sed -i 's/domain\.com/'"$matched_domain"'/g' /usr/local/etc/sing-box/config.json
fi 

    ls /etc/tls
}
while true; do
    echo -e "\n===========格式化xRay用户信息===========\n"
    echo -e "         仅适用于Debian 12的全新机\n
    echo -e "   1. 自动生成新UUID和旧UUID\n"
    echo -e "   2. 自动生成新UUID，手动输入旧UUID\n"
    echo -e "   3. 手动输入新UUID和旧UUID\n"
    echo -e "   4. 将UUID转换为SS认可的BASE64格式\n"
    echo -e "   5. 安装Nginx/Sing-box/xRay\n"
    echo -e "   6. 域名检查，重新生成Let's证书\n"
    echo -e "   7. 修改Nginx/Sing-box/xRay配置\n"
    echo -e "   0. 退出\n"
    echo -e "              www.nruan.com
    echo -e "========================================\n"
    read -p "选择操作（0-7）: " choice

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
            modify_conf
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
