#!/bin/bash
# author:Michael Mao
# url:www.nruan.com
# Your JSON file path
# Set the color code for red
# Set the color code for orange (color 208 in the 256-color palette)
ORANGE='\033[38;5;208m'
# Set the color code for green (color 34 in the 256-color palette)
GREEN='\033[38;5;34m'
# Set the color code for yellow (color 3 in the 256-color palette)
YELLOW='\033[38;5;3m'
# Reset the color to default
NC='\033[0m'
# 定义域名数组，不需要的可以删除整行或者用 # 在行首注释

domain[0]=yordomain1.com
domain[1]=yordomain2.com
domain[2]=yordomain3.com
domain[3]=yordomain4.com
domain[4]=yordomain5.com
domain[5]=yordomain6.com

# Nginx配置路径默认为conf.d,安全测试后自行改回。
path=conf.d
# JSON 文件路径默认为：/etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json
json_file="/etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json"

# cp /etc/v2ray-agent/xray/conf/02_VLESS_TCP_inbounds.json $json_file

# 以下内容勿改动！
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
# 要插入的 JSON 内容的模板
inserted_content_template='        {
              "certificateFile": "/etc/tls/$matched_domains.crt",
              "keyFile": "/etc/tls/$matched_domains.key",
              "ocspStapling": 3600
            },'
# 输出比对结果
echo  -e "${ORANGE}============ 处 理 信 息 ============${NC}"
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
	sed  -i "s/$result/$result2.$i/g" /etc/nginx/$path/${matched_domains[$j]%%.*}.conf
j=$((j + 1))
done
echo -e "${ORANGE}未配置TLS证书的域名:${NC}"
for d in "${unmatched_domains[@]}"; do
    echo "	$d"
done
echo -e "${GREEN}Nginx 置文件：${NC}"
ls /etc/nginx/$path/
cd "$original_directory" || exit
rm *.sh -f
echo  -e "${ORANGE}============ 处 理 结 束 ============${NC}"
systemctl restart nginx
service nginx reload
systemctl status nginx
