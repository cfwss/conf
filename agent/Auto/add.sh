

#!/bin/bash
# author:Michael Mao
# url:www.nruan.com
# Your JSON file path
ORANGE='\033[38;5;208m'
GREEN='\033[38;5;34m'
YELLOW='\033[38;5;3m'
HIGH_INTENSITY_RED='\033[1;31m'
HIGH_INTENSITY_BLUE='\033[1;34m'
HIGH_INTENSITY_YELLOW='\033[1;33m'
LIGHT_GRAY='\033[0;37m'
NC='\033[0m'
declare -a domain=()
cert_dir="/etc/tls"
[ ! -d "/etc/tls" ] && mkdir -p "/etc/tls" > /dev/null 2>&1
echo  -e "${HIGH_INTENSITY_YELLOW}请输入域名，每行一个，输入空行结束：${NC}"
# 循环读取用户输入，直到输入空行
while true; do
    read input_domain
    input_domain=$(echo "$input_domain" | tr -d '[:space:]')
    if [ -z "$input_domain" ]; then
        break
    fi
    domain+=("$input_domain")
done
echo  -e "${HIGH_INTENSITY_BLUE}输入的域名为：${NC}"
printf "\t%s\n" "${domain[@]}"
echo -e "\n\n"
# Nginx配置路径默认为conf.d,安全测试后自行改回。
path=conf.d
# JSON 文件路径默认为：/etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json
json_file="/etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json"

# cp /etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json $json_file


# 以下内容勿改动！
# 循环检查数组中的域名
for d in "${domain[@]}"; do
    cert_file="${cert_dir}/${d}.crt"
    key_file="${cert_dir}/${d}.key"
    # 检查证书文件是否已存在
    if [ -e "$cert_file" ] || [ -e "$key_file" ]; then
        read -p "证书文件 ${d}.crt 或私钥文件 ${d}.key 已存在。是否要更新？(y/n, 回车或Ctrl+D跳过): " overwrite
        # 默认回车为跳过
        if [ "${overwrite,,}" != "y" ]; then
            echo "未覆盖，跳过域名 $d。"
            continue
        fi
    fi
    # 显示证书文件并输入公钥
    echo "为域名 $d 创建证书文件：$cert_file"
    echo -e "${HIGH_INTENSITY_YELLOW}请输入公钥（输入空行或回车结束）:${NC}"
    # 开始输入公钥，直到遇到空行或Ctrl+D为止
    public_key=""
    while read -r line; do
        if [ -z "$line" ]; then
            break
        fi
        public_key+="$line\n"
    done
    echo -e "${ORANGE}公钥输入结束.${NC}"
    # 显示私钥文件并输入私钥
    echo "为域名 $d 创建私钥文件：$key_file"
    echo -e "${HIGH_INTENSITY_BLUE}请输入私钥（输入空行或回车结束）:${NC}"
    # 开始输入私钥，直到遇到空行或Ctrl+D为止
    private_key=""
    while read -r line; do
        if [ -z "$line" ]; then
            break
        fi
        private_key+="$line\n"
    done
    echo -e "${ORANGE}私钥输入结束.${NC}"
    # 将输入的公钥和私钥写入文件
    echo -e "$public_key" > "$cert_file"
    echo -e "$private_key" > "$key_file"
    echo "证书文件 $cert_file 和私钥文件 $key_file 已保存。"
done

echo  -e "${ORANGE}================= 处 理 信 息 =================${NC}"
for key_file in "$cert_dir"/*.key; do
    if [ -f "$key_file" ]; then
        word_count=$(wc -w "$key_file" | awk '{print $1}')
        if [ "$word_count" -lt 9 ]; then
            rm "$key_file"
            echo -e "${LIGHT_GRAY}已删除无效key证书: $key_file${NC}"
        fi
    fi
done
for crt_file in "$cert_dir"/*.crt; do
    if [ -f "$crt_file" ]; then
        word_count=$(wc -w "$crt_file" | awk '{print $1}')
        if [ "$word_count" -lt 21 ]; then
            rm "$crt_file"
            echo -e "${LIGHT_GRAY}已删除无效crt证书: $crt_file${NC}"
        fi
    fi
done
service nginx stop
# Use grep and awk to extract the desired substrings
result_array=($(grep -oP '/tls/\K(.*?)(?=.crt)' "$json_file" | awk '{print $1}'))
# 检查目录中的文件名是否与数组中的域名匹配
directory="/etc/tls/"
matched_domains=()
unmatched_domains=()
for d in "${domain[@]}"; do
    if [ -e "$directory$d.crt" ]; then
        matched_domains+=("$d")
    else
        unmatched_domains+=("$d")
    fi
done
echo -e "${ORANGE}-----------------------------------------------${NC}"
# 要插入的 JSON 内容的模板
inserted_content_template='        {
              "certificateFile": "/etc/tls/$matched_domains.crt",
              "keyFile": "/etc/tls/$matched_domains.key",
              "ocspStapling": 3600
            },'
for d in "${matched_domains[@]}"; do
    if [[ " ${result_array[@]} " =~ " $d " ]]; then
        echo -e "${GREEN}已存在证书路径配置:${NC} $d"
    else
    current_inserted_content=$(echo "$inserted_content_template" | sed "s/\$matched_domains/$d/g")
    awk -v ic="$current_inserted_content" '/"certificates": \[/{print; print "    " ic; next} 1' "$json_file" > temp.json
        echo -e "${YELLOW}证书路径已添加:${NC} $d"
    mv temp.json "$json_file"
    fi
done
original_directory=$(pwd)
target_directory="/etc/nginx/$path"
keep_file="alone.conf"
cd "$target_directory" || exit
files_to_delete=$(find . -type f -not -name "$keep_file")
for file in $files_to_delete; do
    rm "$file"
done
port=31400;j=0
result=($(grep -oP "(?<=server_name).+" /etc/nginx/conf.d/alone.conf))
result=${result//;/}
dot_index=$(expr index "$result" ".")
result2=${result:0:dot_index-1}
for i in "${matched_domains[@]}";do  
port=$((port + 1))
	rm /etc/nginx/$path/${matched_domains[$j]%%.*}.conf -f
	cp /etc/nginx/conf.d/alone.conf  /etc/nginx/$path/${matched_domains[$j]%%.*}.conf
	sed  -i "s/listen 127.0.0.1:31302/listen 127.0.0.1:$port/g" /etc/nginx/$path/${matched_domains[$j]%%.*}.conf
	sed  -i "s/$domain/$result1.$i/g" /etc/nginx/$path/${matched_domains[$j]%%.*}.conf
j=$((j + 1))
done
echo -e "${ORANGE}-----------------------------------------------${NC}"
echo -e "${ORANGE}未配置TLS证书的域名:${NC}"
for d in "${unmatched_domains[@]}"; do
    echo "	$d"
done
echo -e "${ORANGE}-----------------------------------------------${NC}"
echo -e "${GREEN}Nginx 配置文件清单：${NC}"
ls /etc/nginx/$path/
cd "$original_directory" || exit
rm "$0" -f
echo -e "${ORANGE}-----------------------------------------------${NC}"
A=($(grep -oP '"certificateFile": "\K[^"]+' "$json_file" | sed 's/.crt//' | grep -v "v2ray-agent"))
B=($(find "$cert_dir" -type f -name "*.crt" -exec bash -c 'echo "${0%.*}"' {} \;))
for cert in "${A[@]}"; do
  if [[ ! " ${B[@]} " =~ " $cert " ]]; then
    echo "证书'$cert'已配置，但在$cert_dir中不存在"
    echo "$cert"
	line_number=$(grep -n "$cert" $json_file | head -n 1 | cut -d ':' -f 1)
	start_line=$((line_number ))
	end_line=$((line_number + 4))
	sed -i "${start_line},${end_line}d" $json_file
	echo "已删除未正确配置的证书：$cert"
  fi
done

for cert in "${A[@]}"; do
  if [[ " ${B[@]} " =~ " $cert " ]]; then
    echo "证书'$cert'已正确配置"
  fi
done
for cert in "${B[@]}"; do
  if [[ ! " ${A[@]} " =~ " $cert " ]]; then
    echo "证书'$cert'在$cert_dir中存在，但未在JSON中配置"
  fi
done
echo -e "${ORANGE}-----------------------------------------------${NC}"
systemctl restart nginx
service nginx reload
systemctl stop xray
systemctl start xray
status=$(systemctl status nginx.service | grep "Active:")
if [[ $status == *"active (running)"* ]]; then
    echo -e "${GREEN}Nginx 已重启并在正常运行${NC}"
else
    echo -e "${HIGH_INTENSITY_RED}Nginx 启动失败${NC}"
fi
status=$(systemctl status xray.service | grep "Active:")
if [[ $status == *"active (running)"* ]]; then
    echo -e "${GREEN}Xray  已重启并在正常运行${NC}"
else
    echo -e "${HIGH_INTENSITY_RED}Xray 启动失败${NC}"
fi
echo  -e "${ORANGE}================= 处 理 结 束 =================${NC}"
