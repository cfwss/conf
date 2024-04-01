#!/bin/bash
color_set() {
    repeat_count=150
    reset_color='\e[0m'
    light_gray='\e[37m'
    dark_gray='\e[90m'
    half_repeat_count=$((repeat_count / 3))
    path_count=88
}
update_check(){
    xray_version=""
    box_version=""
    xray_latest_version=""
    box_latest_version=""
    file_patha="/usr/local/bin/nruan.sh"
    if [ -e "$file_patha" ]; then
        :
    else
        rm -rf /usr/local/bin/nruan /usr/local/bin/nruan.sh > /dev/null 2>&1
        mv nruan.sh /usr/local/bin/nruan.sh -f > /dev/null 2>&1
        ln -s /usr/local/bin/nruan.sh /usr/local/bin/nruan > /dev/null 2>&1
        chmod +x /usr/local/bin/nruan.sh > /dev/null 2>&1
    fi
    github_repo="cfwss/conf"
    file_name="nruan.sh"
    file_path="install/$file_name"
    get_last_modified_time() {
        local file_path=$1
        if [ -e "$file_path" ]; then
            local last_modified_time
            last_modified_time=$(stat -c %Y "$file_path" 2>/dev/null || stat -f %m -t "%Y" "$file_path" 2>/dev/null)
            echo "$last_modified_time"
        else
            echo "946684800"
        fi
    }
    github_last_modified=$(curl -sI "https://api.github.com/repos/$github_repo/contents/$file_path" | grep -i "last-modified" | awk -F ': ' '{ print $2 }')
    github_last_modified=$(date -d "$github_last_modified" +%s)
    usr_local_bin_last_modified=$(get_last_modified_time "/usr/local/bin/$file_name")
    formatted_date=$(date -d "@$github_last_modified" "+%Y/%m/%d %H:%M")
    if ! command -v jq &> /dev/null; then
        echo "Installing jq..."
        sudo apt-get install -y jq > /dev/null 2>&1
    fi
    xray_version_info=$(xray -version 2>/dev/null)
    xray_version=$(echo "$xray_version_info" | awk '/Xray/ {print $2}')
    box_version_info=$(sing-box version 2>/dev/null)
    box_version=$(echo "$box_version_info" | awk 'NR==1 {print $NF}')
    xray_user="XTLS"
    xray_repo="Xray-core"
    xray_latest_version=$(curl -s "https://api.github.com/repos/$xray_user/$xray_repo/releases/latest" | jq -r .tag_name)
    box_user="SagerNet"
    box_repo="sing-box"
    box_latest_version=$(curl -s "https://api.github.com/repos/$box_user/$box_repo/releases/latest" | jq -r .tag_name)
}
check_warp(){
    install=$(command -v warp &> /dev/null && echo true || echo false)
    warpport=$(awk -F'127.0.0.1:' '/\[Socks5\]/{getline; print $2}' /etc/wireguard/proxy.conf 2>/dev/null)
    if $install ; then
        echo -e "安装Warp \e[0;33m(选13，一路回车)\e[0m \e[90m[作者:fscarmen] \e[0m\e[0;31m已安装\e[0m\e[0;33m:\e[0m\e[0;32m$warpport\e[0m"
    else
        echo -e "安装Warp \e[0;33m(选13，一路回车)\e[0m \e[90m[作者:fscarmen] \e[0m\e[0;32m未安装\e[0m\e[0;33m:\e[0m\e[90m N/A \e[0m"
    fi
}
array_assignment() {
    new_uuid_array=()
    old_uuid_array=()
    box_uuid_array=()
}
generate_new_uuids() {
    path_count=150
    clear
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay和Sing-Box中现有的所有用户信息! \e[0m"
    echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
    read -r -p $'\e[93m - 请输入要生成新和老的UUID数量: \e[0m' count
    if [ -z "$count" ] || [ "$count" -eq 0 ]; then
        echo " - 生成数量为0, 退出操作。"
        display_pause_info
        return 1
    elif [ "$count" -ne 0 ]; then
        for ((i=1; i<=count; i++)); do
            new_uuid=$(uuidgen)
            old_uuid=$(uuidgen)
            box_uuid=$(uuidgen)
            new_uuid_array+=("$new_uuid")
            old_uuid_array+=("$old_uuid")
            box_uuid_array+=("$box_uuid")
        done
        display_generated_uuids
        xray_config_files
        if [ ! -e "$xray_config_file" ]; then
            echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
            display_pause_info
            return 1
        fi
        singbox_config_files
        if [ ! -e "$box_config_file" ]; then
            echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
            display_pause_info
            return 1
        fi
        process_xray_new
        process_xray_old
        process_sing_box
        xray_user_info
        singbox_user_info
        xray_domain_set
        show_all_status
        display_pause_info
    fi
}
generate_new_uuid_with_manual_old() {
    path_count=150
    clear
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay和Sing-Box中现有的所有用户信息! \e[0m"
    echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
    read -r -p $'\e[93m - 请输入要生成新的UUID数量: \e[0m' count
        if [ -z "$count" ] || [ "$count" -eq 0 ]; then
        echo -e "\e[1;91m - 生成数量为0, 退出操作。\e[0m"
        display_pause_info
        return 1
    fi
    for ((i=1; i<=count; i++)); do
        new_uuid=$(uuidgen)
        box_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
        box_uuid_array+=("$box_uuid")
    done
    echo -e "\e[93m - 请输入xRay 老用户的UUID, 每行一个, 以空行结束: \e[0m"
    while read -r uuid_manual && [ -n "$uuid_manual" ]; do
        old_uuid_array+=("$uuid_manual")
    done
    if [ ${#box_uuid_array[@]} -eq 0 ]; then
        box_uuid_array+=("$(uuidgen)")
    fi
    is_valid_uuid() {
        local uuid=$1
        if [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
            return 0  
        else
            return 1
        fi
    }
    valid_old_uuid_array=()
    for old_uuid in "${old_uuid_array[@]}"; do
        if is_valid_uuid "$old_uuid"; then
            valid_old_uuid_array+=("$old_uuid")
        else
            echo " - 删除不符合 UUID 规范的内容: $old_uuid"
        fi
    done
    old_uuid_array=("${valid_old_uuid_array[@]}")
    if [ ${#old_uuid_array[@]} -eq 0 ]; then
        old_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m - 输入为空, 已自动生成 1 枚UUID。\e[0m"
    fi
    display_generated_uuids
    xray_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    process_xray_new
    process_xray_old
    process_sing_box
    xray_user_info
    singbox_user_info
    xray_domain_set
    show_all_status
    display_pause_info
}
manual_input_uuids() {
    clear
    path_count=150
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay和Sing-Box中现有的所有用户信息! \e[0m"
    echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
    echo -e "\e[93m请输入新的xRay UUID, 以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        new_uuid_array+=("$uuid")
    done
    if [ ${#new_uuid_array[@]} -eq 0 ]; then
        new_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空, 已自动生成 1 枚UUID。\e[0m"
    fi
    echo -e "\e[93m请输入老的xRay UUID, 以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        old_uuid_array+=("$uuid")
    done
    if [ ${#old_uuid_array[@]} -eq 0 ]; then
        old_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空, 已自动生成 1 枚UUID。\e[0m"
    fi
    echo -e "\e[93m请输入新的Sing-Box UUID, 以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        box_uuid_array+=("$uuid")
    done
    if [ ${#box_uuid_array[@]} -eq 0 ]; then
        box_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空, 已自动生成 1 枚UUID。\e[0m"
    fi
    display_generated_uuids
    xray_config_files
    singbox_config_files
    process_xray_new
    process_xray_old
    process_sing_box
    xray_user_info
    singbox_user_info
    xray_domain_set
    show_all_status
    display_pause_info
}
display_generated_uuids() {
    clear
    new_uuid_count=${#new_uuid_array[@]}
    old_uuid_count=${#old_uuid_array[@]}
    box_uuid_count=${#box_uuid_array[@]}
    if [ "$new_uuid_count" -ge "$old_uuid_count" ] && [ "$new_uuid_count" -ge "$box_uuid_count" ]; then
        count=$new_uuid_count
    elif [ "$old_uuid_count" -ge "$new_uuid_count" ] && [ "$old_uuid_count" -ge "$box_uuid_count" ]; then
        count=$old_uuid_count
    else
        count=$box_uuid_count
    fi
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}=";
    done
    echo -e "${reset_color}"
    printf "\e[1;32m%66s%s\e[0m\n" "" "已生成的新UUID清单"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}-";
    done
    echo -e "${reset_color}"
    printf "%-3s %-50s %-3s %-50s %-3s %-45s\n" "No." "xRay New" "No."  "xRay Old" "No."  "Sing-Box"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}-";
    done
    echo -e "${reset_color}"
    for ((i=1; i<=count; i++)); do
        printf "%-3s %-50s %-3s %-50s %-3s %-50s\n" "$i." "${new_uuid_array[i - 1]}" "$i." "${old_uuid_array[i - 1]}" "$i." "${box_uuid_array[i - 1]}"
    done
}
display_one_uuids() {
    clear
    print_array() {
        local label="$1"
        shift
        local array=("$@")
        for ((i = 0; i < repeat_count; i++)); do
            echo -n -e "${light_gray}=";
        done
        echo -e "${reset_color}"
        printf "\e[1;32m%66s%s\e[0m\n" "" "已生成的${label} UUID清单"
        for ((i = 0; i < repeat_count; i++)); do
            echo -n -e "${light_gray}-";
        done
        echo -e "${reset_color}"
        printf "%-3s %-50s\n" "No." "${label}" 
        for ((i=1; i<=${#array[@]}; i++)); do
            item="${array[i - 1]:-}" 
            printf "%-3s %-50s\n" "$i." "$item"
        done
        for ((i = 0; i < repeat_count; i++)); do
            echo -n -e "${light_gray}-";
        done
        echo -e "${reset_color}"
    }
    new_uuid_count=${#new_uuid_array[@]}
    old_uuid_count=${#old_uuid_array[@]}
    box_uuid_count=${#box_uuid_array[@]}
    if [ "$new_uuid_count" -gt 0 ]; then
        print_array "xRay New" "${new_uuid_array[@]}"
    fi
    if [ "$old_uuid_count" -gt 0 ]; then
        print_array "xRay Old" "${old_uuid_array[@]}"
    fi
    if [ "$box_uuid_count" -gt 0 ]; then
        print_array "Sing-Box" "${box_uuid_array[@]}"
    fi
}
display_pause_info() {
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    GREEN='\033[1;32m'
    echo -e "${YELLOW} - 按任意键暂停，回车直接返回，否则将在5秒后自动返回... ${NC}"
    read -t 5 -n 1 -s -r response
    if [ -n "$response" ]; then
        echo -e "${GREEN} - 已暂停，再次按下任意键返回...${NC}"
        read -n 1 -s -r response
    fi
}
base64_uuids() {
    echo " - 请输入要转换的 UUID, 以空行或回车结束"
    while read -r uuid && [ -n "$uuid" ]; do
        your_uuid_array+=("$uuid")
    done
    if [ "${#your_uuid_array[@]}" -ne 0 ]; then
        for ((i=0; i<"${#your_uuid_array[@]}"; i++)); do
            your_uuid="${your_uuid_array[i]}"
            base64_uuid=$(echo -n "$your_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            base64_uuid+="=="
            base64_uuid_array+=("    $base64_uuid") 
        done
        echo -e "BASE64 CODEs:\n"
        for ((i=0; i<"${#base64_uuid_array[@]}"; i++)); do
            echo "${base64_uuid_array[i]}"
        done
        echo -e "\n============操作结束============\n"
    else
        echo -e " - 输入的内容为空或错误, 退出, 请重新选择"
    fi
    display_pause_info
}
reset_xray_files() {
    if [ -e "$xray_config_file" ]; then
        rm -f "$xray_config_file" config.conf
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/config.json > /dev/null 2>&1
        sleep 2
        cd .
        mv config.json "$xray_config_file" -f
    else
        echo " - xRay配置文件不存在，已跳过"
    fi
}
reset_nginx_files() {
    if [ -e "$nginx_config_file" ]; then
        rm -f "$nginx_config_file" nginx.conf
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
        sleep 2
        cd .
        mv nginx.conf "$nginx_config_file" -f
        rm -f "$nginx_index_file" default.conf
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
        sleep 2
        cd .
        mv default.conf "$nginx_index_file" -f
    else
        echo " - Nginx 配置文件不存在，已跳过"
    fi
}
reset_singbox_files() {
    if [ -e "$box_config_file" ]; then
        rm -f "$box_config_file" "config.json"
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/singbox_exp.json > /dev/null 2>&1
        sleep 2
        cd .
        mv singbox_exp.json "$box_config_file" -f
    else
        echo " - Sing-Box配置文件不存在，已跳过"
    fi
}
get_xray_tags() {
    new_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" 2>/dev/null | grep -oP '"tag":\s*"\K[^"]+' | grep -iv "OLD" | grep -iv "api"))
    old_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" 2>/dev/null | grep -oP '"tag":\s*"\K[^"]+' | grep -i "OLD"))
}
process_xray_new() {
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    get_xray_tags
    new_ids=()
    if [ ${#new_tags[@]} -eq 0 ]; then
        echo " - 未发现新用户的标签。退出。"
        exit 0
    fi
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    uuid_arrays=($(echo "${new_uuid_array[@]}" | tr ' ' '\n' | sort -u | grep -v '^[[:space:]]*$' 2>/dev/null))
    json_template_xtls='{"id":"full_uuid","flow":"flow2","email":"short_uuid-VLESS_xTLS","level":0}'
    json_template_vmess='{"id":"full_uuid","email":"short_uuid-tag_name","level":0}'
    json_template_trojan='{"password":"full_uuid","email":"short_uuid-tag_name","level":0}'
    json_template_shadowsocks='{"method":"method_character","password":"base64_uuid","level":0}'
    for current_tag in "${new_tags[@]}"; do
        tag_lowercase=$(echo "$current_tag" | tr '[:upper:]' '[:lower:]')
        tag_name=()
        for ((j=0; j<${#new_uuid_array[@]}; j++)); do
            base64_uuid=$(echo -n "${new_uuid_array[j]}" | base64 | tr -d '/+' | cut -c 1-22)
            base64_uuid+="=="
            short_uuid="${new_uuid_array[j]:0:8}"
            case $tag_lowercase in
                *"vless"*|*"vmess"*)
                    if [[ "$tag_lowercase" != *"xtls"* ]]; then
                        current_template="$(echo "$json_template_vmess" | sed -e "s/full_uuid/${new_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                        tag_name+=("$current_template")
                    else
                        current_template="$(echo "$json_template_xtls" | sed -e "s/full_uuid/${new_uuid_array[j]}/" -e "s/flow2/$flow/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                        tag_name+=("$current_template")
                    fi
                    ;;
                *"trojan"*)
                    current_template="$(echo "$json_template_trojan" | sed -e "s/full_uuid/${new_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                    tag_name+=("$current_template")
                    ;;
                *"shadowsocks"*)
                    current_template="$(echo "$json_template_shadowsocks" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid[0]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                    tag_name+=("$current_template")
                    ;;
            esac
        done
        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            found=$(sed -n "/\"tag\": \"$tag_lowercase\"/I,/]/p" "$xray_config_file")
            if [ -n "$found" ]; then
                sed -i "/\"tag\": \"$tag_lowercase\"/I,/]/ {
                    /\"clients\": \[/ {
                        N
                        a \        \"clients\": \[
                        r /dev/stdin
                        d
                    }
                }" "$xray_config_file" <<< "$tag_name_str_escaped"
            fi
        fi
    done
    for unique_id in "${unique_new_ids[@]}"; do
        if [[ " ${uuid_arrays[*]} " == " $unique_id " ]]; then
            unique_new_ids=("${unique_new_ids[@]/$unique_id}")
        fi
    done
    for ((i = 0; i < ${#unique_new_ids[@]}; i++)); do
        if [[ "${unique_new_ids[i]}" =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        base64_encoded_id=$(echo -n "${unique_new_ids[i]}" | base64)
        if [ -n "$base64_encoded_id" ]; then
            modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
            sed -i "/${unique_new_ids[$i]}/d; /$modified_base64_id/d" "$xray_config_file"
        fi
    done
}
process_xray_old() {
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    get_xray_tags
    old_ids=()
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo " - 未发现老用户的标签。退出。"
        exit 0
    fi
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${old_ids[*]} " == " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | awk NF | tr ' ' '\n' | sort -u | tr '\n' ' '))
    uuid_arrays=($(echo "${old_uuid_array[@]}" | tr ' ' '\n' | sort -u | grep -v '^[[:space:]]*$' 2>/dev/null))
    json_template_xtls='{"id":"full_uuid","flow":"flow2","email":"short_uuid-VLESS_xTLS","level":0}'
    json_template_vmess='{"id":"full_uuid","email":"short_uuid-tag_name","level":0}'
    json_template_trojan='{"password":"full_uuid","email":"short_uuid-tag_name","level":0}'
    json_template_shadowsocks='{"method":"method_character","password":"base64_uuid","level":0}'
    for current_tag in "${old_tags[@]}"; do
        tag_lowercase=$(echo "$current_tag" | tr '[:upper:]' '[:lower:]')
        tag_name=()
        for ((j=0; j<${#old_uuid_array[@]}; j++)); do
            base64_uuid=$(echo -n "${old_uuid_array[j]}" | base64 | tr -d '/+' | cut -c 1-22)
            base64_uuid+="=="
            short_uuid="${old_uuid_array[j]:0:8}"
            case $tag_lowercase in
                *"vless"*|*"vmess"*)
                    if [[ "$tag_lowercase" != *"xtls"* ]]; then
                        current_template="$(echo "$json_template_vmess" | sed -e "s/full_uuid/${old_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                        tag_name+=("$current_template")
                    else
                        current_template="$(echo "$json_template_xtls" | sed -e "s/full_uuid/${old_uuid_array[j]}/" -e "s/flow2/$flow/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                        tag_name+=("$current_template")
                    fi
                    ;;
                *"trojan"*)
                    current_template="$(echo "$json_template_trojan" | sed -e "s/full_uuid/${old_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                    tag_name+=("$current_template")
                    ;;
                *"shadowsocks"*)
                    current_template="$(echo "$json_template_shadowsocks" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid[0]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),"
                    tag_name+=("$current_template")
                    ;;
            esac
        done
        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            found=$(sed -n "/\"tag\": \"$tag_lowercase\"/I,/]/p" "$xray_config_file")
            if [ -n "$found" ]; then
                sed -i "/\"tag\": \"$tag_lowercase\"/I,/]/ {
                    /\"clients\": \[/ {
                        N
                        a \        \"clients\": \[
                        r /dev/stdin
                        d
                    }
                }" "$xray_config_file" <<< "$tag_name_str_escaped"
            fi
        fi
    done
    for unique_id in "${unique_old_ids[@]}"; do
        if [[ " ${uuid_arrays[*]} " == " $unique_id " ]]; then
            unique_old_ids=("${unique_old_ids[@]/$unique_id}")
        fi
    done
    for ((i = 0; i < ${#unique_old_ids[@]}; i++)); do
        if [[ "${unique_old_ids[i]}" =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        base64_encoded_id=$(echo -n "${unique_old_ids[i]}" | base64)
        if [ -n "$base64_encoded_id" ]; then
            modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
            sed -i "/${unique_old_ids[$i]}/d; /$modified_base64_id/d" "$xray_config_file"
        else
            echo "跳过空的 base64_encoded_id 行: ${unique_old_ids[$i]}"
        fi
    done
}
process_sing_box() {
    box_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' ))
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    all_passwords=()
    if [ ${#box_tags[@]} -eq 0 ]; then
        echo " - 未发现用户的标签。退出。"
        exit 0
    fi
    for i in "${!box_tags[@]}"; do
        current_tag=${box_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${box_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        passwords=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/s/.*\"password\":\"\(.*\)\".*/\1/p" "$box_config_file"))
        all_passwords+=("${passwords[@]}")
    done
    #unique_box_ids=($(echo "${all_passwords[@]}" | tr ' ' '\n' | awk '!a[$0]++'))
    unique_box_ids=($(echo "${all_passwords[@]}" | tr ' ' '\n' | grep -v '^\s*$' | awk '!a[$0]++'))
    for unique_boxid in "${box_uuid_array[@]}"; do
        if [[ " ${unique_old_ids[*]} " == " $unique_boxid " ]]; then
            box_uuid_array=("${box_uuid_array[@]/$unique_boxid}")
        fi
    done
    box_uuid_array=($(echo "${box_uuid_array[@]}" | tr ' ' '\n' | sort -u | grep -v '^[[:space:]]*$' 2>/dev/null))
    json_template_trojan='{"name":"nruan","password":"full_uuid"}'
    json_template_vmess='{"name":"nruan","uuid":"full_uuid","alterId":0}'
    json_template_vless='{"name":"nruan","uuid":"full_uuid","flow":""}'
    json_template_tuic='{"name":"nruan","uuid":"full_uuid","password":"base64_uuid"}'
    json_template_naive='{"username":"nruan","password":"full_uuid"}'
    json_template_shadowsocks='{"name":"nruan","password":"base64_uuid"}'
    for current_tag in "${box_tags[@]}"; do
        tag_lowercase=$(echo "$current_tag" | tr '[:upper:]' '[:lower:]')
        tag_name=()
        for ((j=0; j<${#box_uuid_array[@]}; j++)); do
            base64_uuid=$(echo -n "${box_uuid_array[j]}" | base64 | tr -d '/+' | cut -c 1-22)
            base64_uuid+="=="
            short_uuid="${box_uuid_array[j]:0:8}"
            case $tag_lowercase in
                *"trojan"*|*"hysteria2"*)
                    current_template="$(echo "$json_template_trojan" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),"
                    tag_name+=("$current_template")
                    ;;
                *"vless"*)
                    current_template="$(echo "$json_template_vless" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),"
                    tag_name+=("$current_template")
                    ;;
                *"vmess"*)
                    current_template="$(echo "$json_template_vmess" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),"
                    tag_name+=("$current_template")
                    ;;
                *"naive"*)
                    current_template="$(echo "$json_template_naive" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),"
                    tag_name+=("$current_template")
                    ;;
                *"tuic"*)
                    current_template="$(echo "$json_template_tuic" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/" -e "s/base64_uuid/${base64_uuid[0]}/"),"
                    tag_name+=("$current_template")
                    ;;
                *"shadowsocks"*)
                    current_template="$(echo "$json_template_shadowsocks" | sed  -e "s/nruan/$short_uuid/" -e "s/base64_uuid/${base64_uuid[0]}/"),"
                    tag_name+=("$current_template")
                    ;;
            esac
        done
        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            found=$(sed -n "/\"tag\": \"$tag_lowercase\"/I,/]/p" "$box_config_file")
            if [ -n "$found" ]; then
                sed -i "/\"tag\": \"$tag_lowercase\"/I,/]/ {
                    /\"users\": \[/ {
                        N
                        a \        \"users\": \[
                        r /dev/stdin
                        d
                    }
                }" "$box_config_file" <<< "$tag_name_str_escaped"
            fi
        fi
    done
    for unique_id in "${unique_box_ids[@]}"; do
        if [[ " ${box_uuid_array[*]} " == " $unique_id " ]]; then
            unique_box_ids=("${unique_box_ids[@]/$unique_id}")
        fi
    done
    unique_box_ids=($(echo "${unique_box_ids[@]}" | tr ' ' '\n' | sort -u | grep -v '^[[:space:]]*$' 2>/dev/null))
    for ((i = 0; i < ${#unique_box_ids[@]}; i++)); do
        if [[ "${unique_box_ids[i]}" =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        base64_encoded_id=$(echo -n "${unique_box_ids[i]}" | base64)
        if [ -n "$base64_encoded_id" ]; then
            modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
            sed -i "/${unique_box_ids[$i]}/d; /$modified_base64_id/d" "$box_config_file"
        fi
    done
}
xray_user_info() {
    get_xray_tags
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "xRay 新用户信息 (左边是除 ShadowSocks 之外的 UUID)"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}+"; done; echo -e "${reset_color}"
    if [ ${#new_tags[@]} -eq 0 ]; then
        echo " - 未发现新用户的标签。退出。"
        exit 0
    fi
    all_ids=()
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${all_ids[*]} " == " $id " ]]; then
                all_ids+=("$id")
            fi
        done
    done
    unique_ids=($(echo "${all_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    printf "\e[1m%-5s %-50s %s\e[0m\n" "No." "UUID for other" "Password For ShadowSocks"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for ((i = 0; i < ${#unique_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)==
        printf "%-5s %-50s %s\n" "$((i+1))." "${unique_ids[$i]}" "$modified_base64_id"
        if [ $i -lt $(( ${#unique_ids[@]} - 1 )) ]; then
            for ((j = 0; j < repeat_count; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
        fi
    done
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "xRay 老用户信息 (左边是除 ShadowSocks 之外的 UUID)"
    all_ids=()
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}+"; done; echo -e "${reset_color}"
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo " - 未发现老用户的标签。退出。"
        exit 0
    fi
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${all_ids[*]} " == " $id " ]]; then
                all_ids+=("$id")
            fi
        done
    done
    unique_ids=($(echo "${all_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    printf "\e[1m%-5s %-50s %s\e[0m\n" "No." "UUID for other" "Password For ShadowSocks"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for ((i = 0; i < ${#unique_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)==
        printf "%-5s %-50s %s\n" "$((i+1))." "${unique_ids[$i]}" "$modified_base64_id"
        if [ $i -lt $(( ${#unique_ids[@]} - 1 )) ]; then
            for ((j = 0; j < repeat_count; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
        fi
    done
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
}
singbox_user_info() {
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    base64_names=()
    tag_box="Sing-Box   "
    uuid_info=("Trojan / Vmess /Vless / Tuic / Naive / Hysteria2   UUID"   "ShadowSocks / Tuic BASE64 Password")
    ks=0
    for tag in "vless" "shadowsocks"; do
        [[ "$tag" == "vless" ]] && base64_names=("${names[@]}")
        [[ "$tag" == "shadow"* ]] && base64_names=($(for uuid in "${names[@]}"; do uuid_to_base64 "$uuid"; done))
        for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
        printf "\e[1;32m%$((45 + (ks + 1) * 10))s%s\e[0m\n" "$tag_box" "${uuid_info[ks]}"
        for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        for ((i = 0; i < ${#base64_names[@]}; i += 3)); do
            for ((j = 0; j < 3 && i + j < ${#base64_names[@]}; j++)); do
                printf "%02d. %-50s" "$((i + j + 1))" "${base64_names[i + j]}"
            done
            echo
            [[ $((i + 3)) -lt ${#base64_names[@]} ]] && { for ((k = 0; k < repeat_count; k++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"; }
        done
        ks=$((ks + 1))
    done
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
}
status_all() {
    printf "%-50s %-50s %-45s\n" "$nginx_status" "$xray_status" "$box_status" 
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
}
show_singbox_setting() {
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%60s""Sing-Box 配置清单\n"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-18s %-8s %-28s %-6s %-20s %-32s %-20s\e[0m\n" "No." "Protocol" "Ports" "Domains or sni" "Type" "Path" "Password" "Method"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
        type_t=$(echo "$content" | grep -oP '"type":\s*"\K[^\"]+' | sed -n '2p')
        Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
         [[ $type_t == *'ws'* ]] && type_x="ws" || type_x=""
        if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            method_t=$(echo "$content" | grep -oP '"method":\s*"\K[^\"]+' | head -n1)
        else
            password_t=""
            method_t=""
        fi
        if [ "$current_tag" == "tuic" ] ; then
            password_t=$'\e[93m与用户UUID对应的BASE64\e[0m'
        fi
        if [ "$current_tag" == "shadowsocks" ] ; then
            Domain_t=$Domain_tb
        fi
        Domain_tb=$Domain_t
        echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
        printf "%-3s %-18s %-8s %-28s %-6s %-20s %-32s %-20s\n" "$((i+1))." "${type[i]}" "${ports[i]}" "$Domain_t" "$type_x" "$path_t" "$password_t" "$method_t"
        [ -n "$line_cont" ] && for ((j = 0; j < repeat_count; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}" || echo -e "${reset_color}"
    done | sed '$d'
}
show_xray_setting() {
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol":\s*"\K[^"]+'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"port":\s*\K[^,]+'))
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%60s""xRay 配置清单\n"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-22s %-18s  %-10s %-20s %-15s\e[0m\n" "No." "Name"  "Protocol" "Ports" "Path" "Method"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [ "${type[i]}" != "dokodemo-door" ]; then
            ports[i]="443"
        fi
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
        fi
        if [[ "${tags[i]}" == *xTLS* ]]; then
            path_t=""
        fi
        printf "%-3s " "$((i+1))."
        printf "%-22s " "${tags[i]}"
        printf "%-18s " "${type[i]}"
        printf "%-10s " "${ports[i]}"
        printf "%-20s" "$path_t"
        printf "%-20s\n" "$method_t"
            if [ -n "$line_cont" ]; then
                for ((j = 0; j < repeat_count; j++)); do
                    echo -n -e "${dark_gray}·"
                done
                echo -e "${reset_color}"
            else
                for ((j = 0; j < repeat_count; j++)); do
                    echo -n -e "${light_gray}="
                done
                echo
            fi
        done
    printf "\n"
}
install_xRay_SingBox() {
    GREEN='\033[0;32m'
    NC='\033[0m'
    rm -rf /etc/nginx/conf.d/*.*
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root > /dev/null 2>&1
    apt -y update
    clear
    echo -e "\n\e[1;32m  - 正在安装相关软件及依赖包, 首次安装时间比较久, 请耐心等待...\e[0m\n"
    echo -e "\e[1;33m  - 超过15分钟无反应, 请重启系统后, 再运行 nruan 进行安装\e[0m\n"
    echo -e "\e[1;32m  - 当前时间: \e[0m $(date -u +"%Y-%m-%d %H:%M:%S") UTC\n"
    packages=("curl" "wget" "jq" "socat" "net-tools" "uuid-runtime" "dnsutils" "lsof" "build-essential" "libssl-dev" "libevent-dev" "zlib1g-dev" "gcc-mingw-w64" "nginx")
    for package in "${packages[@]}"
    do
        apt -y install "$package" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}- 成功安装 $package${NC}"
        else
            echo "  * 安装 $package 失败 "
        fi
    done
    echo ""
    useradd nginx -s /sbin/nologin -M > /dev/null 2>&1
    bash <(curl -fsSL https://sing-box.app/deb-install.sh)> /dev/null 2>&1
    mkdir -p /usr/local/etc
    mkdir -p /etc/sing-box/
    systemctl daemon-reload > /dev/null
    systemctl status nginx > /dev/null
    systemctl status xray > /dev/null
    systemctl status sing-box > /dev/null
    config_files
    reset_xray_files
    reset_nginx_files
    reset_singbox_files
    display_pause_info
}
domain_input(){
    curl -s https://get.acme.sh | sh > /dev/null 2>&1
    sudo apt-get install -y dnsutils > /dev/null 2>&1
    clear
    tls_directory="/etc/tls"
    mkdir -p "$tls_directory/log"
    for ((j = 0; j < 100; j++)); do echo -n -e "\e[93m="; done; echo -e "\e[0m"
    suffix=$((RANDOM % 10))
    generate_domains() {
        local prefix=$1
        local domain=$2
        for i in {0..9}; do
            echo "${prefix}${i}.${domain}"
        done
    }
    prefix=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 3 | tr '[:upper:]' '[:lower:]')
    column1=($(generate_domains "$prefix" "expdomain.com"))
    column2=($(generate_domains "$prefix" "expdomain.org"))
    column3=($(generate_domains "$prefix" "expdomain.net"))
    column4=($(generate_domains "$prefix" "expdomain.edu"))
    echo -e "   输入的清单中\e[1;32m至少包含\e[0m一个\e[1;91m未开CDN的域名\e[0m, 如 ${column1[$suffix]} 未开CDN。"
    echo -e "   参考列表如下: "
    for i in {0..9}; do
    if [[ $i -eq 0 ]]; then
        printf "     \e[90m%-20s %-20s %-20s %-20s \e[0m\n" "${column1[$i]}" "${column2[$i]}" "${column3[$i]}" "${column4[$i]}"
    else
        printf "     \e[90m%-20s %-20s %-20s %-20s \e[0m\n" "${column1[$i]}" "${column2[$i]}" "${column3[$i]}" "${column4[$i]}" 
    fi
    done
    echo -e "   确保\e[1;32m每个子域名所含的前缀解析\e[0m是一致的。"
    echo -e "   如${column2[$suffix]} 解析到了${column1[$suffix]} 的ip, 前者开了CDN。"
    echo -e "   如expdomain.net中有${column3[$suffix]} 子域名解析到了\e[1;91m${column1[$suffix]}\e[0m的ip, 前者开了CDN。"
    for ((j = 0; j < 100; j++)); do echo -n -e "\e[90m."; done; echo -e "\e[0m"
    echo -e "   \e[93m--本功能可以获取开了云朵的域名Let's证书\e[0m"
    echo -e "   以上操作主要是有多个域名的情况下, 在域名服务商处可以\e[1;32m批量导入\e[0m解析, 如Cloudflare, 参考如下:"
    echo -e "\e[90m     ;; A Records\e[0m"
    for i in {0..9}; do
    subdomain="${prefix}${i}"
    random_ip=$(shuf -i 1-255 -n 4 | tr '\n' '.')
    random_ip=${random_ip%?}
    echo -e "\e[90m     $subdomain	1	IN	A	${random_ip}\e[0m"
    done
    echo -e "   把上面这种格式的文件分别导入到(expdomain.org、expdomain.net)DNS记录中, 可与本脚本匹配使用。"
    echo -e "   具体操作方式, 可以自行搜索, 或者查看本脚本在Github上的说明档。"
    echo -e "   \e[93m此脚本未使用单域名别名（同一个IP用同一域名子域名）功能, 可以用CF的Workers解决\e[0m"
    for ((j = 0; j < 100; j++)); do echo -n -e "\e[90m."; done; echo -e "\e[0m"
    echo -e "   因为Sing-Box的特殊性, 以及某些协议不能走ws, 请确保\e[1;91m至少有一个域名\e[0m是不开CDN的域名）"
    echo -e "   \e[93m注: \e[0mSing-Box的端口与xRay是独立的, 如果需要, 请自行在\e[1;91mCloudflare\e[0m平台配置\e[1;32mWorkers\e[0m使用。"
    for ((j = 0; j < 100; j++)); do echo -n -e "\e[93m="; done; echo -e "\e[0m"
    echo -e "  请输入你的\e[1;32m域名列表\e[0m, 以空行结束（可以很多行, Excel可直接复制粘贴）"
    function print_columns_with_parentheses() {
        local array=("$@")
        local max_length=0
        for element in "${array[@]}"; do
            if [ "${#element}" -gt "$max_length" ]; then
                max_length=${#element}
            fi
        done
        local num_columns=$(( ($(tput cols) + 1) / (max_length + 4) ))
        local seq_num=1
        for ((i = 0; i < ${#array[@]}; i += num_columns)); do
            for ((j = 0; j < num_columns && i + j < ${#array[@]}; j++)); do
                local index=$((i + j))
                printf "%2d) %-$((max_length+2))s" "$((seq_num + index))" "${array[index]}"
            done
            echo
        done
    }
    domains=()
    invalid_domains=()
    echo -e "\e[93m  * 每行可以包含任意数量的域名(自动检查域名格式), 类似例中所有的域名都可以同时粘贴到SSH窗口中。\e[0m"
    if [ ${#input_domains[@]} -gt 0 ]; then
            for domain_input in "${input_domains[@]}"; do
                if [[ $domain_input =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    domains+=("$domain_input")
                else
                    invalid_domains+=("$domain_input")
                fi
            done
    else
        while IFS= read -r line && [ -n "$line" ]; do
            IFS=$' \t,' read -ra line_array <<< "$line"
            for domain_input in "${line_array[@]}"; do
                if [[ $domain_input =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    domains+=("$domain_input")
                else
                    invalid_domains+=("$domain_input")
                fi
            done
        done
    fi
    domains=($(echo "${domains[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    invalid_domains=($(echo "${invalid_domains[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    clear
    if [ ${#domains[@]} -gt 0 ]; then
        echo -e "\e[92m格式有效的域名:\e[0m"
        print_columns_with_parentheses "${domains[@]}"
    fi
    if [ ${#invalid_domains[@]} -gt 0 ]; then
        echo -e "\n\e[91m格式无效的域名:\e[0m"
        print_columns_with_parentheses "${invalid_domains[@]}"
    fi


    if [ ${#domains[@]} -gt 0 ]; then
        matched_prefix=""
        matched_domain=""
        full_domain=""
        local_ip=$(curl -s ifconfig.me)
        echo ""
        echo -e "\e[1;32m - 正在检测域名与IP匹配情况, 请稍候...\e[0m"
        match_found=false
        for domain in "${domains[@]}"; do
            result=($(dig +short "$domain" | tr -d '[:space:]'))
            if [ "$match_found" == true ]; then break; fi
            for ip in "${result[@]}"; do
                if [ "$ip" == "$local_ip" ]; then
                    match_found=true
                    full_domain=$domain
                    matched_prefix=$(echo "$domain" | awk -F'.' '{print $1}')
                    matched_domain=$(echo "$domain" | sed "s/$matched_prefix\.//")
                    break
                fi
            done
        done
        
        processed_domains=()
        unique_domains_new=()
        unique_domains_nginx=()
        if [ "$match_found" = true ]; then
            for domain in "${domains[@]}"; do
                dot_count=$(echo "$domain" | grep -o '\.' | wc -l)
                if [ "$dot_count" -lt 2 ]; then
                    processed_domains+=($domain)
                else
                    processed_domains+=("$(echo "$domain" | sed 's/^[^.]*\.//')")
                fi
            done
            unique_domains=($(echo "${processed_domains[@]}" | tr ' ' '\n' | sort -u))
            for prefix in "${unique_domains[@]}"; do
                if [ "$prefix" != "$matched_domain" ]; then
                    domain="$matched_prefix.$prefix"
                    result=($(dig +short "$domain" | tr -d '[:space:]'))
                    if [ ${#result[@]} -gt 0 ]; then
                        unique_domains_new+=("$matched_prefix.$prefix")
                        unique_domains_nginx+=("*.$prefix")
                    fi
                fi
            done
        fi
    else
        echo -e "\e[1;91m - 没有可操作的域名。请确保解析已生效，并重试！\e[0m"
        return 0
    fi
    if [ "$match_found" = true ]; then
        echo -e "\e[1;32m - 当前匹配域名: $full_domain\e[0m"
        echo -e "\e[1;91m - 清空/etc/tls目录\e[0m"
        mkdir -p /etc/tls 
        mkdir -p /var/www
        mkdir -p /var/www/letsencrypt
        systemctl stop nginx > /dev/null 2>&1
        if [ -n "$full_domain" ]; then
            if [ -e "/root/.acme.sh/${full_domain}_ecc/fullchain.cer" ]; then
                echo -e "\e[1;32m * 当前域名 $full_domain 已存在 TLS 证书  \e[0m"
            else
                echo -e "\e[1;32m - 停止Nginx成功\e[0m" 
                echo -e "\e[93m - 正在尝试acme申请 TLS 证书，过程稍长，大约5分钟。请稍后。\e[0m"
                sudo ~/.acme.sh/acme.sh --register-account -m admin@"$full_domain" 2>&1 | sudo tee -a "/etc/tls/log/$full_domain.log"
                sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 --standalone 2>&1 | sudo tee -a "/etc/tls/log/$full_domain.log" 
            fi
            if [ -e "/root/.acme.sh/${full_domain}_ecc/fullchain.cer" ]; then
                sudo ~/.acme.sh/acme.sh --installcert -d "$full_domain" --fullchainpath "/etc/tls/$full_domain.crt" --keypath "/etc/tls/$full_domain.key" >/dev/null 2>&1
                echo -e "\e[1;93m - 证书成功安装。\e[0m" 
                else
                echo -e " - \e[1;31m证书申请失败，日志已保存在 /etc/tls/log/$full_domain.log \e[0m"
            fi
        fi
    fi
    if [ ${#domains[@]} -gt 0 ]; then
        if [ "$match_found" = false ]; then
            unique_domains_new=("${domains[@]}")
        fi
        if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
            config_files
            nginx_cert_path="/etc/nginx/cert"
            cert_path="$nginx_cert_path/$full_domain.crt"
            key_path="$nginx_cert_path/$full_domain.key"
            if [ -e "/root/.acme.sh/${full_domain}_ecc/fullchain.cer" ]; then
                echo -e ""
            else
                echo -e "\e[1;91m - $full_domain TLS证书申请失败, 尝试为Nginx申请自签名证书\e[0m"
                sudo mkdir -p "$nginx_cert_path"
                config_files=$(find / -type f -path "*nginx/nginx.conf" 2>/dev/null)
                if [ -n "$config_files" ]; then
                    if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
                        nginx_config_file=$config_files
                    else
                        echo -e "\e[93m - 系统中存在多个 Nginx 网站的配置, 请在以下配置文件中选择:\e[0m"
                        options=($config_files)
                        select choice in "${options[@]}"; do
                            if [ -n "$choice" ]; then
                                echo "您选择了文件: $choice"
                                nginx_config_file=$choice
                                echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的nginx.conf\e[92m文件\e[0m"
                                break
                            else
                                echo " - 无效的选择, 请重新选择。"
                            fi
                        done
                    fi
                else
                    nginx_config_file="/etc/nginx/nginx.conf"
                fi
                config_files=$(find / -type f -path "*conf.d/default.conf" 2>/dev/null)
                if [ -n "$config_files" ]; then
                    if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
                        nginx_index_file=$config_files
                    else
                        echo -e "\e[93m - 系统中存在多个 Nginx 网站的配置, 请在以下配置文件中选择:\e[0m"
                        options=($config_files)
                        select choice in "${options[@]}"; do
                            if [ -n "$choice" ]; then
                                echo "您选择了文件: $choice"
                                nginx_index_file=$choice
                                echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的default.conf\e[92m文件\e[0m"
                                break
                            else
                                echo " - 无效的选择, 请重新选择。"
                            fi
                        done
                    fi
                else
                    nginx_index_file="/etc/nginx/conf.d/default.conf"
                fi
                echo -e "\e[1;32m - 生成 $full_domain 自签名证书\e[0m"
                openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout "$key_path" -out "$cert_path" -subj "/CN=$full_domain" > /dev/null 2>&1
                chmod 777 "$cert_path"
                chmod 777 "$key_path"
                echo -e "\e[1;91m - 生成 $full_domain 自签名证书生成完毕\e[0m"
                echo -e "\e[1;93m - 正在配置Nginx使用自签证书相关内容 \e[0m"
                rm -rf "$nginx_config_file" nginx.conf
                wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
                mv nginx.conf "$nginx_config_file"
                sed -i "s/yourdomain\.com/$full_domain/g" "$nginx_config_file"
                rm -rf "$nginx_index_file" default.conf
                wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
                mv default.conf "$nginx_index_file"
                rm -rf /etc/tls/domain.tw.key
                rm -rf /etc/tls/domain.tw.crt 
                rm -rf /etc/tls/domain2.tw.key
                rm -rf /etc/tls/domain2.tw.crt
                cp "$key_path" /etc/tls/domain.tw.key
                cp "$cert_path" /etc/tls/domain.tw.crt
                cp "$key_path" /etc/tls/domain2.tw.key
                cp "$cert_path" /etc/tls/domain2.tw.crt
                systemctl stop nginx xray > /dev/null 2>&1
                systemctl start nginx xray > /dev/null 2>&1
                echo -e "\e[1;32m - Nginx配置已更新, 已使用自签名证书\e[0m"
                    if [ "$match_found" = true ]; then
                        unique_domains_new+=("$full_domain")
                    fi
            fi
        fi
        systemctl start nginx > /dev/null 2>&1
        [ ${#unique_domains_new[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
            echo -e "\e[1;31m - 启动Nginx成功\e[0m" 
            printf '%.s-' {1..88} && echo
            echo  " - 将为以下域名申请TLS证书："
            echo  " - ${unique_domains_new[@]}"
            printf '%.s-' {1..88} && echo
        for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
            mkdir -p /etc/tls 
            mkdir -p /var/www
            mkdir -p /var/www/letsencrypt
            echo -e "\e[1;93m - 尝试通过 Nginx 申请证书的域名: ${unique_domains_new[i]}\e[0m"
            if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
                echo -e "\e[1;32m * 当前域名 ${unique_domains_new[i]} 已存在TLS证书  \e[0m"
                else
                sudo ~/.acme.sh/acme.sh --register-account -m admin@${unique_domains_new[i]} > /dev/null 2>&1
                sudo ~/.acme.sh/acme.sh --issue -d ${unique_domains_new[i]} -w /var/www/letsencrypt 2>&1 | sudo tee -a "/etc/tls/log/${unique_domains_new[i]}.log"
            fi
            if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
                echo -e "\e[1;32m - 当前域名 ${unique_domains_new[i]} TLS证书安装成功。\e[0m"
                sudo ~/.acme.sh/acme.sh --installcert -d "${unique_domains_new[i]}" --fullchainpath "/etc/tls/${unique_domains_new[i]}.crt" --keypath "/etc/tls/${unique_domains_new[i]}.key" > /dev/null 2>&1
                else
                echo -e " - \e[1;31m证书申请失败，日志已保存在 /etc/tls/log/${unique_domains_new[i]}.log \e[0m"
            fi
        done
        [ -e "/etc/tls/domain.tw.key" ] && rm -rf /etc/tls/domain.tw.key
        [ -e "/etc/tls/domain.tw.crt" ] && rm -rf /etc/tls/domain.tw.crt
        [ -e "/etc/tls/domain2.tw.key" ] && rm -rf /etc/tls/domain2.tw.key
        [ -e "/etc/tls/domain2.tw.crt" ] && rm -rf /etc/tls/domain2.tw.crt
        [ ${#unique_domains_new[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
        for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
            if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
                :
            else
                sudo rm -f "/etc/tls/${unique_domains_new[i]}.key" "/etc/tls/${unique_domains_new[i]}.crt" > /dev/null 2>&1
            fi
        done
        if [ -d "$tls_directory" ] && \
        (find "$tls_directory" -maxdepth 1 -type f \( -name "*.crt" -o -name "*.key" \) | read); then
        all_domains=($(ls -1 "$tls_directory"/*.crt 2>/dev/null | xargs -n1 basename | sed 's/\.crt//'))
        sorted_domains=($(printf "%s\n" "${all_domains[@]}" | sort))
        max_length=0
            for domain in "${sorted_domains[@]}"; do
                length=${#domain}
                if [ "$length" -gt "$max_length" ]; then
                max_length="$length"
                fi
            done
            echo -e "\e[1;31m当前已保存的域名TLS证书及有效期:\e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
            i=0
            for domain in "${sorted_domains[@]}"; do
                i=$((i+1))
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("\e[1;32m$i) $domain - TLS\e[0m")
                is_tls="TLS"
                color_code="\e[1;32m"
                else
                cdn_domains+=("\e[1;33m$i) $domain - CDN\e[0m")
                is_tls="CDN"
                color_code="\e[1;33m"
                fi
                if openssl x509 -in "$tls_directory/$domain.crt" -noout -dates &>/dev/null; then
                start_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
                end_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
                if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                    start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                    end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                    printf "${color_code}%2s) %-$((max_length + 5))s - %s   - 证书有效期: %s 至 %s\e[0m\n" "$i" "$domain" "$is_tls" "$start_date" "$end_date"
                else
                    echo "日期解析失败: $domain" >&2
                fi
                else
                echo "无法读取证书或证书无效: $domain" >&2
                fi
            done
            for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
        fi
    fi
}
singbox_domain_set() {
    path_count=88
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    max_length=0
    selected_domain_or_tls
    tls_directory="/etc/tls"
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    full_domain=$selected_domain
    sb_sn=($(grep -oP '"server_name":\s*"\K[^"]+' "$box_config_file"))
    sbsn_new=($(echo "${sb_sn[@]}" | tr ' ' '\n' | sort -u))
    for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e ""
    echo -e " - \e[91m已在Sing-Box配置文件中的域名:\e[0m"
    for element in "${sbsn_new[@]}"; do
        printf "%s\n" "   $element"
    done
    match_count=0
    for sn in "${sbsn_new[@]}"; do
        matched=false
        for ((i=0; i<${#full_domain[@]}; i++)); do
            if [[ "${full_domain[$i]}" == *"$sn"* ]]; then
                matched=true
                break
            fi
        done
        if [ "$matched" = false ]; then
            sed -i "s/$sn/$full_domain/g" "$box_config_file"
            sed -i '/"certificate_path"/d' "$box_config_file"
            sed -i "/\"key_path\"/i \\\t        \"certificate_path\": \"/etc/tls/$full_domain.crt\"," "$box_config_file"
            sed -i '/"key_path"/d' "$box_config_file"
            sed -i "/\"certificate_path\"/a \\\t        \"key_path\": \"/etc/tls/$full_domain.key\"" "$box_config_file"
            ((match_count++))
        else
            for ((j = 0; j < path_count; j++)); do echo -n -e "-"; done; echo -e ""
            echo -e " - \e[92mSing-Box证书和域名配置正确, 无需操作。当前域名:\e[0m $full_domain"
            echo -e " - \e[92m当前Sing-Box证书路径: \e[0m/etc/tls/$full_domain.crt \e[92m|\e[0m /etc/tls/$full_domain.key"
            for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e ""
        fi
    done
    if [ "$match_count" -ne 0 ]; then
        for ((j = 0; j < path_count; j++)); do echo -n -e "-"; done; echo -e ""
        echo -e " - \e[92m已完成Sing-Box的Server_Name更新: \e[0m$full_domain"
        echo -e " - \e[92m已完成Sing-Box证书路径更新: \e[0m/etc/tls/$full_domain.crt \e[92m|\e[0m /etc/tls/$full_domain.key"
    fi
}
xray_domain_set() {
    cert_names=()
    tls_directory="/etc/tls"
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    original_directory=$(pwd)
    cd /etc/tls || exit
    file_array=()
    for file in *; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            file_array+=("${file_name%.*}")
        fi
    done
    cd "$original_directory" || exit
    unique_array=($(echo "${file_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for ((i=0; i<"${#unique_array[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_array[i]}_ecc/fullchain.cer" ]; then
            cert_names+=(${unique_array[i]})
        else
            sudo rm -f "/etc/tls/${unique_array[i]}.key" "/etc/tls/${unique_array[i]}.crt" > /dev/null 2>&1
        fi
    done
    json_file="/usr/local/etc/xray/xray_domain.json"
    certname=($(ls -1 /etc/tls/*.crt 2>/dev/null | sed 's/.*\/\([^/]*\)\.crt/\1/' | sort -u))
    {
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
    if grep -q '"certificates": \[' "$xray_config_file"; then
        sed -i "/\"certificates\": \[/ r $json_file" "$xray_config_file"
    else
        sed -i "/\"certificates\": {/ r $json_file" "$xray_config_file"
    fi
    certificate_count=$(grep -c "certificateFile" "$xray_config_file")
    last_line=$(grep -n "certificateFile" "$xray_config_file" | tail -n 1 | cut -d ':' -f 1)
    start_line=$((last_line - certificate_count + cert_count + 1))
    sed -i "${start_line},${last_line}d" "$xray_config_file"
    rm -rf "$json_file"
    sudo systemctl restart xray
}
xray_domain_update(){
    cert_names=()
    certname=()
    tls_directory="/etc/tls"
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    original_directory=$(pwd)
    cd /etc/tls || exit
    file_array=()
    for file in *; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            file_array+=("${file_name%.*}")
        fi
    done
    unique_array=($(echo "${file_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for ((i=0; i<"${#unique_array[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_array[i]}_ecc/fullchain.cer" ]; then
            cert_names+=(${unique_array[i]})
        else
            sudo rm -f "/etc/tls/${unique_array[i]}.key" "/etc/tls/${unique_array[i]}.crt" > /dev/null 2>&1
        fi
    done
    cd "$original_directory" || exit
    json_file="/usr/local/etc/xray/xray_domain_updata.json"
    certname=($(ls -1 /etc/tls/*.crt 2>/dev/null | sed 's/.*\/\([^/]*\)\.crt/\1/' | sort -u))
    {
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
    if grep -q '"certificates": \[' "$xray_config_file"; then
        sed -i "/\"certificates\": \[/ r $json_file" "$xray_config_file"
    else
        sed -i "/\"certificates\": {/ r $json_file" "$xray_config_file"
    fi
    certificate_count=$(grep -c "certificateFile" "$xray_config_file")
    last_line=$(grep -n "certificateFile" "$xray_config_file" | tail -n 1 | cut -d ':' -f 1)
    start_line=$((last_line - certificate_count + cert_count + 1))
    sed -i "${start_line},${last_line}d" "$xray_config_file"
    sudo systemctl restart xray > /dev/null 2>&1
    sudo systemctl restart nginx > /dev/null 2>&1
}
nginx_domain_set(){
    if [ -n "$matched_domain" ]; then
        unique_domains_nginx+=("*.$matched_domain")
        declare -A unique_domains_nginx_map
        for domain in "${unique_domains_nginx[@]}"; do
            unique_domains_nginx_map["$domain"]=1
        done
        unique_domains_nginx=("${!unique_domains_nginx_map[@]}")
        rm -rf "$nginx_config_file" nginx.conf
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
        unique_domains_nginx=($(echo "${unique_domains_nginx[@]}" | tr ' ' '\n' | awk '!a[$0]++' | tr '\n' ' '))
        for domain in "${unique_domains_nginx[@]}"; do
            sed -i "/$domain/d" nginx.conf
        done
        for domain in "${unique_domains_nginx[@]}"; do
            sed -i -e "/server_name yourdomain.com/a\\
            server_name $domain;" nginx.conf
        done
        sed -i "/yourdomain.com/d" nginx.conf
        mv nginx.conf "$nginx_config_file" > /dev/null 2>&1
        rm -rf "$nginx_index_file" default.conf
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
        for domain in "${unique_domains_nginx[@]}"; do
            sed -i "/$domain/d" default.conf
        done
        for domain in "${unique_domains_nginx[@]}"; do
            sed -i -e "/server_name yourdomain.com/a\\
            server_name $domain;" default.conf
        done
        sed -i "/yourdomain.com/d" default.conf
        mv default.conf "$nginx_index_file" -f > /dev/null 2>&1
        echo -e " - \e[1;93m Nginx 配置文件中的域名已更新\e[0m"
    fi
    tags=() path_t=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol":\s*"\K[^"]+'))
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
    all_path_t=()
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
    done
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        all_path_t[i]="${all_path_t[i]//\//}"
    done
    common_prefix=$(printf "%s\n" "${all_path_t[@]}" | awk -F "" 'NR==1{p=$0; next} {p=substr(p, 1, length <= length($0) ? length : length($0)); for(i=1;i<=length && substr($0,i,1)==substr(p,i,1);i++); p=substr(p, 1, i-1)} END{print p}')
    sed -i "s#nruan#$common_prefix#g" "$nginx_index_file"
    echo -e " - \e[1;93m Nginx 配置文件中的Path已更新\e[0m"
    sudo systemctl restart nginx xray sing-box
}
modify_tls_for_singbox(){
    path_count=88
    tls_directory="/etc/tls"
    tls_domains=()
    cdn_domains=()
    domains=()  
    local_ip=$(curl -s https://api64.ipify.org)
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -d "$tls_directory" ]; then
        for cert_file in "$tls_directory"/*.crt; do
            if [ -f "$cert_file" ]; then
            domains_array=($(openssl x509 -in "$cert_file" -text -noout | grep DNS | sed 's/ *DNS://'))
            for domain in "${domains_array[@]}"; do
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("$domain")
                else
                cdn_domains+=("$domain")
                fi
            done
            fi
        done
        domains=("${tls_domains[@]}" "${cdn_domains[@]}")
        echo -e " - \e[93m检测到TLS证书的域名:\e[0m"
        echo "--Sing-Box--------------------------"
        printf '   \e[92m%s\n\e[0m' "${domains[@]}"
        echo "------------------------------------"
        else
        echo "Error: Directory $tls_directory does not exist."
    fi
    if [ -z "${tls_domains[0]}" ]; then
        full_domain="${domains[0]}"
        echo -e " - \e[93m不存在非CDN的域名，已使用CDN域名作配置！\e[0m"
    else
        full_domain="${tls_domains[0]}"
    fi
    sb_sn=($(grep -oP '"server_name":\s*"\K[^"]+' "$box_config_file"))
    sbsn_new=($(echo "${sb_sn[@]}" | tr ' ' '\n' | sort -u))
    for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e ""
    echo -e " - \e[91m已在Sing-Box配置文件中的域名:\e[0m"
    for element in "${sbsn_new[@]}"; do
        printf "%s\n" "   $element"
    done
    match_count=0
    for sn in "${sbsn_new[@]}"; do
        matched=false
        for ((i=0; i<${#full_domain[@]}; i++)); do
            if [[ "${full_domain[$i]}" == *"$sn"* ]]; then
                matched=true
                break
            fi
        done
        if [ "$matched" = false ]; then
            sed -i "s/$sn/$full_domain/g" "$box_config_file"
            sed -i '/"certificate_path"/d' "$box_config_file"
            sed -i "/\"key_path\"/i \\\t        \"certificate_path\": \"/etc/tls/$full_domain.crt\"," "$box_config_file"
            sed -i '/"key_path"/d' "$box_config_file"
            sed -i "/\"certificate_path\"/a \\\t        \"key_path\": \"/etc/tls/$full_domain.key\"" "$box_config_file"
            ((match_count++))
        else
            for ((j = 0; j < path_count; j++)); do echo -n -e "-"; done; echo -e ""
            echo -e " - \e[92mSing-Box证书和域名配置正确, 无需操作。当前配置:\e[0m $full_domain"
            echo -e " - \e[92m当前Sing-Box证书路径: \e[0m/etc/tls/$full_domain.crt \e[92m|\e[0m /etc/tls/$full_domain.key"
            for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e ""
        fi
    done
    if [ "$match_count" -ne 0 ]; then
        for ((j = 0; j < path_count; j++)); do echo -n -e "-"; done; echo -e ""
        echo -e " - \e[92m已完成Sing-Box的Server_Name更新: \e[0m$full_domain"
        echo -e " - \e[92m已完成Sing-Box证书路径更新: \e[0m/etc/tls/$full_domain.crt \e[92m|\e[0m /etc/tls/$full_domain.key"
    fi
}
modify_tls_for_xray(){
    tls_domains=()
    cdn_domains=()
    domains=()  
    local_ip=$(curl -s https://api64.ipify.org)
    cert_names=()
    certname=()
    tls_directory="/etc/tls"
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    original_directory=$(pwd)
    cd /etc/tls || exit
    file_array=()
    for file in *; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            file_array+=("${file_name%.*}")
        fi
    done
    cd "$original_directory" || exit
    unique_array=($(echo "${file_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for ((i=0; i<"${#unique_array[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_array[i]}_ecc/fullchain.cer" ]; then
            cert_names+=(${unique_array[i]})
        else
            sudo rm -f "/etc/tls/${unique_array[i]}.key" "/etc/tls/${unique_array[i]}.crt" > /dev/null 2>&1
        fi
    done
    if [ -d "$tls_directory" ]; then
        for cert_file in "$tls_directory"/*.crt; do
            if [ -f "$cert_file" ]; then
            domains_array=($(openssl x509 -in "$cert_file" -text -noout | grep DNS | sed 's/ *DNS://'))
            for domain in "${domains_array[@]}"; do
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("$domain")
                else
                cdn_domains+=("$domain")
                fi
            done
            fi
        done
        domains=("${tls_domains[@]}" "${cdn_domains[@]}")
        echo -e " - \e[93m检测到TLS证书的域名:\e[0m"
        echo "--xRay------------------------------"
        printf '   \e[92m%s\n\e[0m' "${domains[@]}"
        echo "------------------------------------"
    fi
    json_file="/usr/local/etc/xray/xray_domain_updata.json"
    certname=($(ls -1 /etc/tls/*.crt 2>/dev/null | sed 's/.*\/\([^/]*\)\.crt/\1/' | sort -u))
    {
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
    if grep -q '"certificates": \[' "$xray_config_file"; then
        sed -i "/\"certificates\": \[/ r $json_file" "$xray_config_file"
    else
        sed -i "/\"certificates\": {/ r $json_file" "$xray_config_file"
    fi
    certificate_count=$(grep -c "certificateFile" "$xray_config_file")
    last_line=$(grep -n "certificateFile" "$xray_config_file" | tail -n 1 | cut -d ':' -f 1)
    start_line=$((last_line - certificate_count + cert_count + 1))
    sed -i "${start_line},${last_line}d" "$xray_config_file"
    sudo systemctl restart xray > /dev/null 2>&1
    sudo systemctl restart nginx > /dev/null 2>&1
    echo -e " - \e[92m已完成xRay的TLS证书路径的更新。\e[0m"
}
modify_tls_for_nginx(){
    tls_directory="/etc/tls"
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    tls_domains=()
    cdn_domains=()
    domains=()  
    local_ip=$(curl -s https://api64.ipify.org)
    if [ -d "$tls_directory" ]; then
        for cert_file in "$tls_directory"/*.crt; do
            if [ -f "$cert_file" ]; then
            domains_array=($(openssl x509 -in "$cert_file" -text -noout | grep DNS | sed 's/ *DNS://'))
            for domain in "${domains_array[@]}"; do
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("$domain")
                else
                cdn_domains+=("$domain")
                fi
            done
            fi
        done
        domains=("${tls_domains[@]}" "${cdn_domains[@]}")
        echo -e " - \e[93m检测到TLS证书的域名:\e[0m"
        echo "--Nginx-----------------------------"
        printf '   \e[92m%s\n\e[0m' "${domains[@]}"
        echo "------------------------------------"
    fi
    prefixed_domains=()
    for domain in "${domains[@]}"; do
        stripped_domain=$(echo "$domain" | sed 's/^[^.]*\.//')
        prefixed_domains+=("*.$stripped_domain")
    done
    rm -rf "$nginx_config_file" nginx.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
    mv nginx.conf "$nginx_config_file" > /dev/null 2>&1
    unique_domains_nginx=($(echo "${prefixed_domains[@]}" | tr ' ' '\n' | awk '!a[$0]++' | tr '\n' ' '))
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/server_name yourdomain.com/a\\
        server_name $domain;" "$nginx_config_file"
    done
    sed -i "/yourdomain.com/d" "$nginx_config_file"
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/server_name yourdomain.com/a\\
        server_name $domain;" "$nginx_index_file"
    done
    sed -i "/yourdomain.com/d" "$nginx_index_file"
    echo -e " - \e[92m已完成Nginx的Server_Name更新。\e[0m"
}
cert_names(){
    cert_names=()
    tls_directory="/etc/tls"
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    original_directory=$(pwd)
    cd /etc/tls || exit
    file_array=()
    for file in *; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            file_array+=("${file_name%.*}")
        fi
    done
    unique_array=($(echo "${file_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    clear_tls=false
    for ((i=0; i<"${#unique_array[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_array[i]}_ecc/fullchain.cer" ]; then
            cert_names+=(${unique_array[i]})
        else
            sudo rm -f "/etc/tls/${unique_array[i]}.key" "/etc/tls/${unique_array[i]}.crt" > /dev/null 2>&1
            clear_tls=true
        fi
    done
    if [ "$clear_tls" = true ]; then
        echo -e "\e[1;32m - 清理临时证书文件结束。\e[0m"
    fi
    echo -e "\e[1;32m - 已保存在/etc/tls的 TLS 证书文件:\e[0m"
    for element in "${cert_names[@]}"; do
        echo -e "  - $element (.crt/.key)"
    done
    cd "$original_directory" || exit
}
domain_set(){
    clear
    config_files
    [ ! -e "$xray_config_file" ] && { echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"; display_pause_info; return 1; }
    [ ! -e "$box_config_file" ] && { echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"; display_pause_info; return 1; }
    [ ! -e "$nginx_config_file" ] && { echo -e "\e[1;31m - Nginx 配置文件缺失，操作中止。\e[0m"; display_pause_info; return 1; }
    ! command -v nginx &> /dev/null && { echo -e "\e[1;31m - nginx 未安装，操作中止。\e[0m"; display_pause_info; return 1; }
    ! command -v xray &> /dev/null && { echo -e "\e[1;31m - xray 未安装，操作中止。\e[0m"; display_pause_info; return 1; }
    ! command -v sing-box &> /dev/null && { echo -e "\e[1;31m - Sing-Box 未安装，操作中止。\e[0m"; display_pause_info; return 1; }
    domain_input
    if [ ${#domains[@]} -gt 0 ]; then
        cert_names
        nginx_domain_set
        xray_domain_set
        xray_domain_update
    fi
    display_pause_info
}
show_user_info(){
    clear
    path_count=150
    config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    singbox_user_info
    xray_user_info
    display_pause_info
}
show_setting_info(){
    path_count=150
    clear
    config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    show_singbox_setting
    show_xray_setting
    display_pause_info
}
show_xray_info(){
    clear
    path_count=150
    xray_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    show_xray_setting
    display_pause_info
}
show_singbox_info(){
    clear
    path_count=150
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    show_singbox_setting
        for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    display_pause_info
}
show_status(){
    clear
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    if ! command -v nginx &> /dev/null; then
        echo -e "\e[1;31m - nginx 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if ! command -v xray &> /dev/null; then
        echo -e "\e[1;31m - xray 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if ! command -v sing-box &> /dev/null; then
        echo -e "\e[1;31m - Sing-Box 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    show_all_status
    display_pause_info
}
show_all_status(){
    display_status() {
        local service_name="$1"
        local service_status
        service_status=$(systemctl status "$service_name.service" | grep "Active:")
        if [[ $service_status == *"active (running)"* ]]; then
            printf "\e[1;32m%s\e[0m" " $service_name 正常运行"
        else
            printf "\e[1;91m%s\e[0m" " $service_name 启动失败, 请自查! 可尝试恢复相关配置文件"
        fi
    }
    status_array=()
    status_array+=("$(display_status "xray")")
    status_array+=("·")
    status_array+=("$(display_status "sing-box")")
    status_array+=("·")
    status_array+=("$(display_status "nginx")")
            equals_bottom=$(( (repeat_count - ${#status_array} ) / 3 ))
            output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
            echo -e "\n\e[90m$output_bottom ${status_array[*]}\e[0m"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}="
    done
    echo -e "${reset_color}\n"
}
restore_xray_singbox_nginx(){
    modify_tls_for_nginx
    if ! command -v nginx &> /dev/null; then
        echo -e "\e[1;31m - nginx 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ ! -e "$nginx_config_file" ]; then
        echo -e "\e[1;31m - Nginx 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m Nginx TLS域名恢复已完成。\e[0m"
    fi
    modify_tls_for_xray
    if ! command -v xray &> /dev/null; then
        echo -e "\e[1;31m - xray 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m xRay TLS域名恢复已完成。\e[0m"
    fi
    modify_tls_for_singbox
    if ! command -v sing-box &> /dev/null; then
        echo -e "\e[1;31m - Sing-Box 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m Singbox TLS域名恢复已完成。\e[0m"
    fi
}
reset_xray_singbox_nginx(){
    clear
    path_count=88
    for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e "\e[0m"
    echo -e "\e[0m"
    echo -e "\e[1;93m - 即将重置xRay/Sing-box和Nginx所有的配置\e[0m"
    echo -e "\e[1;91m - 注意: 本操作具有一定风险,\e[0m\e[1;32m 请再次输入 Y 确认, \e[0m\e[1;91m输入其他字符或回车退出。\e[0m"
    read -r -p " - 确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m - 操作已取消。\e[0m"
        return
    fi
    config_files
    if ! command -v nginx &> /dev/null; then
        echo -e "\e[1;31m - nginx 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        if [ ! -e "$nginx_config_file" ]; then
            echo -e "\e[1;31m - Nginx 配置文件缺失，操作中止。\e[0m"
            display_pause_info
            return 1
        else
            reset_nginx_files
        fi
    fi
    if ! command -v xray &> /dev/null; then
        echo -e "\e[1;31m - xray 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        if [ ! -e "$xray_config_file" ]; then
            echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
            display_pause_info
            return 1
        else
            reset_xray_files
        fi
    fi

    if ! command -v sing-box &> /dev/null; then
        echo -e "\e[1;31m - Sing-Box 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        if [ ! -e "$box_config_file" ]; then
            echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
            display_pause_info
            return 1
        else
            reset_singbox_files
        fi
    fi
    if [ -e "$nginx_config_file" ] && [ -e "$xray_config_file" ] && [ -e "$box_config_file" ]; then
        for ((j = 0; j < path_count; j++)); do echo -n -e "-"; done; echo -e "\e[0m"
        echo -e "\e[1;32m - Xray / Nginx 和 Sing-Box的配置文件已重置完成。\e[0m"
        for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e "\e[0m"
    else
        for ((j = 0; j < path_count; j++)); do echo -n -e "-"; done; echo -e "\e[0m"
        echo -e "\e[1;33m - Xray / Nginx 和 Sing-Box 配置文件缺失，未完成重置。\e[0m"
        for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e "\e[0m"
    fi
    restore_xray_singbox_nginx
    echo -e "\e[1;93m - 注意: \e[0m\e[1;32m所有TLS恢复操作已完成。其他配置已恢复初始值。\e[0m"
    for ((j = 0; j < path_count; j++)); do echo -n -e "="; done; echo -e "\e[0m"
    display_pause_info
}
reset_xray(){
    path_count=88
    clear
    xray_resttag="all"
    xray_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    backup_xray_info
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;93m - 即将重置xRay 所有配置\e[0m"
    echo -e "\e[1;91m - 注意: 本操作具有一定风险,\e[0m\e[1;32m 请再次输入 Y 确认, \e[0m\e[1;91m输入其他字符或回车退出。\e[0m"
    read -r -p " - 确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m - 操作已取消。\e[0m"
        return
    fi
    reset_xray_files
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;32m - xRay 的用户信息已重置完成。\e[0m"
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    modify_tls_for_xray
    auto_ng_path
    make_sure_restore
    echo -e "\e[1;91m注意: \e[0m\e[1;32m - 操作已完成。\e[0m\e[1;93m相关内容已自动设置完毕。\e[0m"
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    display_pause_info
}
reset_xray_user(){
    path_count=88
    clear
    xray_resttag="user"
    xray_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    backup_xray_info
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;93m - 即将重置xRay 所有用户信息 UUID \e[0m"
    echo -e "\e[1;91m - 注意: 本操作具有一定风险,\e[0m\e[1;32m 请再次输入 Y 确认, \e[0m\e[1;91m输入其他字符或回车退出。\e[0m"
    read -r -p " - 确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m - 操作已取消。\e[0m"
        return
    fi
    reset_xray_files
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;32m - xRay 的用户信息已重置完成。\e[0m"
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    restore_xray_set
    modify_tls_for_xray
    make_sure_restore
    auto_ng_path
    if [ "$user_input" != "N" ] && [ "$user_input" != "n" ]; then
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m - xRay用户信息重置操作已完成。\e[0m\e[1;93m配置参数已自动还原完毕。\e[0m"
    else
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m - xRay用户信息重置操作已完成。\e[0m\e[1;93m配置参数未还原。\e[0m"
    fi
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    display_pause_info
}
reset_xray_set(){
    path_count=88
    clear
    xray_resttag="set"
    nginx_config_files
    xray_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    backup_xray_info
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;93m - 即将重置xRay 所有配置信息 \e[0m"
    echo -e "\e[1;91m - 注意: 本操作具有一定风险,\e[0m\e[1;32m 请再次输入 Y 确认, \e[0m\e[1;91m输入其他字符或回车退出。\e[0m"
    read -r -p " - 确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m - 操作已取消。\e[0m"
        return
    fi
    reset_xray_files
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    echo -e "\e[1;32m - xRay 的配置文件已重置完成。\e[0m"
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "·";
    done
    echo -e "\e[0m"
    restore_xray_user
    modify_tls_for_xray
    make_sure_restore
    auto_ng_path
    if [ "$user_input" != "N" ] && [ "$user_input" != "n" ]; then
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m - xRay配置重置操作已完成。\e[0m\e[1;93m用户UUID已自动还原完毕。\e[0m"
    else
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m - xRay配置重置操作已完成。\e[0m\e[1;93m用户UUID未还原。\e[0m"
    fi
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    display_pause_info
}
backup_xray_info(){
    if [ "${#tags_backup[@]}" -gt 0 ]; then
        return 1
    fi
    get_xray_tags
    content="" tags_backup=() type_backup=() path_backup=() uuid_backup=() backup_uuids=() backup_new_uuids=() backup_old_uuids=()
    content=$(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file")
    tags_backup=($(echo "$content" | grep -oP '"tag":\s*"\K[^"]+' ))
    for i in "${!tags_backup[@]}"; do
        current_tag="${tags_backup[i]}"
        next_tag="${tags_backup[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        type_backup+=($(echo "$content" | grep -oP '"protocol":\s*"\K[^"]+'))
        if [[ "${tags_backup[i]}" == *api* ]]; then
            uuid_backup+=("")
        else
            uuid_back_tmp=$(echo "$content" | awk '/"clients": \[/{flag=1; next} /\]/{flag=0} flag')
            uuid_backup+=("$uuid_back_tmp")
        fi
        if [[ "${tags_backup[i]}" == *gRPC* || "${tags_backup[i]}" == *xTLS* ]]; then
            path_tmp=$(echo "$content" | grep -oP '"serviceName":\s*"\K[^\"]+' || echo "")
        else
            path_tmp=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' || echo "")
            path_tmp="${path_tmp//\//}"
        fi
        path_backup+=("$path_tmp")
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${backup_uuids[*]} " == " $id " ]]; then
                backup_uuids+=("$id")
            fi
        done
    done
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${backup_new_uuids[*]} " == " $id " ]]; then
                backup_new_uuids+=("$id")
            fi
        done
    done
    backup_new_uuids=($(echo "${backup_new_uuids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${backup_old_uuids[*]} " == " $id " ]]; then
                backup_old_uuids+=("$id")
            fi
        done
    done
    backup_old_uuids=($(echo "${backup_old_uuids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
}
restore_xray_set(){
    content=$(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file")
    tags_restore=($(echo "$content" | grep -oP '"tag":\s*"\K[^"]+' ))
    for i in "${!tags_restore[@]}"; do
        current_tag="${tags_restore[i]}"
        next_tag="${tags_restore[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        type_restore+=($(echo "$content" | grep -oP '"protocol":\s*"\K[^"]+' 2>/dev/null))
        if [[ "${tags_restore[i]}" == *gRPC* || "${tags_restore[i]}" == *xTLS* ]]; then
            path_tmp=$(echo "$content" | grep -oP '"serviceName":\s*"\K[^\"]+' 2>/dev/null || echo "")
        else
            path_tmp=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' 2>/dev/null || echo "")
            path_tmp="${path_tmp//\//}"
        fi
        path_restore+=("$path_tmp")
    done
    for i in "${!tags_restore[@]}"; do
        restore_tag="${tags_restore[i]}"
        for j in "${!tags_backup[@]}"; do
            backup_tag="${tags_backup[j]}"
            if  [ "${#path_restore[i]}" -gt 0 ] && [ "$restore_tag" == "$backup_tag" ]; then
                sed -i "s/${path_restore[i]}/${path_backup[j]}/" "$xray_config_file"
                break
            fi
        done
    done
}
restore_xray_user(){
    path_count=88
    new_uuid_array=("${backup_new_uuids[@]}")
    old_uuid_array=("${backup_old_uuids[@]}")
    process_xray_new
    process_xray_old
}
backup_singbox_setting() {
    if [ "${#backup_box_tags[@]}" -gt 0 ]; then
        return 1
    fi
    backup_box_tags=() backup_box_path=() backup_box_password=() backup_box_method=()
    backup_box_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    backup_box_ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    for i in "${!backup_box_tags[@]}"; do
        current_tag=${backup_box_tags[$i]} next_tag=${backup_box_tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | sed 's#/#''#')
        if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            method_t=$(echo "$content" | grep -oP '"method":\s*"\K[^\"]+' | head -n1)
        else
            password_t=""
            method_t=""
        fi
        backup_box_path+=($path_t)
        backup_box_password+=($password_t)
        backup_box_method+=($method_t)
    done 
}
restore_singbox_setting(){
    restore_box_tags=() restore_box_method=() restore_box_ports=() restore_box_path=() restore_box_password=()
    restore_box_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    restore_box_ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    for i in "${!restore_box_tags[@]}"; do
        current_tag=${restore_box_tags[$i]} next_tag=${restore_box_tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' 2>/dev/null | head -n1 | sed 's#/#''#')
        if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' 2>/dev/null | head -n1)
            method_t=$(echo "$content" | grep -oP '"method":\s*"\K[^\"]+' 2>/dev/null | head -n1)
        else
            password_t=""
            method_t=""
        fi
        restore_box_password+=($password_t)
        restore_box_method+=($method_t)
        restore_box_path+=($path_t)
    done 
    for i in "${!restore_box_tags[@]}"; do
        current_tag=${restore_box_tags[$i]}
        for j in "${!backup_box_tags[@]}"; do
            backup_tag=${backup_box_tags[$j]}
            if [[ " $backup_tag " == *" $current_tag "* ]]; then
                sed -i "s#${restore_box_tags[$i]}#${backup_box_tags[$j]}#" "$box_config_file"
                if [ -n "${restore_box_path[$i]}" ]; then
                sed -i "s#${restore_box_path[$i]}#${backup_box_path[$j]}#" "$box_config_file"
                fi
                if [ -n "${restore_box_password[$i]}" ]; then
                sed -i "s#${restore_box_password[$i]}#${backup_box_password[$j]}#" "$box_config_file"
                fi
                if [ -n "${restore_box_method[$i]}" ]; then
                sed -i "s#${restore_box_method[$i]}#${backup_box_method[$j]}#g" "$box_config_file"
                fi
                sed -i "s#${restore_box_ports[$i]}#${backup_box_ports[$j]}#" "$box_config_file"
            fi
        done
    done
}
make_sure_box_restore(){
    if [ "${#backup_box_tags[@]}" -gt 0 ]; then
        read -r -t 5 -p " - 当前存在备份，5秒后将自动恢复。(默认按Enter跳过等待，或在5秒内输入 N 取消): " user_input
        echo
        if [ "$user_input" != "N" ] && [ "$user_input" != "n" ]; then
            restore_singbox_setting
            echo " - 配置参数已恢复成功..."
        else
            echo " - 已跳过恢复操作"
        fi
    else
        echo " - 未发现备份"
    fi
}
make_sure_restore(){
    if [ "${#tags_backup[@]}" -gt 0 ]; then
        read -r -t 5 -p " - 当前存在备份，5秒后将自动恢复。(默认按Enter跳过等待，或在5秒内输入 N 取消): " user_input
        echo
        if [ "$user_input" != "N" ] && [ "$user_input" != "n" ]; then
            if [ "$xray_resttag" == "user" ]; then
                restore_xray_user
                echo " - 用户数据已恢复成功..."
            elif [ "$xray_resttag" == "set" ]; then
                restore_xray_set
                echo " - 配置参数已恢复成功..."
            elif [ "$xray_resttag" == "all" ]; then
                restore_xray_set
                restore_xray_user
                echo " - 用户数据与配置参数已恢复成功..."
            fi
        else
            echo " - 已跳过恢复操作"
        fi
    else
        echo " - 未发现备份"
    fi
}
reset_nginx(){
    clear
    path_count=88
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;93m - 即将重置 Nginx 所有配置信息 \e[0m"
    echo -e "\e[1;91m - 注意: 本操作具有一定风险,\e[0m\e[1;32m 请再次输入 Y 确认, \e[0m\e[1;91m输入其他字符或回车退出。\e[0m"
    read -r -p " - 确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m - 操作已取消。\e[0m"
        return
    fi
    xray_config_files
    nginx_config_files
    if [ ! -e "$nginx_config_file" ]; then
        echo -e "\e[1;31m - Nginx 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    reset_nginx_files
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    echo -e "\e[1;32m - Nginx 的配置文件已重置完成。\e[0m"
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "·";
    done
    echo -e "\e[0m"
    auto_ng_path
    modify_tls_for_nginx
    echo -e "\e[1;91m - 注意: \e[0m\e[1;32m操作已完成。\e[0m\e[1;93m相关内容已自动设置完毕。\e[0m"
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    display_pause_info
}
reset_singbox(){
    path_count=88
    clear
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    backup_singbox_setting
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "-";
    done
    echo -e "\e[0m"
    echo -e "\e[1;93m - 即将重置 Sing-Box 所有配置信息 \e[0m"
    echo -e "\e[1;91m - 注意: 本操作具有一定风险,\e[0m\e[1;32m 请再次输入 Y 确认, \e[0m\e[1;91m输入其他字符或回车退出。\e[0m"
    read -r -p " - 确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m操作已取消。\e[0m"
        return
    fi
    reset_singbox_files
    modify_tls_for_singbox
    make_sure_box_restore
    if [ "$user_input" != "N" ] && [ "$user_input" != "n" ]; then
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m - xRay配置重置操作已完成。\e[0m\e[1;93m设置已自动还原，UUID为初始值。\e[0m"
    else
        echo -e "\e[1;91m - 注意: \e[0m\e[1;32m - Sing-Box重置操作已完成。\e[0m\e[1;93m所有设置和UUID为初始值。\e[0m"
    fi
    for ((j = 0; j < path_count; j++)); do
        echo -n -e "=";
    done
    echo -e "\e[0m"
    display_pause_info
}
modify_singbox_path(){
    clear
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    tags=() path_t=()
    path_count=88
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-20s %-42s\e[0m\n" "No." "Type" "Path"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t+=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | tr -s '\n' | grep -v '^$'))
        type_t+=(${type[i]})
    done
    common_prefix="${path_t[0]}"
    for ((j = 1; j < ${#path_t[@]}; j++)); do
        while [[ "${path_t[j]}" != "${common_prefix}"* ]]; do
            common_prefix="${common_prefix%?}"
        done
    done
    for ((j = 0; j < ${#path_t[@]}; j++)); do
        printf "%-3s %-20s %-42s\n" "$((j+1))." "${type_t[j+1]}" "${path_t[j]}"
    done
    common_prefix2=$(echo "${common_prefix}" | tr -d '/')
    echo -e "当前前缀: \e[1;32m${common_prefix2}\e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    error_count=0
    while true; do
        echo -e "\e[1;93m请输入一个3位及以上的前缀 (只允许包含英文字母和数字):\e[0m"
        read -r -e user_prefix
        if [[ "$user_prefix" =~ ^[a-zA-Z0-9]+$ && ${#user_prefix} -ge 3 ]]; then
            echo -e "\n输入的前缀是: \e[1;91m${user_prefix}\n\e[0m"
            break
        else
            ((error_count++))
            echo -e "\033[1;31m\n  输入无效, 请只输入英文字母和数字, 并确保长度大于等于3。\n\033[0m"
            if [ "$error_count" -ge 3 ]; then
                user_prefix=$(head -c 5 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c $((RANDOM % 3 + 3)))
                for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
                echo -e "\033[1;93m  * 累计错误已达3次, 随机生成的前缀为: \e[0m\e[1;32m${user_prefix}\n\e[0m"
                break
            fi
        fi
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    new_paths=()
    for ((j = 0; j < ${#path_t[@]}; j++)); do
        new_path=/"$user_prefix${path_t[j]#"$common_prefix"}"
        new_paths+=("$new_path")
    done
    printf "\e[1;91m%-3s %-20s %-42s\e[0m\n" "No." "Type" "Path"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for ((j = 0; j < ${#new_paths[@]}; j++)); do
        printf "%-3s %-20s %-42s\n" "$((j+1))." "${type_t[j+1]}" "${new_paths[j]}"
    done
    for ((j = 0; j < ${#new_paths[@]}; j++)); do
        sed -i "s|\"path\": \"${path_t[j]}\"|\"path\": \"${new_paths[j]}\"|g" "$box_config_file"
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;93mSing-Box 配置文件中的 Path 已完成更新\e[0m"
    restart_singbox_info
    display_pause_info
}
modify_xray_ng_path(){
    clear
    xray_config_files
    nginx_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    tags=() path_t=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol":\s*"\K[^"]+'))
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%32s%s\n" "" "当前 xRay Path 清单"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-22s %-18s %-20s\e[0m\n" "No." "Name" "Protocol" "Path"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    all_path_t=()
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
        if [ "${#path_t[@]}" -gt 0 ]; then
            printf "%-3s " "$((i-1))."
            printf "%-22s " "${tags[i]}"
            printf "%-18s " "${type[i]}"
            printf "%-20s\n" "${path_t[0]}"
        fi
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"; 
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        all_path_t[i]="${all_path_t[i]//\//}"
    done
    common_prefix=$(printf "%s\n" "${all_path_t[@]}" | awk -F "" 'NR==1{p=$0; next} {p=substr(p, 1, length <= length($0) ? length : length($0)); for(i=1;i<=length && substr($0,i,1)==substr(p,i,1);i++); p=substr(p, 1, i-1)} END{print p}')
    if [ -n "$common_prefix" ]; then
        echo -e "当前前缀: \e[1;32m${common_prefix}\e[0m"
    else
        echo "找到共同前缀，如有单独修改过，请修改为一致后再操作。"
    fi
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    error_count=0
    while true; do
        echo -e "\e[1;93m请输入一个3位及以上的前缀 (只允许包含英文字母和数字):\e[0m"
        read -r -e user_prefix
        if [[ "$user_prefix" =~ ^[a-zA-Z0-9]+$ && ${#user_prefix} -ge 3 ]]; then
            echo -e "\n输入的前缀是: \e[1;91m${user_prefix}\n\e[0m"
            break
        else
            ((error_count++))
            echo -e "\033[1;31m\n  输入无效, 请只输入英文字母和数字, 并确保长度大于等于3。\n\033[0m"
            if [ "$error_count" -ge 3 ]; then
                user_prefix=$(head -c 5 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c $((RANDOM % 3 + 3)))
                for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
                echo -e "\033[1;93m  * 累计错误已达3次, 随机生成的前缀为: \e[0m\e[1;32m${user_prefix}\n\e[0m"
                break
            fi
        fi
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    new_paths=()
    for ((j = 0; j < ${#all_path_t[@]}; j++)); do
        new_path="$user_prefix${all_path_t[j]#"$common_prefix"}"
        new_paths+=("$new_path")
    done
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        sed -i "s|${all_path_t[i]}|${new_paths[i]}|g" "$xray_config_file"
        sed -i "s|${all_path_t[i]}|${new_paths[i]}|g" "$nginx_index_file"
    done
    printf "\e[1;91m%-3s %-22s %-18s %-20s\e[0m\n" "No." "Name"  "Protocol" "Path"
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
        printf "%-3s " "$((i-1))."
        printf "%-22s " "${tags[i]}"
        printf "%-18s " "${type[i]}"
        printf "%-20s\n" "${path_t[0]}"
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;93m xRay 配置文件中的 Path 已完成更新\e[0m"
    auto_ng_path
    restart_xray_info
    display_pause_info
}
xray_path_alone(){
    path_count=80
    clear
    xray_config_files
    nginx_config_files
    if [ ! -e "$xray_config_file" ]; then
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    tags=() path_t=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol":\s*"\K[^"]+'))
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path":\s*"\K[^\"]+' | tr -d '/'))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%32s%s\n" "" "当前 xRay Path 清单"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-22s %-18s %-20s\e[0m\n" "No." "Name"  "Protocol" "Path Name"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    all_path_t=()
    n=1
    tag_path=()
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | tr -d '/'))
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
        if [ "${#path_t[@]}" -gt 0 ]; then
            tag_path+=("${tags[i]}")
            printf "%-3s " "$((n))."
            printf "%-22s " "${tags[i]}"
            printf "%-18s " "${type[i]}"
            printf "%-20s\n" "${path_t[0]}"
            ((n++))
        fi
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"; 
      echo -e "\e[1;31m  提醒: 如果在这里单独修改后，无法再次批量修改前缀，必须统一前缀才能批量修改！\e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    k=0
    while true; do
        ((k++))
        read -r -p $'\e[1;33m - 请选择要修改的路径 (输入编号): \e[0m' choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "$n" ]; then
                selected_path="${all_path_t[$((choice-1))]}"
                echo -e " - 你选择要修改的path为:\e[1;32m $selected_path\e[0m"
                k=0
                break
            else
                 echo -e "\e[1;31m - 无效的选择。请重新输入！\e[0m"
            fi
        else
            echo -e "\e[1;31m - 请输入有效的数字。\e[0m"
        fi
        if [ "$k" -eq 3 ]; then
            echo -e "\e[1;32m - 连续输入错误已达3次，本次操作结束\033[0m" 
            break
        fi
    done
    if [ "$k" -eq 0 ]; then
        selected_element="${tag_path[$choice-1]}"
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        generate_random_string() {
            tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c $((RANDOM % 6 + 7))
            echo
        }
        max_attempts=3
        attempt=0
        while [ $attempt -le $max_attempts ]; do
            read -r -p $'\e[1;33m - 请输入要修改的path内容5-12位（按 Enter 使用随机字符）: \e[0m' user_input
            if [ -z "$user_input" ]; then
                user_input=$(generate_random_string)
                echo " - 自动生成的随机字符:  $user_input"
                break
            fi
            if [[ ! "$user_input" =~ ^[a-zA-Z0-9]{5,12}$ ]]; then
                echo -e "\e[1;31m - 错误: 只允许输入英文和数字，且长度不小于5位且不超过12位。\e[0m"
                ((attempt++))
            else
                echo -e " - 你输入的新path是:  \e[1;31m$user_input\e[0m"
                break
            fi
            if [ $attempt -eq $max_attempts ]; then
                echo  -e " - \e[1;32m连续输入错误超过3次，已自动生成。\e[0m"
                user_input=$(generate_random_string)
                echo " - 自动生成的随机字符:  $user_input"
                break
            fi
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        if [[ "${selected_element,,}" =~ "grpc" ]]; then
            sed -i "s|$selected_path|$user_input|g" "$xray_config_file"
            echo -e " - \e[1;32m - 已完成xRay中对应path的修改\e[0m"
            sed -i "s|$selected_path|$user_input|g" "$nginx_index_file"
            echo -e " - \e[1;32m - 已完成Nginx中对应path的修改\e[0m"
            sleep 2
            sudo systemctl restart xray
            echo -e " - \e[1;32m - 已重新启动xRay\e[0m"
            systemctl reload nginx
            sudo systemctl restart nginx
            echo -e " - \e[1;32m - 已重新启动Nginx\e[0m"
        else
            sed -i "s|$selected_path|$user_input|g" "$xray_config_file"
            echo -e " - \e[1;32m - 已完成xRay中对应path的修改\e[0m"
            sleep 1
            sudo systemctl restart xray
            echo -e " - \e[1;32m - 重新启动xRay\e[0m"
        fi
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    fi
    display_pause_info
}
singbox_path_alone(){
    path_count=80
    color_set
    clear
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    tags=() path_t=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-20s %-42s\e[0m\n" "No." "Type" "Path Name"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t+=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | tr -s '\n' | grep -v '^$' | tr -d '/'))
        type_t+=(${type[i]})
    done
    for ((j = 0; j < ${#path_t[@]}; j++)); do
        printf "%-3s %-20s %-42s\n" "$((j+1))." "${type_t[j+1]}" "${path_t[j]}"
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"; 
      echo -e "\e[1;31m  提醒: 如果在这里单独修改后，无法再次批量修改前缀，必须统一前缀才能批量修改！\e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    k=0
    while true; do
        ((k++))
        read -r -p $'\e[1;33m - 请选择要修改的路径 (输入编号): \e[0m' choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#path_t[@]}" ]; then
                selected_path="${path_t[$((choice-1))]}"
                echo -e " - 你选择要修改的path为:\e[1;32m $selected_path\e[0m"
                k=0
                break
            else
                 echo -e "\e[1;31m - 无效的选择。请重新输入！\e[0m"
            fi
        else
            echo -e "\e[1;31m - 请输入有效的数字。\e[0m"
        fi
        if [ "$k" -eq 3 ]; then
            echo -e "\e[1;32m - 连续输入错误已达3次，本次操作结束\033[0m" 
            break
        fi
    done
    if [ "$k" -eq 0 ]; then
        selected_element="$selected_path"
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        generate_random_string() {
            tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c $((RANDOM % 6 + 7))
            echo
        }
        max_attempts=3
        attempt=0
        while [ $attempt -le $max_attempts ]; do
            read -r -p $'\e[1;33m - 请输入要修改的path内容5-12位（按 Enter 使用随机字符）: \e[0m' user_input
            if [ -z "$user_input" ]; then
                user_input=$(generate_random_string)
                echo " - 自动生成的随机字符:  $user_input"
                break
            fi
            if [[ ! "$user_input" =~ ^[a-zA-Z0-9]{5,12}$ ]]; then
                echo -e "\e[1;31m错误: 只允许输入英文和数字，且长度不小于5位且不超过12位。\e[0m"
                ((attempt++))
            else
                echo -e " - 你输入的新path是:  \e[1;31m$user_input\e[0m"
                break
            fi
            if [ $attempt -eq $max_attempts ]; then
                echo  -e " - \e[1;32m连续输入错误超过3次，已自动生成。\e[0m"
                user_input=$(generate_random_string)
                echo " - 自动生成的随机字符:  $user_input"
                break
            fi
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
            sed -i "s|$selected_path|$user_input|g" "$box_config_file"
            echo -e " - \e[1;32m已完成Sing-Box中对应path的修改\e[0m"
            sudo systemctl restart sing-box
            echo -e " - \e[1;32m已重新启动Sing-Box\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    fi
    display_pause_info
}
modify_singbox_ports(){
    clear
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    tags=() ports=() type=() new_port=""
    path_count=88
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    if [ ${#ports[@]} -eq 0 ]; then
        display_pause_info
        return 1
    fi
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    printf "\e[1;32m%30s当前Sing-Box端口清单\e[0m\n"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-20s %-42s\e[0m\n" "No." "Type" "Ports"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    n=0
    for ((j = 0; j < ${#ports[@]}; j++)); do
        printf "%-3s %-20s %-42s\n" "$((j+1))." "${tags[j]}" "${ports[j]}"
        ((n++))
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    k=0
    while true; do
        ((k++))
         read -r -p $'\e[1;33m - 请选择要修改的端口 (输入编号): \e[0m' choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "$n" ]; then
                selected_port="${ports[$((choice-1))]}"
                echo -e " - 你选择要修改的Port为:\e[1;32m $selected_port\e[0m"
                k=0
                break
            else
                 echo -e "\e[1;31m - 无效的选择。请重新输入！\e[0m"
            fi
        else
            echo -e "\e[1;31m - 请输入有效的数字。\e[0m"
        fi
        if [ "$k" -eq 3 ]; then
            echo -e "\e[1;32m - 连续输入错误已达3次，本次操作结束\033[0m" 
            break
        fi
    done
    if [ "$k" -eq 0 ]; then
        m=0
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        echo -e "\e[1;91m - 常规不可用端口: 小于3000的端口以及 ${ports[*]}\e[0m"
        while true; do
            ((m++))
            if [ "$m" -gt 3 ]; then
                echo -e "\e[1;32m - 连续输入错误已达3次，本次操作结束\033[0m" 
                break
            fi
            read -re -p $' - 请输入'"${tags[choice-1]}"'协议的监听端口: ' new_port
            if [[ $new_port =~ ^[1-9][0-9]{0,4}$ && $new_port -le 65535 && $new_port -gt 3000 ]]; then
                check_result=$(netstat -tulpn | grep -E "\b${new_port}\b")
                if [ -z "$check_result" ]; then
                    echo " - 当前输入${tags[choice-1]}的监听端口: $new_port"
                    m=0
                    break
                else
                    echo -e "\033[1;31m 错误: 端口已被占用, 请选择其他端口! \033[0m" >&2
                fi
            else
                echo -e "\033[1;31m 错误: 端口范围 \e[1;33m3001-65535\033[0m , 请重新输入! \033[0m" >&2
            fi
        done
    fi
    if [ "$k" -eq 0 ] && [ "$m" -eq 0 ]; then
        echo -e "\e[1;92m - 新的${tags[choice-1]}端口号为: $new_port\e[0m"
        sed -i "s/\"listen_port\":\s*${ports[choice-1]}/\"listen_port\": $new_port/" "$box_config_file"
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
        printf "\e[1;31m%30s更新后的Sing-Box端口清单\e[0m\n"
        ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
        if [ ${#ports[@]} -eq 0 ]; then
            display_pause_info
            return 1
        fi
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        printf "\e[1;32m%-3s %-20s %-42s\e[0m\n" "No." "Type" "Ports"
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        for ((j = 0; j < ${#ports[@]}; j++)); do
            printf "%-3s %-20s %-42s\n" "$((j+1))." "${tags[j]}" "${ports[j]}"
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        restart_singbox_info
    fi
    display_pause_info
}
modify_tls_for_reset(){
    path_count=88
    tls_directory="/etc/tls"
    tls_domains=()
    cdn_domains=()
    domains=()  
    local_ip=$(curl -s https://api64.ipify.org)
    if [ -d "$tls_directory" ]; then
    for cert_file in "$tls_directory"/*.crt; do
        if [ -f "$cert_file" ]; then
        domains_array=($(openssl x509 -in "$cert_file" -text -noout | grep DNS | sed 's/ *DNS://'))
        for domain in "${domains_array[@]}"; do
            if dig +short "$domain" | grep -q "$local_ip"; then
            tls_domains+=("$domain")
            else
            cdn_domains+=("$domain")
            fi
        done
        fi
    done
    domains=("${tls_domains[@]}" "${cdn_domains[@]}")
    echo -e " - \e[93m已存在TLS证书的域名:\e[0m"
    echo "--------------Nginx-------------"
    printf ' - \e[92m%s\n\e[0m' "${domains[@]}"
    echo "--------------------------------"
    else
    echo "Error: Directory $tls_directory does not exist."
    fi
    prefixed_domains=()
    for domain in "${domains[@]}"; do
        stripped_domain=$(echo "$domain" | sed 's/^[^.]*\.//')
        prefixed_domains+=("*.$stripped_domain")
    done
    for domain in "${prefixed_domains[@]}"; do
        sed -i -e "/server_name yourdomain.com/a\\
        server_name $domain;" "$nginx_config_file"
    done
    sed -i "/yourdomain.com/d" "$nginx_config_file"
    for domain in "${prefixed_domains[@]}"; do
        sed -i -e "/server_name yourdomain.com/a\\
        server_name $domain;" "$nginx_index_file"
    done
    sed -i "/yourdomain.com/d" "$nginx_index_file"
    echo -e " - \e[92m已完成Nginx的Server_Name更新。\e[0m"
    xray_domain_update
}
auto_ng_path(){
    nginx_ports=() nginx_paths=() xray_ports=() xray_paths=()
    nginx_path=$(grep 'corresponds' "$nginx_index_file" 2>/dev/null)
    nginx_ports=($(grep -oP 'grpc://127\.0\.0\.1:[0-9]+' "$nginx_index_file" 2>/dev/null | sed 's/grpc:\/\/127\.0\.0\.1://'))
    location_block=$(awk '/corresponds/ {f=1} f; /location/ {f=0}' <<< "$nginx_path")
    readarray -t location_array <<< "$location_block"
    for element in "${location_array[@]}"; do
        nginx_paths+=($(echo "$element" | sed 's/{.*$//' | sed 's/.*\///' | tr -d ' '))
    done
    xray_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' 2>/dev/null))
    xray_paths=() xray_ports=()
    for i in "${!xray_tags[@]}"; do
        current_tag="${xray_tags[i]}"
        next_tag="${xray_tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        if [[ "${xray_tags[i]}" == *gRPC* ]]; then
            xray_paths+=($(echo "$content" | grep -oP '"serviceName":\s*"\K[^\"]+'| tr -d ' ' 2>/dev/null))
            xray_ports+=($(echo "$content" | grep -oP '"port":\s*\K[^,]+'| tr -d ' ' 2>/dev/null))
        fi
    done
    for ((i=0; i<${#nginx_ports[@]}; i++)); do
    x_count=false
    if [[ "${nginx_ports[i]}" = "${xray_ports[i]}" ]]; then
        if [[ "${nginx_paths[i]}" != "${xray_paths[i]}" ]]; then
            sed -i "s#${nginx_paths[i]}#${xray_paths[i]}#" "$nginx_index_file"
            x_count=true
        fi
    fi
    done
    if [ "$x_count" = "true" ]; then
        echo -e "\e[1;93m - Nginx 配置文件中的 Path 已更新\e[0m"
      for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    fi
}
restart_all(){
    clear
    if ! command -v nginx &> /dev/null; then
        echo -e "\e[1;31m - Nginx 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if ! command -v xray &> /dev/null; then
        echo -e "\e[1;31m - xRay 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if ! command -v sing-box &> /dev/null; then
        echo -e "\e[1;31m - Sing-Box 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    systemctl reload nginx
    sudo systemctl start nginx
    sudo systemctl start xray
    sudo systemctl start sing-box
    sudo systemctl restart nginx
    sudo systemctl restart xray
    sudo systemctl restart sing-box
    sudo systemctl status nginx 
    sudo systemctl status xray 
    sudo systemctl status sing-box
    display_pause_info
}
restart_xray(){
    clear
    if ! command -v nginx &> /dev/null; then
        echo -e "\e[1;31m - Nginx 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if ! command -v xray &> /dev/null; then
        echo -e "\e[1;31m - xRay 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    systemctl reload nginx
    sudo systemctl start nginx
    sudo systemctl start xray
    sudo systemctl restart nginx
    sudo systemctl restart xray
    sudo systemctl status nginx 
    sudo systemctl status xray 
    display_pause_info
}
restart_singbox(){
    clear
    if ! command -v sing-box &> /dev/null; then
        echo -e "\e[1;31m - Sing-Box 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    sudo systemctl start sing-box
    sudo systemctl restart sing-box
    sudo systemctl status sing-box
    display_pause_info
}
restart_xray_info(){
    systemctl reload nginx
    sudo systemctl stop nginx
    sudo systemctl stop xray
    sudo systemctl start nginx
    sudo systemctl start xray
    sudo systemctl restart nginx
    sudo systemctl restart xray
    color_set
    display_status() {
        local service_name="$1"
        local service_status
        service_status=$(systemctl status "$service_name.service" | grep "Active:")
        if [[ $service_status == *"active (running)"* ]]; then
            printf "\e[1;32m%s\e[0m" " $service_name 正常运行"
        else
            printf "\e[1;91m%s\e[0m" " $service_name 启动失败, 请自查! 可尝试恢复相关配置文件"
        fi
    }
    status_array=()
    status_array+=("$(display_status "xray")")
    status_array+=("·")
    status_array+=("$(display_status "nginx")")
    equals_bottom=$(( (path_count - ${#status_array} ) / 3 ))
    output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
    echo -e "\n\e[90m$output_bottom ${status_array[*]}\e[0m"
    for ((i = 0; i < path_count; i++)); do
        echo -n -e "${light_gray}="
    done
    echo -e "${reset_color}\n"
}
restart_singbox_info(){
    sudo systemctl stop sing-box
    sudo systemctl start sing-box
    sudo systemctl restart sing-box
    color_set
    display_status() {
        local service_name="$1"
        local service_status
        service_status=$(systemctl status "$service_name.service" | grep "Active:")
        if [[ $service_status == *"active (running)"* ]]; then
            printf "\e[1;32m%s\e[0m" " $service_name 正常运行"
        else
            printf "\e[1;91m%s\e[0m" " $service_name 启动失败, 请自查! 可尝试恢复相关配置文件"
        fi
    }
    status_array=()
    status_array+=("$(display_status "sing-box")")
    equals_bottom=$(( (path_count - ${#status_array} ) / 2 ))
    output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
    echo -e "\n\e[90m$output_bottom ${status_array[*]}\e[0m"
    for ((i = 0; i < path_count; i++)); do
        echo -n -e "${light_gray}="
    done
    echo -e "${reset_color}\n"
}
config_files(){
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*sing-box/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            box_config_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 Sing-Box 的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo " - 您选择了文件: $choice"
                    box_config_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - Sing-Box 配置文件路径为: \e[0m\e[93m$box_config_file\e[0m"
    else
        box_config_file="/etc/sing-box/config.json"
    fi
    config_files=$(find / -type f -path "*xray/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            xray_config_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 xRay 的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo " - 您选择了文件: $choice"
                    xray_config_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - xRay 配置文件路径为: \e[0m\e[93m$xray_config_file\e[0m"
    else
        xray_config_file="/usr/local/etc/xray/config.json"
    fi
    config_files=$(find / -type f -path "*nginx/nginx.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            nginx_config_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 Nginx 网站的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo " - 您选择了文件: $choice"
                    nginx_config_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的nginx.conf\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - Nginx 配置文件路径为: \e[0m\e[93m$nginx_config_file\e[0m"
    else
        nginx_config_file="/etc/nginx/nginx.conf"
    fi
    config_files=$(find / -type f -path "*conf.d/default.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            nginx_index_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 Nginx 网站的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo " - 您选择了文件: $choice"
                    nginx_index_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的default.conf\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - Nginx 站点配置文件路径为: \e[0m\e[93m$nginx_index_file\e[0m"
    else
        nginx_index_file="/etc/nginx/conf.d/default.conf"
    fi
}
xray_config_files(){
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*xray/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            xray_config_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 xRay 的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo " - 您选择了文件: $choice"
                    xray_config_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - xRay 配置文件路径为: \e[0m\e[93m$xray_config_file\e[0m"
    else
        xray_config_file="/usr/local/etc/xray/config.json"
    fi
}
nginx_config_files(){
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*nginx/nginx.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            nginx_config_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 Nginx 网站的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    nginx_config_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的nginx.conf\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - Nginx 配置文件路径为: \e[0m\e[93m$nginx_config_file\e[0m"
    else
        nginx_config_file="/etc/nginx/nginx.conf"
    fi
    config_files=$(find / -type f -path "*conf.d/default.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            nginx_index_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 Nginx 网站的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    nginx_index_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的default.conf\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - Nginx 网站配置文件路径为: \e[0m\e[93m$nginx_index_file\e[0m"
    else
        nginx_index_file="/etc/nginx/conf.d/default.conf"
    fi
}
singbox_config_files(){
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*sing-box/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ "$(echo "$config_files" | wc -l)" -eq 1 ]; then
            box_config_file=$config_files
        else
            echo -e "\e[93m - 系统中存在多个 Sing-Box 的配置, 请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo " - 您选择了文件: $choice"
                    box_config_file=$choice
                    echo -e "\e[92m - 为了减少你的交互操作, 请在本次操作完全结束后, 删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo " - 无效的选择, 请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m - Sing-Box 配置文件路径为: \e[0m\e[93m$box_config_file\e[0m"
    else
        box_config_file="/etc/sing-box/config.json"
    fi
}
install_warp(){
   wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh [option] [lisence/url/token]
}
dokodemo_door_ports(){
    path_count=88
    clear
    xray_config_files
    singbox_config_files
    if [ -e "$xray_config_file" ] ; then
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
        type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol":\s*"\K[^"]+'))
        ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"port":\s*\K[^,]+'))
        for i in "${!type[@]}"; do
            if [ "${type[i]}" == "dokodemo-door" ]; then
                ports_t=${ports[i]}
            fi
        done
        box_ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
        if [ -z "$ports_t" ]; then
            echo -e "\033[1;31m\n    Dokodemo-Door端口读取失败! 请检查xRay相关配置或文件\n\033[0m"
        else
            echo -e "\e[1;91m - 常规不可用端口: 80 443 ${box_ports[*]}\e[0m"
            echo -e "\e[1;92m - 当前Dokodemo-Door监听端口为: $ports_t\e[0m"
            while true; do
                read -re -p $'\e[93m - 请输入Dokodemo-Door监听端口 (回车随机): \e[0m' new_port
                new_port=${new_port:-$((RANDOM % (60000-10000+1) + 10000))}
                if [[ $new_port =~ ^[1-9][0-9]{0,4}$ && $new_port -le 65535 ]]; then
                    check_result=$(netstat -tulpn | grep -E "\b${new_port}\b")
                    if [ -z "$check_result" ]; then
                        echo " - 当前输入的监听端口: $new_port"
                        break
                    else
                        echo -e "\033[1;31m错误: 端口已被占用, 请选择其他端口! \033[0m" >&2
                    fi
                else
                    echo -e "\033[1;31m错误: 端口范围1-65535, 请重新输入! \033[0m" >&2
                fi
            done
            echo -e "\e[1;92m - 新的Dokodemo-Door端口号为: $new_port\e[0m"
            sed -i "s/\"port\": $ports_t/\"port\": $new_port/" "$xray_config_file"
        fi
        restart_xray_info
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
hysteria2_password(){
    clear
    path_count=88
    singbox_config_files
    if [ -e "$box_config_file" ]; then
        tags=() 
        tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        for i in "${!tags[@]}"; do
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
            [ -z "$next_tag" ] && next_tag="outbounds"
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
            if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
                password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            fi
        done
        echo -e "\e[1;91m - 当前Hysteria2的PassWord为:  $password_t\e[0m"
        while true; do
            if [ "$current_tag" == "hysteria2" ]; then
                read -r -p " - 是否随机生成12位数密码？选择 Y/N: " random_password_choice
                if [ "$random_password_choice" == "Y" ] || [ "$random_password_choice" == "y" ]; then
                    new_password=$(head -c 22 /dev/urandom | base64 | tr -d '/+='| cut -c 1-12)
                    echo -e "\n\e[93m - 自动生成${#new_password}位密码: $new_password\e[0m"
                    break  
                elif [ "$random_password_choice" == "N" ] || [ "$random_password_choice" == "n" ]; then
                    read -re -p $'\e[93m - 请输入 Hysteria2 的 Password, 建议为 12 位 Base64: \e[0m' new_password
                    if [ -z "$new_password" ]; then
                        new_password=$(head -c 22 /dev/urandom | base64 | tr -d '/+='| cut -c 1-12)
                        echo -e "\n\e[93m - 当前输入为空, 已为你自动生成${#new_password}位密码: $new_password\e[0m"
                    fi
                    break  
                else
                    echo -e "\e[1;91m - 无效的选择。请输入 Y 或 N。\e[0m"
                    continue 
                fi
            fi
        done
        echo -e "\e[1;92m - 新的Hysteria2的PassWord为: $new_password\e[0m"
        sed -i "s|\"password\": \"$password_t\"|\"password\": \"$new_password\"|" "$box_config_file"
        restart_singbox_info
    else
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
shadowsocks_password(){
    clear
    path_count=88
    singbox_config_files
    if [ -e "$box_config_file" ]; then
        tags=() 
        tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        for i in "${!tags[@]}"; do
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
            [ -z "$next_tag" ] && next_tag="outbounds"
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
            if [ "$current_tag" == "shadowsocks" ] || [ "$current_tag" == "shadowsocks" ]; then
                password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            fi
        done
        echo -e "\e[1;91m - 当前ShadowSocks的PassWord为:  $password_t\e[0m"
        for i in "${!tags[@]}"; do
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
            if [ "$current_tag" == "shadowsocks" ] ; then
                while true; do
                    read -r -p " - 是否随机生成24位数密码？选择 Y/N: " random_password_choice
                    if [ "$random_password_choice" == "Y" ] || [ "$random_password_choice" == "y" ]; then
                        random_data=$(head -c 22 /dev/urandom | base64 | tr -d '/+='| cut -c 1-22)
                        ss_password="${random_data}=="
                        echo -e "\n\e[93m - 自动生成${#ss_password}位密码: $ss_password\e[0m"
                        break  
                    elif [ "$random_password_choice" == "N" ] || [ "$random_password_choice" == "n" ]; then
                        read -re -p $'\e[93m - 请输入 Shadowsocks 的 Password, 建议为 24 位 Base64: \e[0m' ss_password
                        if [ -z "$ss_password" ]; then
                            random_data=$(head -c 22 /dev/urandom | base64 | tr -d '/+='| cut -c 1-22)
                            ss_password="${random_data}=="
                            echo -e "\n\e[93m - 当前输入为空, 已为你自动生成${#ss_password}位密码: $ss_password\e[0m"
                        fi
                        if [ ${#ss_password} -eq 24 ]; then
                            last_two_chars="${ss_password: -2}"
                            if [ "$last_two_chars" == "==" ]; then
                                break  
                            else
                                echo -e "\033[0;31m$ss_password 最后两位不符合要求, 请重新开始! \033[0m"
                            fi
                        else
                            echo -e "\033[0;31m$ss_password 长度不足24位, 请重新开始! \033[0m"
                        fi
                    else
                        echo -e "\e[1;91m - 无效的选择。请输入 Y 或 N。\e[0m"
                    fi
                done
                break  
            fi
        done
        echo -e "\e[1;92m新的ShadowSocks的PassWord为: $ss_password\e[0m"
        sed -i "s|\"password\": \"$password_t\"|\"password\": \"$ss_password\"|" "$box_config_file"
        restart_singbox_info
    else
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
install_all(){
    install_xRay_SingBox
    domain_set
}
xray_new_uuids() {
    path_count=150
    clear
    xray_config_files
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -e "$xray_config_file" ] ; then
        echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay中现有的新用户信息! \e[0m"
        echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
        read -r -p $'\e[93m - 请输入要生成xRay新UUID数量: \e[0m' count
        if [ -z "$count" ] || [ "$count" -eq 0 ]; then
            echo " - 生成数量为0, 退出操作。"
            display_pause_info
            return 1
        elif [ "$count" -ne 0 ]; then
            for ((i=1; i<=count; i++)); do
                new_uuid=$(uuidgen)
                new_uuid_array+=("$new_uuid")
            done
            xray_config_files
            process_xray_new
            xray_user_info
            restart_xray_info
            display_pause_info
        fi
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
}
xray_new_manual_input_uuids() {
    path_count=150
    clear
    xray_config_files
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -e "$xray_config_file" ] ; then
        echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay中现有的新用户信息! \e[0m"
        echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
        echo -e "\e[93m - 请输入新的xRay UUID, 以空行结束\e[0m"
        while read -r uuid && [ -n "$uuid" ]; do
            new_uuid_array+=("$uuid")
        done
        is_valid_uuid() {
            local uuid=$1
            if [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
                return 0  
            else
                return 1
            fi
        }
        valid_new_uuid_array=()
        for new_uuid in "${new_uuid_array[@]}"; do
            if is_valid_uuid "$new_uuid"; then
                valid_new_uuid_array+=("$new_uuid")
            else
                echo "删除不符合 UUID 规范的内容: $new_uuid"
            fi
        done
        new_uuid_array=("${valid_new_uuid_array[@]}")
        if [ ${#new_uuid_array[@]} -eq 0 ]; then
            new_uuid_array+=("$(uuidgen)")
            echo -e "\e[1;32m - 输入为空, 已自动生成 1 枚UUID。\e[0m"
        fi
        display_one_uuids
        process_xray_new
        xray_user_info
        restart_xray_info
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
xray_old_uuids() {
    path_count=150
    xray_config_files
    clear
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -e "$xray_config_file" ] ; then
        echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay中现有的老用户信息! \e[0m"
        echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
        read -r -p $'\e[93m - 请输入要生成xRay老用户的UUID数量: \e[0m' count
        if [ -z "$count" ] || [ "$count" -eq 0 ]; then
            echo " - 生成数量为0, 退出操作。"
            display_pause_info
            return 1
        elif [ "$count" -ne 0 ]; then
            for ((i=1; i<=count; i++)); do
                old_uuid=$(uuidgen)
                old_uuid_array+=("$old_uuid")
            done
            display_one_uuids
            process_xray_old
            xray_user_info
            restart_xray_info
            display_pause_info
        fi
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
}
xray_old_manual_input_uuids() {
    path_count=150
    clear
    xray_config_files
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -e "$xray_config_file" ] ; then
        echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除xRay中现有的老用户信息! \e[0m"
        echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
        echo -e "\e[93m - 请输入老用户的xRay UUID, 以空行结束\e[0m"
        while read -r uuid && [ -n "$uuid" ]; do
            old_uuid_array+=("$uuid")
        done
        is_valid_uuid() {
            local uuid=$1
            if [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
                return 0  
            else
                return 1
            fi
        }
        valid_old_uuid_array=()
        for old_uuid in "${old_uuid_array[@]}"; do
            if is_valid_uuid "$old_uuid"; then
                valid_old_uuid_array+=("$old_uuid")
            else
                echo "删除不符合 UUID 规范的内容: $old_uuid"
            fi
        done
        old_uuid_array=("${valid_old_uuid_array[@]}")
        if [ ${#old_uuid_array[@]} -eq 0 ]; then
            old_uuid_array+=("$(uuidgen)")
            echo -e "\e[1;32m - 输入为空, 已自动生成 1 枚UUID。\e[0m"
        fi
        display_one_uuids
        process_xray_old
        xray_user_info
        restart_xray_info
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
singbox_uuids() {
    path_count=150
    clear
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    singbox_config_files
    if [ -e "$box_config_file" ]; then
        echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除Sing-Box中现有的用户信息! \e[0m"
        echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
        read -r -p $'\e[93m - 请输入要生成Sing-Box的UUID数量: \e[0m' count
        if [ -z "$count" ] || [ "$count" -eq 0 ]; then
            echo " - 生成数量为0, 退出操作。"
            display_pause_info
            return 1
        elif [ "$count" -ne 0 ]; then
            for ((i=1; i<=count; i++)); do
                box_uuid=$(uuidgen)
                box_uuid_array+=("$box_uuid")
            done
            process_sing_box
            singbox_user_info
            restart_singbox_info
        fi
    else
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
singbox_manual_input_uuids() {
    path_count=150
    clear
    singbox_config_files
    array_assignment
    if ! command -v uuidgen &> /dev/null; then
        echo -e "\e[1;31m - uuidgen 未安装，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -e "$box_config_file" ]; then
        echo -e "\e[1;91m · 本操作具有一定的风险, 将会清除Sing-Box中现有的用户信息! \e[0m"
        echo -e "\e[1;32m · 除非你知道接下来会发生什么, 否则请按 Ctrl+C 强行结束! \e[0m"
        echo -e "\e[93m - 请输入Sing-Box的UUID, 以空行结束\e[0m"
        while read -r uuid && [ -n "$uuid" ]; do
            box_uuid_array+=("$uuid")
        done
        is_valid_uuid() {
            local uuid=$1
            if [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
                return 0  
            else
                return 1
            fi
        }
        valid_box_uuid_array=()
        for box_uuid in "${box_uuid_array[@]}"; do
            if is_valid_uuid "$box_uuid"; then
                valid_box_uuid_array+=("$box_uuid")
            else
                echo " - 删除不符合 UUID 规范的内容: $box_uuid"
            fi
        done
        box_uuid_array=("${valid_box_uuid_array[@]}")
        if [ ${#box_uuid_array[@]} -eq 0 ]; then
            box_uuid_array+=("$(uuidgen)")
            echo -e "\e[1;32m - 输入为空, 已自动生成 1 枚UUID。\e[0m"
        fi
        display_one_uuids
        process_sing_box
        singbox_user_info
        restart_singbox_info
    else
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
show_xray_user_info(){
    path_count=150
    clear
    xray_config_files
    if [ -e "$xray_config_file" ] ; then
        xray_user_info
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
show_singbox_user_info(){
    path_count=150
    clear
    singbox_config_files
    if [ -e "$box_config_file" ]; then
        singbox_user_info
    else
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
show_domain_tls_info(){
    tls_directory="/etc/tls"
    tls_domains=()
    cdn_domains=()
    local_ip=$(curl -s https://api64.ipify.org)
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -d "$tls_directory" ]; then
    all_domains=($(ls -1 "$tls_directory"/*.crt | xargs -n1 basename | sed 's/\.crt//'))
    sorted_domains=($(printf "%s\n" "${all_domains[@]}" | sort))
    max_length=0
    for domain in "${sorted_domains[@]}"; do
        length=${#domain}
        if [ "$length" -gt "$max_length" ]; then
        max_length="$length"
        fi
    done
    clear
    echo -e "\e[1;31m当前已保存的域名TLS证书及有效期:\e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
    i=0
    for domain in "${sorted_domains[@]}"; do
        i=$((i+1))
        if dig +short "$domain" | grep -q "$local_ip"; then
        tls_domains+=("\e[1;32m$i) $domain - TLS\e[0m")
        is_tls="TLS"
        color_code="\e[1;32m"
        else
        cdn_domains+=("\e[1;33m$i) $domain - CDN\e[0m")
        is_tls="CDN"
        color_code="\e[1;33m"
        fi
        if openssl x509 -in "$tls_directory/$domain.crt" -noout -dates &>/dev/null; then
        start_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
        end_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
        if [ -n "$start_date" ] && [ -n "$end_date" ]; then
            start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
            end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
            printf "${color_code}%2s) %-$((max_length + 5))s - %s   - 证书有效期: %s 至 %s\e[0m\n" "$i" "$domain" "$is_tls" "$start_date" "$end_date"
        else
            echo "日期解析失败: $domain" >&2
        fi
        else
        echo "无法读取证书或证书无效: $domain" >&2
        fi
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
    else
    echo "Error: Directory $tls_directory does not exist."
    fi
    display_pause_info
}
force_update_domain() {
    clear
    systemctl start nginx > /dev/null 2>&1
    echo -e " - \e[1;31m启动Nginx成功\e[0m" 
    domain_tls=($(find "/etc/tls" -type f \( -name "*.crt" -o -name "*.key" \) -exec basename {} \; | sed -E 's/\.(crt|key)//' | awk '!seen[$0]++'))
    [ ${#domain_tls[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
    for ((i=0; i<"${#domain_tls[@]}"; i++)); do
        echo -e " - 尝试通过 Nginx 申请证书的域名: ${domain_tls[i]}"
        sudo ~/.acme.sh/acme.sh --issue -d ${domain_tls[i]} -w /var/www/letsencrypt --force > /dev/null 2>&1
    done
    [ ${#domain_tls[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
    for ((i=0; i<"${#domain_tls[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${domain_tls[i]}_ecc/fullchain.cer" ]; then
            sudo ~/.acme.sh/acme.sh --installcert -d "${domain_tls[i]}" --fullchainpath "/etc/tls/${domain_tls[i]}.crt" --keypath "/etc/tls/${domain_tls[i]}.key" > /dev/null 2>&1
        else
            sudo rm -f "/etc/tls/${domain_tls[i]}.key" "/etc/tls/${domain_tls[i]}.crt" > /dev/null 2>&1
        fi
    done
    show_domain_tls_info
}
selected_domain_or_tls(){
    tls_directory="/etc/tls"
    tls_domains=()
    cdn_domains=()
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    else
        local_ip=$(curl -s https://api64.ipify.org)
        if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
            echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
            display_pause_info
            return 1
        else
            if [ -d "$tls_directory" ]; then
            all_domains=($(ls -1 "$tls_directory"/*.crt | xargs -n1 basename | sed 's/\.crt//'))
            sorted_domains=($(printf "%s\n" "${all_domains[@]}" | sort))
            max_length=0
            for domain in "${sorted_domains[@]}"; do
                length=${#domain}
                if [ "$length" -gt "$max_length" ]; then
                max_length="$length"
                fi
            done
            echo -e "\e[1;31m当前已保存的域名TLS证书及有效期:\e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
            i=0
            for domain in "${sorted_domains[@]}"; do
                i=$((i+1))
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("\e[1;32m$i) $domain - TLS\e[0m")
                is_tls="TLS"
                color_code="\e[1;32m"
                else
                cdn_domains+=("\e[1;33m$i) $domain - CDN\e[0m")
                is_tls="CDN"
                color_code="\e[1;33m"
                fi
                if openssl x509 -in "$tls_directory/$domain.crt" -noout -dates &>/dev/null; then
                start_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
                end_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
                if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                    start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                    end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                    printf "${color_code}%2s) %-$((max_length + 5))s - %s   - 证书有效期: %s 至 %s\e[0m\n" "$i" "$domain" "$is_tls" "$start_date" "$end_date"
                else
                    echo -e "\e[1;35m日期解析失败: $domain\e[0m" >&2
                fi
                fi
            done
            for ((i = 0; i < 88; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
            if [ ${#all_domains[@]} -eq 1 ]; then
                    selected_domain="${sorted_domains[0]}"
                    echo -e "\e[1;33m当前有且只存在一个有效域名TLS: \e[0m \e[1;32m$selected_domain\e[0m"
                else
                    if [ ${#all_domains[@]} -eq 0 ]; then
                        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
                        return 1 
                    fi
                    while true; do
                    read -r -p "请选择一个域名的序号: " choice
                    selected_domain=""
                    if [ "$choice" -ge 1 ] && [ "$choice" -le "$i" ]; then
                        selected_domain="${sorted_domains[$((choice-1))]}"
                        echo -e "\e[1;33m你选择了域名: \e[0m\e[1;32m$selected_domain\e[0m"
                        return 0
                    else
                        echo -e "\e[1;31m无效的选择，请重新输入\e[0m"
                    fi
                    done
                fi
            else
                echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
            fi
        fi
        
    fi
}
singbox_domain_set2(){
    clear
    singbox_domain_set
    display_pause_info
}
user_xray_new() {
    clear
    path_count=88
    xray_config_files
    get_xray_tags
    if [ -e "$xray_config_file" ] ; then
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
        new_ids=()
        if [ ${#new_tags[@]} -eq 0 ]; then
            echo " - 未发现新用户的标签。退出。"
            exit 0
        fi
        for i in "${!new_tags[@]}"; do
            current_tag=${new_tags[$i]}
            [[ "$current_tag" == "api" ]] && continue
            next_tag=${new_tags[$((i+1))]}
            if [ -z "$next_tag" ]; then
                continue
            fi
            ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            for id in "${ids[@]}"; do
                if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                    new_ids+=("$id")
                fi
            done
        done
        unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        PS3=$'\e[1;33m - 请选择一个序号: \e[0m '
        select chosen_uuid in "${unique_new_ids[@]}"; do
            if [ -n "$chosen_uuid" ]; then
                echo -e "\e[1;91m - 你选择了序号 $REPLY: $chosen_uuid\e[0m"
                break
            else
                echo -e "\e[1;31m - 无效的选择, 请重新选择。\e[0m"
            fi
        done
        selected_domain_or_tls
        trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&alpn=http%2F1.1&type=tcp&headerType=none&host=example.com#tagname"
        trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
        trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
        vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
        vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp&headerType=http&path=/yourpath#tagname"
        vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
        vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
        vmess_tcp_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"auto","net":"tcp","type":"http","host":"","path":"/yourpath","tls":"tls","sni":"","alpn":"","fp":""}'
        vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
        vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
        shadowsocks="2022-blake3-aes-128-gcm:Password:base64_uuid"
        k=0
        for i in "${!new_tags[@]}"; do
            current_tag=${new_tags[$i]} next_tag=${new_tags[$((i+1))]} line_cont=${new_tags[$((i+1))]}
            current_tag="${new_tags[i]}"
            next_tag="${new_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="${old_tags[0]}"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${new_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${new_tags[i]}" == *gRPC* ]]; then
                path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${new_tags[i]}" == *xTLS* ]]; then
                path_t=""
            fi
            short_uuid="${chosen_uuid:0:8}"
            tag_name=""
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    k=$((k+1))
                    case ${new_tags[i]} in
                        "VLess-xTLS")
                            current_template=$(echo "$vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-TCP")
                            current_template=$(echo "$trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-WS")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-Warp")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-gRPC")
                            current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-TCP")
                            current_template=$(echo "$vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-WS")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-Warp")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-gRPC")
                            current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${new_tags[i]^}_$short_uuid#")
                            ;;
                        "VMess-TCP")
                            current_template=$(echo "$vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "VMess-WS")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "VMess-Warp")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "VMess-gRPC")
                            current_template=$(echo "$vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "ShadowSocks-TCP")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选tcp，类型选http，下方选tls"
                            ;;
                        "ShadowSocks-WS")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                            ;;
                        "ShadowSocks-gRPC")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改不带斜杠的path:$path_t,传输协议选gRPC,伪装gun,下方选TLS，SNI填域名"
                            ;;
                        *)
                            tag_name=""
                        ;;
                    esac
                    tag_name="$current_template" 
                    printf "\e[1;32m%-2s\e[0m" "$k."
                    printf "\e[1;32m%-22s\e[0m\n" "${new_tags[i]}:"
                    printf "%-5s\n\n" "$tag_name"
            fi
        done
        echo -e "\e[1;91m  以TCP为主时, 需在客户端将 域名 或 HOST 或 SNI 都改成不开CDN的域名, 以WS/GRPC为主则使用开启CDN后的域名或优选IP ! \n\e[0m"
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
user_xray_old() {
    clear
    path_count=88
    xray_config_files
    get_xray_tags
    if [ -e "$xray_config_file" ] ; then
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
        new_ids=()
        if [ ${#old_tags[@]} -eq 0 ]; then
            echo " - 未发现老用户的标签。退出。"
            exit 0
        fi
        tag_name=()
        for i in "${!old_tags[@]}"; do
            current_tag=${old_tags[$i]}
            [[ "$current_tag" == "api" ]] && continue
            next_tag=${old_tags[$((i+1))]}
            if [ -z "$next_tag" ]; then
                continue
            fi
            ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            for id in "${ids[@]}"; do
                if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                    new_ids+=("$id")
                fi
            done
        done
        unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        PS3=$'\e[1;33m - 请选择一个序号: \e[0m '
        select chosen_uuid in "${unique_new_ids[@]}"; do
            if [ -n "$chosen_uuid" ]; then
                echo -e "\e[1;91m - 你选择了序号 $REPLY: $chosen_uuid\e[0m"
                break
            else
                echo -e "\e[1;31m - 无效的选择, 请重新选择。\e[0m"
            fi
        done
        selected_domain_or_tls
        trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&type=tcp#tagname"
        trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
        trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
        vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
        vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp#tagname"
        vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
        vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
        vmess_tcp_template='{"add":"example.com","aid":"0","host":"","id":"full_uuid","net":"tcp","path":"/yourpath","port":"443","ps":"tagname","sc":"none","sn":"","tls":"http","v":"2"}'
        vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
        vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
        shadowsocks="2022-blake3-aes-128-gcm:Password:base64_uuid"
        k=0
        for i in "${!old_tags[@]}"; do
            current_tag=${old_tags[$i]} next_tag=${old_tags[$((i+1))]} line_cont=${old_tags[$((i+1))]}
            current_tag="${old_tags[i]}"
            next_tag="${old_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="outbounds"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${old_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${old_tags[i]}" == *gRPC* ]]; then
                path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${old_tags[i]}" == *xTLS* ]]; then
                path_t=""
            fi
            short_uuid="${chosen_uuid:0:8}"
            tag_name=""
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    k=$((k+1))
                    case ${old_tags[i]} in
                        "Old-Trojan-WS")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-Trojan-gRPC")
                            current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-VLess-WS")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-Vless-gRPC")
                            current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${old_tags[i]^}_$short_uuid#")
                            ;;
                        "Old-VMess-WS")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "Old-ShadowSocks-WS")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${old_tags[i]^}_${short_uuid}_要加一个path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                            ;;
                        *)
                            tag_name=""
                        ;;
                    esac
                    tag_name="$current_template" 
                    printf "\e[1;32m%-2s\e[0m" "$k."
                    printf "\e[1;32m%-22s\e[0m\n" "${old_tags[i]}:"
                    printf "%-5s\n\n" "$tag_name"
            fi
        done
    else
        echo -e "\e[1;31m - Xray 配置文件缺失，操作中止。\e[0m"
    fi
    display_pause_info
}
user_sing_box() {
    clear
    path_count=150
    singbox_config_files
    if [ ! -e "$box_config_file" ]; then
        echo -e "\e[1;31m - Sing-Box 配置文件缺失，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=()
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    base64_names=()
    for tag in "vless" ; do
        [[ "$tag" == "vless" ]] && base64_names=("${names[@]}")
    done
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    PS3=$'\e[1;33m - 请选择一个序号: \e[0m '
    select option in "${base64_names[@]}"; do
        if [ -n "$option" ]; then
            echo -e "\e[1;91m - 你选择了序号 $REPLY: $option\e[0m"
            break
        else
            echo -e "\e[1;31m - 无效的选择, 请重新选择。\e[0m"
        fi
    done
    trojan_ws_template="trojan://full_uuid@example.com:listen_port?security=tls&sni=example.com&type=ws&path=yourpath#tagname"
    vmess_ws_template='{"add":"example.com","aid":"0","host":"example.com","id":"full_uuid","net":"ws","path":"yourpath","port":"listen_port","ps":"tagname","scy":"auto","sni":"example.com","tls":"tls","type":"","v":"2","alpn":"h2"}'
    shadowsocks_tcp_template="ss://Method:Password:base64_uuid@example.com:listen_port#tagname"
    vless_ws_template="vless://full_uuid@example.com:listen_port?security=tls&sni=example.com&alpn=h2&type=ws&path=yourpath&host=example.com&encryption=none&alpn=h2#tagname"
    tuic_tcp_template="tuic://full_uuid:base64_uuid@example.com:listen_port?congestion_control=cubic&alpn=h3&sni=example.com&udp_relay_mode=native#tagname"
    naive_tcp_template="naive+https://short_uuid:full_uuid@example.com:listen_port#tagname"
    hysteria2_tcp_template="hy2://full_uuid@example.com:listen_port?obfs=salamander&obfs-password=obfs_pw&mport=listen_port&insecure=1&sni=example.com#tagname"
    k=0
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
        type_t=$(echo "$content" | grep -oP '"type":\s*"\K[^\"]+' | sed -n '2p')
        Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
        names=($(echo "$content" | sed -n '/"name"\|"username"/p'))
        names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | sed 's/alterId:0//g' | tr ',' '\n'))
        names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
        names=($(echo "${names[@]}" | tr -d '{}'))
        filtered_names=()
        for ((j=0; j<${#names[@]}; j++)); do
            if [[ "${names[j]}" != *"name:"* ]] && [[ "${names[j]}" != *"username:"* ]]; then
                filtered_names+=("${names[j]}")
            fi
        done
        if [ "${tags[i]}" != "shadowsocks" ]; then
            names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
        else 
        names=("${filtered_names[@]}")
        fi
         [[ $type_t == *'ws'* ]] && type_x="ws" || type_x=""
        if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            method_t=$(echo "$content" | grep -oP '"method":\s*"\K[^\"]+' | head -n1)
        else
            password_t=""
            method_t=""
        fi
        if [ "$current_tag" == "tuic" ] ; then
            password_t=$'\e[93m与用户UUID对应的BASE64\e[0m'
        fi
        if [ "$current_tag" == "shadowsocks" ] ; then
            Domain_t=$Domain_tb
        fi
        Domain_tb=$Domain_t
        echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
        cont_id=0
        for u in "${names[@]}"; do
            option_base64=$(echo -n "$option" | base64 | tr -d '/+' | cut -c 1-22)
            option_base64+="=="
            if [ "$option" == "$u" ] || [ "$option_base64" == "$u" ]; then
                cont_id=1
                break
            fi
        done
        short_uuid="${option:0:8}"
        if [ "$cont_id" -eq 1 ]; then
                current_template=""
                k=$((k+1))
                case ${tags[i]} in
                    "trojan")
                        current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${tags[i]^}_WS_${short_uuid}#")
                        ;;
                    "vmess")
                        current_template=$(echo "$vmess_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${tags[i]^}_WS_${short_uuid}#")
                        current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n' )"
                        ;;
                    "shadowsocks")
                        current_template=$(echo "$shadowsocks_tcp_template" | sed -e "s#base64_uuid#$option_base64#"  -e "s#Password#$password_t#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[i]}#g" -e "s#Method#$method_t#" -e "s#tagname#${tags[i]^}_TCP_${short_uuid}#")
                        ;;
                    "vless")
                        current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${tags[i]^}_WS_${short_uuid}#")
                        ;;
                    "tuic")
                        current_template=$(echo "$tuic_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#base64_uuid#$option_base64#g" -e "s#listen_port#${ports[i]}#g" -e "s#example.com#$Domain_t#g" -e "s#tagname#${tags[i]^}_TCP_${short_uuid}#")
                        ;;
                    "naive")
                        current_template=$(echo "$naive_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[i]}#g" -e "s#short_uuid#$short_uuid#" -e "s#tagname#${tags[i]^}_TCP_${short_uuid}#")
                        ;;
                    "hysteria2")
                        current_template=$(echo "$hysteria2_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[i]}#g" -e "s#obfs_pw#$password_t#" -e "s#tagname#${tags[i]^}_TCP_${short_uuid}#")
                        ;;
                    *)
                        tag_name=""
                        ;;
                esac
                tag_name="$current_template" 
                printf "\e[1;32m%-2s\e[0m" "$k."
                printf "\e[1;32m%-22s\e[0m\n" "${tags[i]}:"
                printf "%-5s\n\n" "$tag_name"
        fi
    done 
       display_pause_info
}
get_sing_box_subscription() {
    path_count=88
    html_dir="/usr/share/nginx/html/box"
    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=()
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    base64_names=()
    trojan_ws_template="trojan://full_uuid@example.com:listen_port?security=tls&sni=example.com&type=ws&path=yourpath#tagname"
    vmess_ws_template='{"add":"example.com","aid":"0","host":"example.com","id":"full_uuid","net":"ws","path":"yourpath","port":"listen_port","ps":"tagname","scy":"auto","sni":"example.com","tls":"tls","type":"","v":"2","alpn":"h2"}'
    shadowsocks="2022-blake3-aes-128-gcm:Password:base64_uuid"
    vless_ws_template="vless://full_uuid@example.com:listen_port?security=tls&sni=example.com&alpn=h2&type=ws&path=yourpath&host=example.com&encryption=none&alpn=h2#tagname"
    tuic_tcp_template="tuic://full_uuid:base64_uuid@example.com:listen_port?congestion_control=cubic&alpn=h3&sni=example.com&udp_relay_mode=native#tagname"
    naive_tcp_template="naive+https://short_uuid:full_uuid@example.com:listen_port#tagname"
    hysteria2_tcp_template="hy2://full_uuid@example.com:listen_port?obfs=salamander&obfs-password=obfs_pw&mport=listen_port&insecure=1&sni=example.com#tagname"
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    mkdir -p "$html_dir"
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${names[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理Sing-Box非当前UUID新用户的订阅链接...\e[0m"
    for option in "${names[@]}"; do
        short_uuid="${option:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for i in "${!tags[@]}"; do
            k=$i
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
            [ -z "$next_tag" ] && next_tag="outbounds"
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
            type_t=$(echo "$content" | grep -oP '"type":\s*"\K[^\"]+' | sed -n '2p')
            Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
            [[ $type_t == *'ws'* ]] && type_x="ws" || type_x=""
            if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
                password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
                method_t=$(echo "$content" | grep -oP '"method":\s*"\K[^\"]+' | head -n1)
            else
                password_t=""
                method_t=""
            fi
            if [ "$current_tag" == "shadowsocks" ] ; then
                Domain_t=$Domain_tb
            fi
            Domain_tb=$Domain_t
            echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
            cont_id=0
            for u in "${names[@]}"; do
                option_base64=$(echo -n "$option" | base64 | tr -d '/+' | cut -c 1-22)
                option_base64+="=="
                if [ "$option" == "$u" ] || [ "$option_base64" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    k=$((k+1))
                    case $current_tag in
                        "trojan")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            ;;
                        "vmess")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n' )"
                            ;;
                        "shadowsocks")
                            current_template=$(echo "$shadowsocks" | sed -e "s#Password#$password_t#" -e "s#base64_uuid#$option_base64#")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$Domain_t:${ports[k]}#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}"
                            ;;
                        "vless")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            ;;
                        "tuic")
                            current_template=$(echo "$tuic_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#base64_uuid#$option_base64#g" -e "s#listen_port#${ports[k]}#g" -e "s#example.com#$Domain_t#g" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        "naive")
                            current_template=$(echo "$naive_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#short_uuid#$short_uuid#" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        "hysteria2")
                            current_template=$(echo "$hysteria2_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#obfs_pw#$password_t#g" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        *)
                            current_template=""
                            ;;
                    esac
            fi
            tag_name+=("$current_template")
        done 
            printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$option"
            echo "https://$Domain_t/box/$short_uuid/$option"
    done
    echo -e "\e[0;32m 所有Sing-Box用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$Domain_t/box/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
}
get_xray_new_subscription() {
    path_count=88
    get_xray_tags
    html_dir="/usr/share/nginx/html/xray"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    new_ids=()
    tag_name=()
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    mkdir -p "$html_dir"
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    selected_domain_or_tls
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理xRay非当前UUID新用户的订阅链接...\e[0m"
    trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&alpn=http%2F1.1&type=tcp&headerType=none&host=example.com#tagname"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
    vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp&headerType=http&path=/yourpath#tagname修改path:/yourpath"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_tcp_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"auto","net":"tcp","type":"http","host":"","path":"/yourpath","tls":"tls","sni":"","alpn":"","fp":""}'
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
    for chosen_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
         for i in "${!new_tags[@]}"; do
            current_tag=${new_tags[$i]} next_tag=${new_tags[$((i+1))]} line_cont=${new_tags[$((i+1))]}
            current_tag="${new_tags[i]}"
            next_tag="${new_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="${old_tags[0]}"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                if [ "$chosen_uuid" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${new_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${new_tags[i]}" == *gRPC* ]]; then
                path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${new_tags[i]}" == *xTLS* ]]; then
                path_t=""
            fi
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    k=$((k+1))
                    case ${new_tags[i]} in
                        "VLess-xTLS")
                            current_template=$(echo "$vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-TCP")
                            current_template=$(echo "$trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-WS")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-Warp")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-gRPC")
                            current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-TCP")
                            current_template=$(echo "$vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-WS")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-Warp")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VLess-gRPC")
                            current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${new_tags[i]^}_$short_uuid#")
                            ;;
                        "VMess-TCP")
                            current_template=$(echo "$vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "VMess-WS")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "VMess-Warp")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "VMess-gRPC")
                            current_template=$(echo "$vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "ShadowSocks-TCP")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选tcp，类型选http，下方选tls"
                            ;;
                        "ShadowSocks-WS")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                            ;;
                        "ShadowSocks-gRPC")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改不带斜杠的path:$path_t,传输协议选gRPC,伪装gun,下方选TLS，SNI填域名"
                            ;;
                        *)
                            current_template=""
                        ;;
                    esac
            fi
            tag_name+=("$current_template")
        done
            printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$chosen_uuid"
            echo "https://$selected_domain/xray/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay新用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/xray/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;33m  使用带TCP标签的协议时, 需在客户端将 域名 或 HOST 或 SNI 都改成不开CDN的域名\e[0m"
    echo -e "\e[1;33m  使用以WS/GRPC协议时则使用开启CDN后的域名或优选IP ! \e[0m"
}
get_xray_old_subscription() {
    get_xray_tags
    path_count=88
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
    all_path_t=()
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
    done
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        all_path_t[i]="${all_path_t[i]//\//}"
    done
    common_prefix=$(printf "%s\n" "${all_path_t[@]}" | awk -F "" 'NR==1{p=$0; next} {p=substr(p, 1, length <= length($0) ? length : length($0)); for(i=1;i<=length && substr($0,i,1)==substr(p,i,1);i++); p=substr(p, 1, i-1)} END{print p}')
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    old_ids=()
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo " - 未发现老用户的标签。退出。"
        exit 0
    fi
    html_dir="/usr/share/nginx/html/$common_prefix"
    tag_name=()
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${old_ids[*]} " == " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    mkdir -p "$html_dir"
    selected_domain_or_tls
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理xRay非当前UUID老用户的订阅链接...\e[0m"
    trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&type=tcp#tagname"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath&host=example.com#tagname_HOST填域名"
    vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
    vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp#tagname"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_tcp_template='{"add":"example.com","aid":"0","host":"","id":"full_uuid","net":"tcp","path":"/yourpath","port":"443","ps":"tagname","sc":"none","sn":"","tls":"http","v":"2"}'
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
    for chosen_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for i in "${!old_tags[@]}"; do
            current_tag=${old_tags[$i]} next_tag=${old_tags[$((i+1))]} line_cont=${old_tags[$((i+1))]}
            current_tag="${old_tags[i]}"
            next_tag="${old_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="outbounds"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                if [ "$chosen_uuid" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${old_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${old_tags[i]}" == *gRPC* ]]; then
                path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${old_tags[i]}" == *xTLS* ]]; then
                path_t=""
            fi
            short_uuid="${chosen_uuid:0:8}"
            tag_name=""
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    ((k++))
                    case ${old_tags[i]} in
                        "Old-Trojan-WS")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-Trojan-gRPC")
                            current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-VLess-WS")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-Vless-gRPC")
                            current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${old_tags[i]^}_$short_uuid#")
                            ;;
                        "Old-VMess-WS")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        "Old-ShadowSocks-WS")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${old_tags[i]^}_${short_uuid}_要加一个path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                            ;;
                        *)
                            current_template=""
                        ;;
                    esac
            fi
            tag_name+=("$current_template")
        done
            printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$chosen_uuid"
            echo "https://$selected_domain/$common_prefix/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay老用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/path前缀/UUID前8位/完整的UUID"
}
all_sing_box_subscription() {
    clear
    singbox_config_files
    get_sing_box_subscription
    display_pause_info
}
all_xray_new_subscription() {
    clear
    xray_config_files
    get_xray_new_subscription
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    display_pause_info
}
all_xray_old_subscription() {
    clear
    xray_config_files
    get_xray_old_subscription
    display_pause_info
}
all_subscription(){
    clear
    path_count=88
    xray_config_files
    singbox_config_files
    get_xray_new_subscription
    get_xray_old_subscription
    get_sing_box_subscription
    display_pause_info
}
quanx_all_subscription() {
    xray_config_files
    singbox_config_files
    get_xray_tags
    html_dir="/usr/share/nginx/html/quanx"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
   is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=()
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    base64_names=()
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    new_ids=()
    tag_name=()
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    old_ids=()
    tag_name=()
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${old_ids[*]} " == " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    mkdir -p "$html_dir"
    all_user_ids=($(echo "${names[@]}" "${unique_old_ids[@]}" "${unique_new_ids[@]}" | tr ' ' '\n' | sort -u))
    extension=($(find "/etc/tls" -type f \( -name "*.crt" -o -name "*.key" \) -exec basename {} \; | sed -E 's/\.(crt|key)//' | awk '!seen[$0]++'))
    if [ "${#extension[@]}" -gt 1 ]; then
        sorted_extension=($(printf '%s\n' "${extension[@]}" | sort))
        echo -e "\e[1;32m - 目前有多个有效的域名 TLS 证书。请选择一个域名: \e[0m"
        for i in "${!sorted_extension[@]}"; do
            printf "%-2s %-20s\n" "$((i+1))" "${sorted_extension[i]}"
        done
        while true; do
            read -r -p $'\e[1;33m - 请输入域名的序号: \e[0m' selected_number
            if [[ "$selected_number" =~ ^[0-9]+$ ]] && [ "$selected_number" -ge 1 ] && [ "$selected_number" -le "${#sorted_extension[@]}" ]; then
                selected_domain=${sorted_extension[$((selected_number-1))]}
                echo -e "\e[1;91m - 你选择了域名: $selected_domain\e[0m"
                break
            else
                echo -e "\e[0;91m - 无效的输入。请输入有效的数字。\e[0m"
            fi
        done
    else 
        selected_domain=${extension[0]}
    fi
    rm -rf  $html_dir
    echo -e "\e[0;32m - 清理xRay/Sing-Box所有UUID用户的订阅链接...\e[0m"
    quanx_xray_vmess_wss_template="vmess=example.com:443, method=aes-128-gcm, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=/yourpath, tls-verification=false, fast-open=false, udp-relay=false, aead=true, tag=tagname"
    quanx_xray_trojan_wss_template="trojan=example.com:443, password=full_uuid, over-tls=true, tls-verification=false, tls-host=example.com, fast-open=false, udp-relay=false, tag=tagname"
    quanx_xray_shadowsocks_wss_template="shadowsocks=example.com:443, method=chacha20-ietf-poly1305, password=passwordbase64, obfs=wss, obfs-uri=/yourpath, obfs-host=example.com, fast-open=false, udp-relay=false, tag=tagname"
    quanx_sing_box_vmess_wss_template="vmess=example.com:3610, method=aes-128-gcm, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=yourpath, tls-verification=false, fast-open=false, udp-relay=false, aead=true, tag=tagname"
    quanx_sing_box_trojan_wss_template="trojan=example.com:3600, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=yourpath, tls-verification=false, fast-open=false, udp-relay=false, tag=tagname"
    for chosen_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
         for i in "${!new_tags[@]}"; do
            current_tag=${new_tags[$i]} next_tag=${new_tags[$((i+1))]} line_cont=${new_tags[$((i+1))]}
            current_tag="${new_tags[i]}"
            next_tag="${new_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="${old_tags[0]}"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            new_path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${new_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${new_tags[i]}" == *gRPC* ]]; then
                new_path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${new_tags[i]}" == *xTLS* ]]; then
                new_path_t=""
            fi
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    k=$((k+1))
                    case ${new_tags[i]} in
                        "Trojan-WS")
                            current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "Trojan-Warp")
                            current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VMess-WS")
                            current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "VMess-Warp")
                            current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        "ShadowSocks-WS")
                            current_template=$(echo "$quanx_xray_shadowsocks_wss_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                            ;;
                        *)
                            current_template=""
                        ;;
                    esac
            fi
            tag_name+=("$current_template")
        done
            printf "%s\n" "${tag_name[@]}" > "$html_dir/$short_uuid/$chosen_uuid"
            echo "https://$selected_domain/quanx/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay新用户订阅链接生成完毕, 使用愉快! \e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for chosen_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
         for i in "${!old_tags[@]}"; do
            current_tag=${old_tags[$i]} next_tag=${old_tags[$((i+1))]} line_cont=${old_tags[$((i+1))]}
            current_tag="${old_tags[i]}"
            next_tag="${old_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="outbounds"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            old_path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${old_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${old_tags[i]}" == *gRPC* ]]; then
                old_path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${old_tags[i]}" == *xTLS* ]]; then
                old_path_t=""
            fi
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    k=$((k+1))
                    case ${old_tags[i]} in
                        "Old-Trojan-WS")
                            current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$old_path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-VMess-WS")
                            current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$old_path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        "Old-ShadowSocks-WS")
                            current_template=$(echo "$quanx_xray_shadowsocks_wss_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$old_path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                            ;;
                        *)
                            current_template=""
                        ;;
                    esac
            fi
            tag_name+=("$current_template")
        done
            printf "%s\n" "${tag_name[@]}"  >> "$html_dir/$short_uuid/$chosen_uuid"
            echo "https://$selected_domain/quanx/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay老用户订阅链接生成完毕, 使用愉快! \e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for option in "${names[@]}"; do
        short_uuid="${option:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for i in "${!tags[@]}"; do
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
            [ -z "$next_tag" ] && next_tag="outbounds"
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
            box_path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
            Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
            names=($(echo "$content" | sed -n '/"name"\|"username"/p'))
            names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | sed 's/alterId:0//g' | tr ',' '\n'))
            names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
            names=($(echo "${names[@]}" | tr -d '{}'))
            filtered_names=()
            for ((j=0; j<${#names[@]}; j++)); do
                if [[ "${names[j]}" != *"name:"* ]] && [[ "${names[j]}" != *"username:"* ]]; then
                    filtered_names+=("${names[j]}")
                fi
            done
            if [ "${tags[i]}" != "shadowsocks" ]; then
                names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
            else 
            names=("${filtered_names[@]}")
            fi
            if [ "$current_tag" == "shadowsocks" ] ; then
                Domain_t=$Domain_tb
            fi
            Domain_tb=$Domain_t
            echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
            cont_id=0
            for u in "${names[@]}"; do
                option_base64=$(echo -n "$option" | base64 | tr -d '/+' | cut -c 1-22)
                option_base64+="=="
                if [ "$option" == "$u" ] || [ "$option_base64" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
            if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    case ${tags[i]} in
                        "trojan")
                            current_template=$(echo "$quanx_sing_box_vmess_wss_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$box_path_t#" -e "s#tagname#${tags[i]^}_WS_${short_uuid}#")
                            ;;
                        "vmess")
                            current_template=$(echo "$quanx_sing_box_vmess_wss_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$box_path_t#" -e "s#tagname#${tags[i]^}_WS_${short_uuid}#")
                            ;;
                        *)
                            current_template=""
                            ;;
                    esac
            fi
            tag_name+=("$current_template")
        done 
            printf "%s\n" "${tag_name[@]}" >> "$html_dir/$short_uuid/$option"
            echo "https://$Domain_t/quanx/$short_uuid/$option"
    done
    echo -e "\e[0;32m 所有Sing-Box用户订阅链接生成完毕, 使用愉快! \e[0m"
    i=0
    for bas64_code in "${all_user_ids[@]}"; do
        short_uuid="${bas64_code:0:8}" 
        mv "$html_dir/$short_uuid/${all_user_ids[i]}" "$html_dir/$short_uuid/${all_user_ids[i]}-encoded"
        reencoded_base64=$(base64 < "$html_dir/$short_uuid/${all_user_ids[i]}-encoded")
        echo "$reencoded_base64" > "$html_dir/$short_uuid/${all_user_ids[i]}"
        rm -rf "$html_dir/$short_uuid/${all_user_ids[i]}-encoded"
        ((i++))
    done
        echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/quanx/UUID前8位/完整的UUID"
    display_pause_info
}
get_all_domains(){
  domain_array=()
  start_with_zero=""
  start_number=""
  domain_countb=""
  domain_count=""
  prefix="${selected_domain%%.*}"
  suffix="${selected_domain#*.}"
  numbers=$(echo "$prefix" | tr -cd '0-9')
  letters=$(echo "$prefix" | tr -cd 'A-Za-z')
  if [ -z "$numbers" ]; then
    echo -e " - \e[91m当前域名前缀无数字! \e[0m"
    no_nomber=true
    return 1
  fi
  if [[ $numbers =~ ^[0-9]$ ]]; then
    read -p "前缀只有一位数字，是否从0开始生成？ (按回车默认, y/n): " start_with_zero
    start_number=0
    start_with_zero=${start_with_zero:-y}
  elif [[ $numbers =~ ^[0-9][0-9]$ ]]; then
    read -p "前缀有两位数字，是否从00开始生成？ (按回车默认, y/n): " start_with_zero
    start_number=00
    start_with_zero=${start_with_zero:-y}
  elif [[ $numbers =~ ^[0-9][0-9][0-9]$ ]]; then
    read -p "前缀有两位数字，是否从000开始生成？ (按回车默认, y/n): " start_with_zero
    start_number=000
    start_with_zero=${start_with_zero:-y}
  elif [[ $numbers =~ ^[0-9][0-9][0-9][0-9]$ ]]; then
    read -p "前缀有两位数字，是否从0000开始生成？ (按回车默认, y/n): " start_with_zero
    start_number=0000
    start_with_zero=${start_with_zero:-y}
  fi
  if [[ $start_with_zero == "n" ]]; then
    while true; do
      read -p "请输入开始的数字序号（例如: 0 或 00）: " start_number
      if [[ "$start_number" =~ ^[0-9]+$ ]]; then
        break
      else
        echo "请输入有效的数字序号。"
      fi
    done
  fi
  read -p "要生成多少台前缀？: " domain_count
  domain_countb=$((start_number + domain_count))
  for ((i = start_number; i < domain_countb; i++)); do
    if [ ${#start_number} -eq 1 ]; then
      formatted_number=$i
    elif [ ${#start_number} -eq 2 ]; then
      formatted_number=$(printf "%02d" $i)
    elif [ ${#start_number} -eq 3 ]; then
      formatted_number=$(printf "%03d" $i)
    else
      formatted_number=$(printf "%04d" $i)
    fi
    new_domain="${letters}${formatted_number}.${suffix}"
    domain_array+=("$new_domain")
  done
  if ((domain_count % 5 == 0)); then
    columns=5
  elif ((domain_count % 4 == 0)); then
    columns=4
  elif ((domain_count % 3 == 0)); then
    columns=3
  elif ((domain_count % 2 == 0)); then
    columns=2
  fi
  for ((i = 0; i < ${#domain_array[@]}; i++)); do
    if [ $i -lt 9 ] && [ $domain_count -ge 9 ]; then
      echo -n " $((i + 1))) ${domain_array[i]}"
    else
      echo -n "$((i + 1))) ${domain_array[i]}"
    fi
    if (( (i + 1) % columns == 0 )); then
      echo
    else
      if [ $i -lt 9 ] && [ $domain_count -ge 9 ]; then
        echo -n "    "
      else
        echo -n "   "
      fi
    fi
  done
  if ((domain_count < 10 && domain_count % 5 == 0)); then
    echo
  fi
}
get_xray_new_domain_subscription() {
    path_count=88
    xray_config_files
    get_xray_tags
    html_dir="/usr/share/nginx/html/xray"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    new_ids=()
    tag_name=()
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    mkdir -p "$html_dir"
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    selected_domain_or_tls
    get_all_domains
    if [ "$no_number" = true ]; then
        display_pause_info
        return 1
    fi
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理xRay非当前UUID新用户的订阅链接...\e[0m"
    trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&alpn=http%2F1.1&type=tcp&headerType=none&host=example.com#tagname"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
    vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp&headerType=http&path=/yourpath#tagname修改path:/yourpath"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_tcp_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"auto","net":"tcp","type":"http","host":"","path":"/yourpath","tls":"tls","sni":"","alpn":"","fp":""}'
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
    for chosen_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for selected_domain in "${domain_array[@]}"; do
            for i in "${!new_tags[@]}"; do
                current_tag=${new_tags[$i]} next_tag=${new_tags[$((i+1))]} line_cont=${new_tags[$((i+1))]}
                current_tag="${new_tags[i]}"
                next_tag="${new_tags[i+1]}"
                if [ -z "$next_tag" ]; then
                    next_tag="${old_tags[0]}"
                fi
                content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                cont_id=0
                chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
                chosen_base64+="=="
                for u in "${uuid[@]}"; do
                    if [ "$chosen_uuid" == "$u" ]; then
                        cont_id=1
                        break
                    fi
                done
                for u in "${password[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                if [[ "${new_tags[i]}" == *"ShadowSocks"* ]]; then
                    pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                    for pw in "${pw_base64[@]}"; do
                    if [ "$chosen_base64" == "$pw" ]; then
                        cont_id=1
                        break
                    fi
                done
                fi
                if [[ "${new_tags[i]}" == *gRPC* ]]; then
                    path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
                fi
                if [[ "${new_tags[i]}" == *xTLS* ]]; then
                    path_t=""
                fi
                if [ "$cont_id" -eq 1 ]; then
                        current_template=""
                        k=$((k+1))
                        case ${new_tags[i]} in
                            "VLess-xTLS")
                                current_template=$(echo "$vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-TCP")
                                current_template=$(echo "$trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-WS")
                                current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-Warp")
                                current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-gRPC")
                                current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-TCP")
                                current_template=$(echo "$vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-WS")
                                current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-Warp")
                                current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-gRPC")
                                current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${new_tags[i]^}_$short_uuid#")
                                ;;
                            "VMess-TCP")
                                current_template=$(echo "$vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "VMess-WS")
                                current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "VMess-Warp")
                                current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "VMess-gRPC")
                                current_template=$(echo "$vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "ShadowSocks-TCP")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选tcp，类型选http，下方选tls"
                                ;;
                            "ShadowSocks-WS")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                                ;;
                            "ShadowSocks-gRPC")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改不带斜杠的path:$path_t,传输协议选gRPC,伪装gun,下方选TLS，SNI填域名"
                                ;;
                            *)
                                current_template=""
                            ;;
                        esac
                fi
                tag_name+=("$current_template")
            done
        done
        printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$chosen_uuid"
        echo "https://$selected_domain/xray/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay新用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/xray/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;33m  使用带TCP标签的协议时, 需在客户端将 域名 或 HOST 或 SNI 都改成不开CDN的域名\e[0m"
    echo -e "\e[1;33m  使用以WS/GRPC协议时则使用开启CDN后的域名或优选IP ! \e[0m"
    display_pause_info
}
get_xray_old_domain_subscription() {
    path_count=88
    xray_config_files
    get_xray_tags
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
    all_path_t=()
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
    done
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        all_path_t[i]="${all_path_t[i]//\//}"
    done
    common_prefix=$(printf "%s\n" "${all_path_t[@]}" | awk -F "" 'NR==1{p=$0; next} {p=substr(p, 1, length <= length($0) ? length : length($0)); for(i=1;i<=length && substr($0,i,1)==substr(p,i,1);i++); p=substr(p, 1, i-1)} END{print p}')
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    old_ids=()
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo " - 未发现老用户的标签。退出。"
        exit 0
    fi
    html_dir="/usr/share/nginx/html/nruan"
    tag_name=()
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${old_ids[*]} " == " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    mkdir -p "$html_dir"
    selected_domain_or_tls
    get_all_domains
    if [ "$no_number" = true ]; then
        display_pause_info
        return 1
    fi
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理xRay非当前UUID老用户的订阅链接...\e[0m"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath&host=example.com#tagname_HOST填域名"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
    for chosen_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for selected_domain in "${domain_array[@]}"; do
            for i in "${!old_tags[@]}"; do
                current_tag=${old_tags[$i]} next_tag=${old_tags[$((i+1))]} line_cont=${old_tags[$((i+1))]}
                current_tag="${old_tags[i]}"
                next_tag="${old_tags[i+1]}"
                if [ -z "$next_tag" ]; then
                    next_tag="outbounds"
                fi
                content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                cont_id=0
                chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
                chosen_base64+="=="
                for u in "${uuid[@]}"; do
                    if [ "$chosen_uuid" == "$u" ]; then
                        cont_id=1
                        break
                    fi
                done
                for u in "${password[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                if [[ "${old_tags[i]}" == *"ShadowSocks"* ]]; then
                    pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                    for pw in "${pw_base64[@]}"; do
                    if [ "$chosen_base64" == "$pw" ]; then
                        cont_id=1
                        break
                    fi
                done
                fi
                if [[ "${old_tags[i]}" == *gRPC* ]]; then
                    path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
                fi
                if [[ "${old_tags[i]}" == *xTLS* ]]; then
                    path_t=""
                fi
                short_uuid="${chosen_uuid:0:8}"
                tag_name=""
                if [ "$cont_id" -eq 1 ]; then
                        current_template=""
                        ((k++))
                        case ${old_tags[i]} in
                            "Old-Trojan-WS")
                                current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-Trojan-gRPC")
                                current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-VLess-WS")
                                current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-Vless-gRPC")
                                current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${old_tags[i]^}_$short_uuid#")
                                ;;
                            "Old-VMess-WS")
                                current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "Old-ShadowSocks-WS")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${old_tags[i]^}_${short_uuid}_要加一个path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                                ;;
                            *)
                                current_template=""
                            ;;
                        esac
                fi
                tag_name+=("$current_template")
            done
        done
        printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$chosen_uuid"
        echo "https://$selected_domain/nruan/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay老用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/path前缀/UUID前8位/完整的UUID"
    display_pause_info
}
quanx_all_domain_subscription() {
    xray_config_files
    singbox_config_files
    get_xray_tags
    html_dir="/usr/share/nginx/html/quanx"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
   is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=()
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    base64_names=()
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    new_ids=()
    tag_name=()
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    old_ids=()
    tag_name=()
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${old_ids[*]} " == " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    mkdir -p "$html_dir"
    all_user_ids=($(echo "${names[@]}" "${unique_old_ids[@]}" "${unique_new_ids[@]}" | tr ' ' '\n' | sort -u))
    extension=($(find "/etc/tls" -type f \( -name "*.crt" -o -name "*.key" \) -exec basename {} \; | sed -E 's/\.(crt|key)//' | awk '!seen[$0]++'))
    if [ "${#extension[@]}" -gt 1 ]; then
        sorted_extension=($(printf '%s\n' "${extension[@]}" | sort))
        echo -e "\e[1;32m - 目前有多个有效的域名 TLS 证书。请选择一个域名: \e[0m"
        for i in "${!sorted_extension[@]}"; do
            printf "%-2s %-20s\n" "$((i+1))" "${sorted_extension[i]}"
        done
        while true; do
            read -r -p $'\e[1;33m - 请输入域名的序号: \e[0m' selected_number
            if [[ "$selected_number" =~ ^[0-9]+$ ]] && [ "$selected_number" -ge 1 ] && [ "$selected_number" -le "${#sorted_extension[@]}" ]; then
                selected_domain=${sorted_extension[$((selected_number-1))]}
                echo -e "\e[1;91m - 你选择了域名: $selected_domain\e[0m"
                break
            else
                echo -e "\e[0;91m - 无效的输入。请输入有效的数字。\e[0m"
            fi
        done
    else 
        selected_domain=${extension[0]}
    fi
    selected_domain2=$selected_domain
    get_all_domains
    if [ "$no_number" = true ]; then
        display_pause_info
        return 1
    fi
    rm -rf  "$html_dir"
    echo -e "\e[0;32m - 清理xRay/Sing-Box所有UUID用户的订阅链接...\e[0m"
    quanx_xray_vmess_wss_template="vmess=example.com:443, method=aes-128-gcm, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=/yourpath, tls-verification=false, fast-open=false, udp-relay=false, aead=true, tag=tagname"
    quanx_xray_trojan_wss_template="trojan=example.com:443, password=full_uuid, over-tls=true, tls-verification=false, tls-host=example.com, fast-open=false, udp-relay=false, tag=tagname"
    quanx_xray_shadowsocks_wss_template="shadowsocks=example.com:443, method=chacha20-ietf-poly1305, password=passwordbase64, obfs=wss, obfs-uri=/yourpath, obfs-host=example.com, fast-open=false, udp-relay=false, tag=tagname"
    quanx_sing_box_vmess_wss_template="vmess=example.com:3610, method=aes-128-gcm, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=yourpath, tls-verification=false, fast-open=false, udp-relay=false, aead=true, tag=tagname"
    quanx_sing_box_trojan_wss_template="trojan=example.com:3600, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=yourpath, tls-verification=false, fast-open=false, udp-relay=false, tag=tagname"
    for chosen_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for selected_domain in "${domain_array[@]}"; do
            for i in "${!new_tags[@]}"; do
                current_tag=${new_tags[$i]} next_tag=${new_tags[$((i+1))]} line_cont=${new_tags[$((i+1))]}
                current_tag="${new_tags[i]}"
                next_tag="${new_tags[i+1]}"
                if [ -z "$next_tag" ]; then
                    next_tag="${old_tags[0]}"
                fi
                content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                new_path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                cont_id=0
                chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
                chosen_base64+="=="
                for u in "${uuid[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                for u in "${password[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                if [[ "${new_tags[i]}" == *"ShadowSocks"* ]]; then
                    pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                    for pw in "${pw_base64[@]}"; do
                    if [ "$chosen_base64" == "$pw" ]; then
                        cont_id=1
                        break
                    fi
                done
                fi
                if [[ "${new_tags[i]}" == *gRPC* ]]; then
                    new_path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
                fi
                if [[ "${new_tags[i]}" == *xTLS* ]]; then
                    new_path_t=""
                fi
                if [ "$cont_id" -eq 1 ]; then
                        current_template=""
                        k=$((k+1))
                        case ${new_tags[i]} in
                            "Trojan-WS")
                                current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-Warp")
                                current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VMess-WS")
                                current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VMess-Warp")
                                current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "ShadowSocks-WS")
                                current_template=$(echo "$quanx_xray_shadowsocks_wss_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$new_path_t/" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            *)
                                current_template=""
                            ;;
                        esac
                fi
                tag_name+=("$current_template")
            done
        done
        printf "%s\n" "${tag_name[@]}" > "$html_dir/$short_uuid/$chosen_uuid"
        echo "https://$selected_domain2/quanx/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay新用户订阅链接生成完毕, 使用愉快! \e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for chosen_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for selected_domain in "${domain_array[@]}"; do
            for i in "${!old_tags[@]}"; do
                current_tag=${old_tags[$i]} next_tag=${old_tags[$((i+1))]} line_cont=${old_tags[$((i+1))]}
                current_tag="${old_tags[i]}"
                next_tag="${old_tags[i+1]}"
                if [ -z "$next_tag" ]; then
                    next_tag="outbounds"
                fi
                content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                old_path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                cont_id=0
                chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
                chosen_base64+="=="
                for u in "${uuid[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                for u in "${password[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_uuid" == "$u" ] || [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                if [[ "${old_tags[i]}" == *"ShadowSocks"* ]]; then
                    pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                    for pw in "${pw_base64[@]}"; do
                    if [ "$chosen_base64" == "$pw" ]; then
                        cont_id=1
                        break
                    fi
                done
                fi
                if [[ "${old_tags[i]}" == *gRPC* ]]; then
                    old_path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
                fi
                if [[ "${old_tags[i]}" == *xTLS* ]]; then
                    old_path_t=""
                fi
                if [ "$cont_id" -eq 1 ]; then
                        current_template=""
                        k=$((k+1))
                        case ${old_tags[i]} in
                            "Old-Trojan-WS")
                                current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$old_path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-VMess-WS")
                                current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$old_path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-ShadowSocks-WS")
                                current_template=$(echo "$quanx_xray_shadowsocks_wss_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$old_path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            *)
                                current_template=""
                            ;;
                        esac
                fi
                tag_name+=("$current_template")
            done
        done
        printf "%s\n" "${tag_name[@]}"  >> "$html_dir/$short_uuid/$chosen_uuid"
        echo "https://$selected_domain2/quanx/$short_uuid/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay老用户订阅链接生成完毕, 使用愉快! \e[0m"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for option in "${names[@]}"; do
        short_uuid="${option:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
            for i in "${!tags[@]}"; do
                current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
                [ -z "$next_tag" ] && next_tag="outbounds"
                content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
                box_path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
                Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
                names=($(echo "$content" | sed -n '/"name"\|"username"/p'))
                names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | sed 's/alterId:0//g' | tr ',' '\n'))
                names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
                names=($(echo "${names[@]}" | tr -d '{}'))
                filtered_names=()
                for ((j=0; j<${#names[@]}; j++)); do
                    if [[ "${names[j]}" != *"name:"* ]] && [[ "${names[j]}" != *"username:"* ]]; then
                        filtered_names+=("${names[j]}")
                    fi
                done
                if [ "${tags[i]}" != "shadowsocks" ]; then
                    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
                else 
                names=("${filtered_names[@]}")
                fi
                if [ "$current_tag" == "shadowsocks" ] ; then
                    Domain_t=$Domain_tb
                fi
                Domain_tb=$Domain_t
                echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
                cont_id=0
                for u in "${names[@]}"; do
                    option_base64=$(echo -n "$option" | base64 | tr -d '/+' | cut -c 1-22)
                    option_base64+="=="
                    if [ "$option" == "$u" ] || [ "$option_base64" == "$u" ]; then
                        cont_id=1
                        break
                    fi
                done
                prefix="${Domain_t%%.*}"
                suffix="${Domain_t#*.}"
                numbers=$(echo "$prefix" | tr -cd '0-9')
                letters=$(echo "$prefix" | tr -cd 'A-Za-z')
                if [ -z "$numbers" ]; then
                    echo " - 当前域名前缀无数字，操作无效，退出。"
                    display_pause_info
                    return 1
                fi
                domain_array=()
                for ((i = start_number; i < domain_countb; i++)); do
                    if [ ${#start_number} -eq 1 ]; then
                    formatted_number=$i
                    elif [ ${#start_number} -eq 2 ]; then
                    formatted_number=$(printf "%02d" $i)
                    elif [ ${#start_number} -eq 3 ]; then
                    formatted_number=$(printf "%03d" $i)
                    else
                    formatted_number=$(printf "%04d" $i)
                    fi
                    new_domain="${letters}${formatted_number}.${suffix}"
                    domain_array+=("$new_domain")
                done
                for Domain_t in "${domain_array[@]}"; do
                    if [ "$cont_id" -eq 1 ]; then
                            current_template=""
                            case ${tags[i]} in
                                "trojan")
                                    current_template=$(echo "$quanx_sing_box_vmess_wss_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$box_path_t#" -e "s#tagname#box_${tags[i]^}_WS_${short_uuid}#")
                                    ;;
                                "vmess")
                                    current_template=$(echo "$quanx_sing_box_vmess_wss_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[i]}#g" -e "s#yourpath#$box_path_t#" -e "s#tagname#box_${tags[i]^}_WS_${short_uuid}#")
                                    ;;
                                *)
                                    current_template=""
                                    ;;
                            esac
                    fi
                    tag_name+=("$current_template")
                done
            done
        printf "%s\n" "${tag_name[@]}" >> "$html_dir/$short_uuid/$option"
        echo "https://$selected_domain2/quanx/$short_uuid/$option"
    done
    echo -e "\e[0;32m 所有Sing-Box用户订阅链接生成完毕, 使用愉快! \e[0m"
    i=0
    for bas64_code in "${all_user_ids[@]}"; do
        short_uuid="${bas64_code:0:8}" 
        mv "$html_dir/$short_uuid/${all_user_ids[i]}" "$html_dir/$short_uuid/${all_user_ids[i]}-encoded"
        reencoded_base64=$(base64 < "$html_dir/$short_uuid/${all_user_ids[i]}-encoded")
        echo "$reencoded_base64" > "$html_dir/$short_uuid/${all_user_ids[i]}"
        rm -rf "$html_dir/$short_uuid/${all_user_ids[i]}-encoded"
        ((i++))
    done
        echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain2/quanx/UUID前8位/完整的UUID"
    display_pause_info
}
get_sing_box_domain_subscription() {
    singbox_config_files
    path_count=88
    html_dir="/usr/share/nginx/html/box"
    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=()
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    trojan_ws_template="trojan://full_uuid@example.com:listen_port?security=tls&sni=example.com&type=ws&path=yourpath#tagname"
    vmess_ws_template='{"add":"example.com","aid":"0","host":"example.com","id":"full_uuid","net":"ws","path":"yourpath","port":"listen_port","ps":"tagname","scy":"auto","sni":"example.com","tls":"tls","type":"","v":"2","alpn":"h2"}'
    shadowsocks="2022-blake3-aes-128-gcm:Password:base64_uuid"
    vless_ws_template="vless://full_uuid@example.com:listen_port?security=tls&sni=example.com&alpn=h2&type=ws&path=yourpath&host=example.com&encryption=none&alpn=h2#tagname"
    tuic_tcp_template="tuic://full_uuid:base64_uuid@example.com:listen_port?congestion_control=cubic&alpn=h3&sni=example.com&udp_relay_mode=native#tagname"
    naive_tcp_template="naive+https://short_uuid:full_uuid@example.com:listen_port#tagname"
    hysteria2_tcp_template="hy2://full_uuid@example.com:listen_port?obfs=salamander&obfs-password=obfs_pw&mport=listen_port&insecure=1&sni=example.com#tagname"
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    mkdir -p "$html_dir"
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${names[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
        while true; do
        read -p "请输入开始的数字序号（例如: 0 或 00）: " start_number
        if [[ "$start_number" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "请输入有效的数字序号。"
        fi
        done
    read -p "要生成多少台前缀？: " domain_count
    domain_countb=$((start_number + domain_count))
    echo -e "\e[0;32m - 清理Sing-Box非当前UUID新用户的订阅链接...\e[0m"
    for option in "${names[@]}"; do
        short_uuid="${option:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        tag_name=()
        for i in "${!tags[@]}"; do
            k=$i
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
            [ -z "$next_tag" ] && next_tag="outbounds"
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
            type_t=$(echo "$content" | grep -oP '"type":\s*"\K[^\"]+' | sed -n '2p')
            Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
            [[ $type_t == *'ws'* ]] && type_x="ws" || type_x=""
            if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
                password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            else
                password_t=""
            fi
            if [ "$current_tag" == "shadowsocks" ] ; then
                Domain_t=$Domain_tb
            fi
            Domain_tb=$Domain_t
            echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
            cont_id=0
            for u in "${names[@]}"; do
                option_base64=$(echo -n "$option" | base64 | tr -d '/+' | cut -c 1-22)
                option_base64+="=="
                if [ "$option" == "$u" ] || [ "$option_base64" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
                prefix="${Domain_t%%.*}"
                suffix="${Domain_t#*.}"
                numbers=$(echo "$prefix" | tr -cd '0-9')
                letters=$(echo "$prefix" | tr -cd 'A-Za-z')
                if [ -z "$numbers" ]; then
                    echo -e " - \e[91m当前域名前缀无数字，操作无效，退出。\e[0m"
                    display_pause_info
                    return 1
                fi
                domain_array=()
                for ((i = start_number; i < domain_countb; i++)); do
                    if [ ${#start_number} -eq 1 ]; then
                    formatted_number=$i
                    elif [ ${#start_number} -eq 2 ]; then
                    formatted_number=$(printf "%02d" $i)
                    elif [ ${#start_number} -eq 3 ]; then
                    formatted_number=$(printf "%03d" $i)
                    else
                    formatted_number=$(printf "%04d" $i)
                    fi
                    new_domain="${letters}${formatted_number}.${suffix}"
                    domain_array+=("$new_domain")
                done
            selected_domain2=$Domain_t
            for Domain_t in "${domain_array[@]}"; do
                if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    case $current_tag in
                        "trojan")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            ;;
                        "vmess")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n' )"
                            ;;
                        "shadowsocks")
                            current_template=$(echo "$shadowsocks" | sed -e "s#Password#$password_t#" -e "s#base64_uuid#$option_base64#")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$Domain_t:${ports[k]}#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}"
                            ;;
                        "vless")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            ;;
                        "tuic")
                            current_template=$(echo "$tuic_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#base64_uuid#$option_base64#g" -e "s#listen_port#${ports[k]}#g" -e "s#example.com#$Domain_t#g" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        "naive")
                            current_template=$(echo "$naive_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#short_uuid#$short_uuid#" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        "hysteria2")
                            current_template=$(echo "$hysteria2_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#obfs_pw#$password_t#g" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        *)
                            current_template=""
                            ;;
                    esac
                fi
                tag_name+=("$current_template")
            done
        done 
        printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$option"
        echo "https://$selected_domain2/box/$short_uuid/$option"
    done
    echo -e "\e[0;32m 所有Sing-Box用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain2/box/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    display_pause_info
}
get_xray_new_tags_subscription() {
    path_count=88
    xray_config_files
    get_xray_tags
    html_dir="/usr/share/nginx/html/new"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    new_ids=()
    tag_name=()
    for i in "${!new_tags[@]}"; do
        current_tag=${new_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${new_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    mkdir -p "$html_dir"
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    selected_domain_or_tls
    get_all_domains
    if [ "$no_number" = true ]; then
        display_pause_info
        return 1
    fi
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理xRay非当前UUID新用户的订阅链接...\e[0m"
    trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&alpn=http%2F1.1&type=tcp&headerType=none&host=example.com#tagname"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
    vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp&headerType=http&path=/yourpath#tagname修改path:/yourpath"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_tcp_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"auto","net":"tcp","type":"http","host":"","path":"/yourpath","tls":"tls","sni":"","alpn":"","fp":""}'
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
    for chosen_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        for i in "${!new_tags[@]}"; do
        is_tag=$(echo "${new_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
        mkdir -p "$html_dir/$short_uuid/$is_tag"
        tag_name=()
            for selected_domain in "${domain_array[@]}"; do
                current_tag=${new_tags[$i]} next_tag=${new_tags[$((i+1))]} 
                current_tag="${new_tags[i]}"
                next_tag="${new_tags[i+1]}"
                if [ -z "$next_tag" ]; then
                    next_tag="${old_tags[0]}"
                fi
                content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
                cont_id=0
                chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
                chosen_base64+="=="
                for u in "${uuid[@]}"; do
                    if [ "$chosen_uuid" == "$u" ]; then
                        cont_id=1
                        break
                    fi
                done
                for u in "${password[@]}"; do
                    u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                    u_base64+="=="
                    if [ "$chosen_base64" == "$u_base64" ]; then
                        cont_id=1
                        break
                    fi
                done
                if [[ "${new_tags[i]}" == *"ShadowSocks"* ]]; then
                    pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                    for pw in "${pw_base64[@]}"; do
                    if [ "$chosen_base64" == "$pw" ]; then
                        cont_id=1
                        break
                    fi
                done
                fi
                if [[ "${new_tags[i]}" == *gRPC* ]]; then
                    path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
                fi
                if [[ "${new_tags[i]}" == *xTLS* ]]; then
                    path_t=""
                fi
                if [ "$cont_id" -eq 1 ]; then
                        current_template=""
                        k=$((k+1))
                        case ${new_tags[i]} in
                            "VLess-xTLS")
                                current_template=$(echo "$vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-TCP")
                                current_template=$(echo "$trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-WS")
                                current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-Warp")
                                current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "Trojan-gRPC")
                                current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-TCP")
                                current_template=$(echo "$vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-WS")
                                current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-Warp")
                                current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                ;;
                            "VLess-gRPC")
                                current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${new_tags[i]^}_$short_uuid#")
                                ;;
                            "VMess-TCP")
                                current_template=$(echo "$vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "VMess-WS")
                                current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "VMess-Warp")
                                current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "VMess-gRPC")
                                current_template=$(echo "$vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${new_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "ShadowSocks-TCP")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选tcp，类型选http，下方选tls"
                                ;;
                            "ShadowSocks-WS")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                                ;;
                            "ShadowSocks-gRPC")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${new_tags[i]^}_${short_uuid}_修改不带斜杠的path:$path_t,传输协议选gRPC,伪装gun,下方选TLS，SNI填域名"
                                ;;
                            *)
                                current_template=""
                            ;;
                        esac
                fi
                tag_name+=("$current_template")
            done
        printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
        echo "https://$selected_domain/new/$short_uuid/$is_tag/$chosen_uuid"
        done
    done
    echo -e "\e[0;32m 所有xRay新用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/xray/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;33m  使用带TCP标签的协议时, 需在客户端将 域名 或 HOST 或 SNI 都改成不开CDN的域名\e[0m"
    echo -e "\e[1;33m  使用以WS/GRPC协议时则使用开启CDN后的域名或优选IP ! \e[0m"
    display_pause_info
}
get_xray_old_tags_subscription() {
    path_count=88
    xray_config_files
    get_xray_tags
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
    all_path_t=()
    for i in "${!tags[@]}"; do
        if [[ "${tags[i]}" == "api" || "${tags[i]}" == *"xTLS"* ]]; then
            continue
        fi
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=($(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n 1))
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t+=($(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++'))
        fi
        all_path_t+=("${path_t[@]}")
    done
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        all_path_t[i]="${all_path_t[i]//\//}"
    done
    common_prefix=$(printf "%s\n" "${all_path_t[@]}" | awk -F "" 'NR==1{p=$0; next} {p=substr(p, 1, length <= length($0) ? length : length($0)); for(i=1;i<=length && substr($0,i,1)==substr(p,i,1);i++); p=substr(p, 1, i-1)} END{print p}')
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    old_ids=()
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo "No new tags found. Exiting."
        exit 0
    fi
    html_dir="/usr/share/nginx/html/old"
    tag_name=()
    for i in "${!old_tags[@]}"; do
        current_tag=${old_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${old_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${old_ids[*]} " == " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    mkdir -p "$html_dir"
    selected_domain_or_tls
    get_all_domains
    if [ "$no_number" = true ]; then
        display_pause_info
        return 1
    fi
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[0;32m - 清理xRay非当前UUID老用户的订阅链接...\e[0m"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath&host=example.com#tagname_HOST填域名"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
    for chosen_uuid in "${unique_old_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        for i in "${!old_tags[@]}"; do
            is_tag=$(echo "${old_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
            mkdir -p "$html_dir/$short_uuid/$is_tag"
            tag_name=()
            current_tag=${old_tags[$i]} next_tag=${old_tags[$((i+1))]} line_cont=${old_tags[$((i+1))]}
            current_tag="${old_tags[i]}"
            next_tag="${old_tags[i+1]}"
            if [ -z "$next_tag" ]; then
                next_tag="outbounds"
            fi
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
                if [ "$chosen_uuid" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
            for u in "${password[@]}"; do
                u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
                u_base64+="=="
                if [ "$chosen_base64" == "$u_base64" ]; then
                    cont_id=1
                    break
                fi
            done
            if [[ "${old_tags[i]}" == *"ShadowSocks"* ]]; then
                pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
                for pw in "${pw_base64[@]}"; do
                if [ "$chosen_base64" == "$pw" ]; then
                    cont_id=1
                    break
                fi
            done
            fi
            if [[ "${old_tags[i]}" == *gRPC* ]]; then
                path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${old_tags[i]}" == *xTLS* ]]; then
                path_t=""
            fi
            for selected_domain in "${domain_array[@]}"; do
                if [ "$cont_id" -eq 1 ]; then
                        current_template=""
                        ((k++))
                        case ${old_tags[i]} in
                            "Old-Trojan-WS")
                                current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-Trojan-gRPC")
                                current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-VLess-WS")
                                current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                ;;
                            "Old-Vless-gRPC")
                                current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${old_tags[i]^}_$short_uuid#")
                                ;;
                            "Old-VMess-WS")
                                current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${old_tags[i]^}_$short_uuid/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "Old-ShadowSocks-WS")
                                current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${old_tags[i]^}_${short_uuid}_要加一个path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                                ;;
                            *)
                                current_template=""
                            ;;
                        esac
                fi
                tag_name+=("$current_template")
            done
        done
        printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
        echo "https://$selected_domain/old/$short_uuid/$is_tag/$chosen_uuid"
    done
    echo -e "\e[0;32m 所有xRay老用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_domain/path前缀/UUID前8位/完整的UUID"
    display_pause_info
}
get_sing_box_tags_subscription() {
    singbox_config_files
    path_count=88
    html_dir="/usr/share/nginx/html/btag"
    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid
        base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=()
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    trojan_ws_template="trojan://full_uuid@example.com:listen_port?security=tls&sni=example.com&type=ws&path=yourpath#tagname"
    vmess_ws_template='{"add":"example.com","aid":"0","host":"example.com","id":"full_uuid","net":"ws","path":"yourpath","port":"listen_port","ps":"tagname","scy":"auto","sni":"example.com","tls":"tls","type":"","v":"2","alpn":"h2"}'
    shadowsocks="2022-blake3-aes-128-gcm:Password:base64_uuid"
    vless_ws_template="vless://full_uuid@example.com:listen_port?security=tls&sni=example.com&alpn=h2&type=ws&path=yourpath&host=example.com&encryption=none&alpn=h2#tagname"
    tuic_tcp_template="tuic://full_uuid:base64_uuid@example.com:listen_port?congestion_control=cubic&alpn=h3&sni=example.com&udp_relay_mode=native#tagname"
    naive_tcp_template="naive+https://short_uuid:full_uuid@example.com:listen_port#tagname"
    hysteria2_tcp_template="hy2://full_uuid@example.com:listen_port?obfs=salamander&obfs-password=obfs_pw&mport=listen_port&insecure=1&sni=example.com#tagname"
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port":\s*\K[^,]+'))
    mkdir -p "$html_dir"
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${names[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
        while true; do
        read -p "请输入开始的数字序号（例如: 0 或 00）: " start_number
        if [[ "$start_number" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "请输入有效的数字序号。"
        fi
        done
    read -p "要生成多少台前缀？: " domain_count
    domain_countb=$((start_number + domain_count))
    echo -e "\e[0;32m - 清理Sing-Box非当前UUID新用户的订阅链接...\e[0m"
    for option in "${names[@]}"; do
        short_uuid="${option:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        for i in "${!tags[@]}"; do
            k=$i
            current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
            [ -z "$next_tag" ] && next_tag="outbounds"
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
            type_t=$(echo "$content" | grep -oP '"type":\s*"\K[^\"]+' | sed -n '2p')
            Domain_t=$(echo "$content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
            [[ $type_t == *'ws'* ]] && type_x="ws" || type_x=""
            if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
                password_t=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
            else
                password_t=""
            fi
            if [ "$current_tag" == "shadowsocks" ] ; then
                Domain_t=$Domain_tb
            fi
            Domain_tb=$Domain_t
            echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
            cont_id=0
            for u in "${names[@]}"; do
                option_base64=$(echo -n "$option" | base64 | tr -d '/+' | cut -c 1-22)
                option_base64+="=="
                if [ "$option" == "$u" ] || [ "$option_base64" == "$u" ]; then
                    cont_id=1
                    break
                fi
            done
                prefix="${Domain_t%%.*}"
                suffix="${Domain_t#*.}"
                numbers=$(echo "$prefix" | tr -cd '0-9')
                letters=$(echo "$prefix" | tr -cd 'A-Za-z')
                if [ -z "$numbers" ]; then
                    echo " - 当前域名前缀无数字，操作无效，退出。"
                    display_pause_info
                    return 1
                fi
                domain_array=()
                for ((i = start_number; i < domain_countb; i++)); do
                    if [ ${#start_number} -eq 1 ]; then
                    formatted_number=$i
                    elif [ ${#start_number} -eq 2 ]; then
                    formatted_number=$(printf "%02d" $i)
                    elif [ ${#start_number} -eq 3 ]; then
                    formatted_number=$(printf "%03d" $i)
                    else
                    formatted_number=$(printf "%04d" $i)
                    fi
                    new_domain="${letters}${formatted_number}.${suffix}"
                    domain_array+=("$new_domain")
                done
            tag_name=()
            mkdir -p "$html_dir/$short_uuid/$current_tag"
            for Domain_t in "${domain_array[@]}"; do
                if [ "$cont_id" -eq 1 ]; then
                    current_template=""
                    prefix_a="${Domain_t%%.*}"
                    case $current_tag in
                        "trojan")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            ;;
                        "vmess")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n' )"
                            ;;
                        "shadowsocks")
                            current_template=$(echo "$shadowsocks" | sed -e "s#Password#$password_t#" -e "s#base64_uuid#$option_base64#")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$Domain_t:${ports[k]}#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}"
                            ;;
                        "vless")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g"  -e "s#listen_port#${ports[k]}#g" -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_WS_${short_uuid}#")
                            ;;
                        "tuic")
                            current_template=$(echo "$tuic_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#base64_uuid#$option_base64#g" -e "s#listen_port#${ports[k]}#g" -e "s#example.com#$Domain_t#g" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        "naive")
                            current_template=$(echo "$naive_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#short_uuid#$short_uuid#" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        "hysteria2")
                            current_template=$(echo "$hysteria2_tcp_template" | sed -e "s#full_uuid#$option#" -e "s#example.com#$Domain_t#g" -e "s#listen_port#${ports[k]}#g" -e "s#obfs_pw#$password_t#g" -e "s#tagname#${prefix_a^^}_${current_tag^}_TCP_${short_uuid}#")
                            ;;
                        *)
                            current_template=""
                            ;;
                    esac
                fi
                tag_name+=("$current_template")
            done
            printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$current_tag/$option"
            echo "https://$Domain_t/btag/$short_uuid/$current_tag/$option"
        done 
    done
    echo -e "\e[0;32m 所有Sing-Box用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$Domain_t/box/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
}
auto_xray_all_tags(){
   tls_directory="/etc/tls"
   if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
      echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
      display_pause_info
      return 1
   fi
   selected_tls=() selected_cdn=()
   if [ -d "$tls_directory" ] && \
   (find "$tls_directory" -maxdepth 1 -type f \( -name "*.crt" -o -name "*.key" \) | read); then
    all_domains=($(ls -1 "$tls_directory"/*.crt 2>/dev/null | xargs -n1 basename | sed 's/\.crt//'))
    sorted_domains=($(printf "%s\n" "${all_domains[@]}" | sort))
    max_length=0
        for domain in "${sorted_domains[@]}"; do
            length=${#domain}
            if [ "$length" -gt "$max_length" ]; then
            max_length="$length"
            fi
        done
        echo -e "\e[1;31m当前已保存的域名TLS证书及有效期:\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
        i=0
        for domain in "${sorted_domains[@]}"; do
            i=$((i+1))
            local_ip=$(curl -s ifconfig.me)
            if dig +short "$domain" | grep -q "$local_ip"; then
            tls_domains+=("\e[1;32m$i) $domain - TLS\e[0m")
            selected_tls+=($domain)
            is_tls="TLS"
            color_code="\e[1;32m"
            else
            selected_cdn+=($domain)
            cdn_domains+=("\e[1;33m$i) $domain - CDN\e[0m")
            is_tls="CDN"
            color_code="\e[1;33m"
            fi
            if openssl x509 -in "$tls_directory/$domain.crt" -noout -dates &>/dev/null; then
            start_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
            end_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
            if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                printf "${color_code}%2s) %-$((max_length + 5))s - %s   - 证书有效期: %s 至 %s\e[0m\n" "$i" "$domain" "$is_tls" "$start_date" "$end_date"
            else
                echo "日期解析失败: $domain" >&2
            fi
            else
            echo "无法读取证书或证书无效: $domain" >&2
            fi
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}";
    fi
    domain_array=()
    domain_count=""
    path_count=88
    xray_config_files
    xray_all_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' | grep -iv "api"))
    html_dir="/usr/share/nginx/html/xray"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    new_ids=()
    tag_name=()
    for i in "${!xray_all_tags[@]}"; do
        current_tag=${xray_all_tags[$i]}
        [[ "$current_tag" == "api" ]] && continue
        next_tag=${xray_all_tags[$((i+1))]}
        if [ -z "$next_tag" ]; then
            continue
        fi
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${new_ids[*]} " == " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    mkdir -p "$html_dir"
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    directories=$(ls -l "$html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${html_dir:?}/$matching_directory"
        fi
    done
    echo -e "\e[1;32m - 清理xRay非当前UUID新用户的订阅链接...\e[0m"
    trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&alpn=http%2F1.1&type=tcp&headerType=none&host=example.com#tagname"
    trojan_ws_template="trojan://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    trojan_grpc_template="trojan://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
    vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp&headerType=http&path=/yourpath#tagname修改path:/yourpath"
    vless_ws_template="vless://full_uuid@example.com:443?security=tls&type=ws&path=/yourpath#tagname"
    vless_grpc_template="vless://full_uuid@example.com:443?security=tls&type=grpc&serviceName=yourpath#tagname"
    vmess_tcp_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"auto","net":"tcp","type":"http","host":"","path":"/yourpath","tls":"tls","sni":"","alpn":"","fp":""}'
    vmess_ws_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
    vmess_grpc_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
    shadowsocks="chacha20-ietf-poly1305:passwordbase64"
        selected_tls="${selected_tls[0]}"
        selected_cdn="${selected_cdn[0]}"
         echo  -e "\e[1;33m已自动选择: \e[0m\e[1;32mTLS域名 $selected_tls\e[0m  -  \e[1;33mCDN域名 $selected_cdn\e[0m"
        prefix="${selected_tls%%.*}"
        suffix="${selected_tls#*.}"
        letters=$(echo "$prefix" | tr -cd 'A-Za-z')
        while true; do
        read -e -p "请输入开始的数字序号（例如: 0 或 00） [默认: 0]: " start_number
        start_number=${start_number:-0}
        if [[ $start_number =~ ^[0-9]+$ ]]; then
            break
        else
            echo "请输入有效的数字序号。"
        fi
        done
         if [[ -n $start_number ]]; then
            read -p "要生成多少台前缀？: " domain_count
               domain_countb=$((start_number + domain_count))
               for ((i = start_number; i < domain_countb; i++)); do
                  if [ ${#start_number} -eq 1 ]; then
                     formatted_number=$i
                  elif [ ${#start_number} -eq 2 ]; then
                     formatted_number=$(printf "%02d" $i)
                  elif [ ${#start_number} -eq 3 ]; then
                     formatted_number=$(printf "%03d" $i)
                  else
                     formatted_number=$(printf "%04d" $i)
                  fi
                  new_domain="${letters}${formatted_number}.${suffix}"
                  domain_array+=("$new_domain")
               done
               if ((domain_count % 5 == 0)); then
                  columns=5
               elif ((domain_count % 4 == 0)); then
                  columns=4
               elif ((domain_count % 3 == 0)); then
                  columns=3
               elif ((domain_count % 2 == 0)); then
                  columns=2
               fi
               for ((i = 0; i < ${#domain_array[@]}; i++)); do
                  if [ $i -lt 9 ] && [ $domain_count -ge 9 ]; then
                     echo -n " $((i + 1))) ${domain_array[i]}"
                  else
                     echo -n "$((i + 1))) ${domain_array[i]}"
                  fi
                  if (( (i + 1) % columns == 0 )); then
                     echo 
                  else
                     if [ $i -lt 9 ] && [ $domain_count -ge 9 ]; then
                     echo -n "    "
                     else
                     echo -n "   "
                     fi
                  fi
             done;echo
           else
            new_domain="${letters}$.${suffix}"
            domain_array+=("$new_domain")
         fi
    for chosen_uuid in "${unique_new_ids[@]}"; do
        short_uuid="${chosen_uuid:0:8}"
        mkdir -p "$html_dir/$short_uuid"
        for i in "${!xray_all_tags[@]}"; do
            current_tag="${xray_all_tags[i]}"
            next_tag="${xray_all_tags[i+1]}"
            if [ -z "$next_tag" ]; then
               next_tag="${old_tags[0]}"
            fi
            is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
            mkdir -p "$html_dir/$short_uuid/$is_tag"
            tag_name=()
            content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
            path_t=$(echo "$content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
            uuid=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            password=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
            cont_id=0
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            for u in "${uuid[@]}"; do
               if [ "$chosen_uuid" == "$u" ]; then
                  cont_id=1
                  break
               fi
            done
            for u in "${password[@]}"; do
               u_base64=$(echo -n "$u" | base64 | tr -d '/+' | cut -c 1-22)
               u_base64+="=="
               if [ "$chosen_base64" == "$u_base64" ]; then
                  cont_id=1
                  break
               fi
            done
            if [[ "${xray_all_tags[i]}" == *"ShadowSocks"* ]]; then
               pw_base64=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$xray_config_file" | awk -F'"' '{print $8}' | awk '!a[$0]++'))
               for pw in "${pw_base64[@]}"; do
               if [ "$chosen_base64" == "$pw" ]; then
                  cont_id=1
                  break
               fi
            done
            fi
            if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
               path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
            fi
            if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
               path_t=""
            fi
            domain_array=()
            if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* || ${current_tag,,} == *"-warp"* ]]; then
               suffix="${selected_cdn#*.}"
               else
               suffix="${selected_tls#*.}"
            fi
            if [[ -n $start_number ]]; then
                domain_countb=$((start_number + domain_count))
                for ((i = start_number; i < domain_countb; i++)); do
                    if [ ${#start_number} -eq 1 ]; then
                        formatted_number=$i
                    elif [ ${#start_number} -eq 2 ]; then
                        formatted_number=$(printf "%02d" $i)
                    elif [ ${#start_number} -eq 3 ]; then
                        formatted_number=$(printf "%03d" $i)
                    else
                        formatted_number=$(printf "%04d" $i)
                    fi
                    new_domain="${letters}${formatted_number}.${suffix}"
                    domain_array+=("$new_domain")
                done
                else
                new_domain="${letters}$.${suffix}"
                domain_array+=("$new_domain")
            fi
            if [ "$cont_id" -eq 1 ]; then
              if [[ ${current_tag,,} != *"old"* ]]; then
                  for selected_domain in "${domain_array[@]}"; do
                     current_template=""
                     prefix_a="${selected_domain%%.*}"
                     case $current_tag in
                        "VLess-xTLS")
                           current_template=$(echo "$vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/"${prefix_a^^}"_${current_tag^}_$short_uuid/")
                           ;;
                        "Trojan-TCP")
                           current_template=$(echo "$trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "Trojan-WS")
                           current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "Trojan-Warp")
                           current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "Trojan-gRPC")
                           current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "VLess-TCP")
                           current_template=$(echo "$vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "VLess-WS")
                           current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "VLess-Warp")
                           current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           ;;
                        "VLess-gRPC")
                           current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_$short_uuid#")
                           ;;
                        "VMess-TCP")
                           current_template=$(echo "$vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                           ;;
                        "VMess-WS")
                           current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                           ;;
                        "VMess-Warp")
                           current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                           ;;
                        "VMess-gRPC")
                           current_template=$(echo "$vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                           current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                           ;;
                        "ShadowSocks-TCP")
                           current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                           current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${short_uuid}_修改path:/$path_t,传输协议选tcp，类型选http，下方选tls"
                           ;;
                        "ShadowSocks-WS")
                           current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                           current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${short_uuid}_修改path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                           ;;
                        "ShadowSocks-gRPC")
                           current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                           current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${short_uuid}_修改不带斜杠的path:$path_t,传输协议选gRPC,伪装gun,下方选TLS，SNI填域名"
                           ;;
                        *)
                           current_template=""
                        ;;
                     esac
                     tag_name+=("$current_template")
                  done
                  else
                  for selected_domain in "${domain_array[@]}"; do
                    current_template=""
                    case $current_tag in
                            "Old-Trojan-WS")
                            current_template=$(echo "$trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                            ;;
                            "Old-Trojan-gRPC")
                            current_template=$(echo "$trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                            ;;
                            "Old-VLess-WS")
                            current_template=$(echo "$vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/" -e "s/yourpath/$path_t/" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                            ;;
                            "Old-Vless-gRPC")
                            current_template=$(echo "$vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$path_t#" -e "s#tagname#${prefix_a^^}_${current_tag^}_$short_uuid#")
                            ;;
                            "Old-VMess-WS")
                            current_template=$(echo "$vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$path_t/" -e "s/tagname/${prefix_a^^}_${current_tag^}_$short_uuid/")
                            current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                            "Old-ShadowSocks-WS")
                            current_template=$(echo "$shadowsocks" | sed -e "s/passwordbase64/$chosen_base64/")
                            current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${short_uuid}_要加一个path:/$path_t,传输协议选ws，HOST和SNI都填域名"
                            ;;
                            *)
                            current_template=""
                            ;;
                    esac
                  done
                fi
                printf "%s\n" "${tag_name[@]}" | base64 > "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                echo "https://$selected_cdn/xray/$short_uuid/$is_tag/$chosen_uuid"
            fi
        done
    done
    echo -e "\e[1;32m 所有xRay新用户订阅链接生成完毕, 使用愉快! \e[0m"
    echo -e "\e[0;33m 订阅链接格式为: \e[0m https://$selected_cdn/xray/UUID前8位/完整的UUID"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;33m  使用带TCP标签的协议时, 需在客户端将 域名 或 HOST 或 SNI 都改成不开CDN的域名\e[0m"
    echo -e "\e[1;33m  使用以WS/GRPC协议时则使用开启CDN后的域名或优选IP ! \e[0m"
    display_pause_info
}
clear_all_subscriptions() {
    path_count=88
    clear
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    dir="/usr/share/nginx/html/"
    if [ "$(find "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)" ]; then
        find "$dir" -mindepth 1 -maxdepth 1 -type d -exec rm -r {} \;
        echo -e "\e[1;32m      所有订阅已清空, 如有需要, 请重新生成! \e[0m"
    else
        echo -e "\e[1;33m      当前未存在订阅文件! \e[0m"
    fi
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    display_pause_info
}
xray_protocol_details(){
    clear
    xray_tags=()
    xray_tag_all=()
    xray_tag_line_before=()
    xray_tag_line_end=()
    xray_config_file="/usr/local/etc/xray/config.json"
    output_tags=$(awk '/"inbounds"/,/"outbounds"/ { 
            if (/\"tag\"\s*:/) {
                i++
                xray_tag_all[i]=$2
                xray_tag_line_before[i]=prev
            } 
            prev2 = prev
            prev = $0
            xray_tag_line_end[i]=prev2
        } 
        END {
            for (j=1; j<=i; j++) 
                printf("%s\n%s\n%s\n", xray_tag_all[j], xray_tag_line_before[j], xray_tag_line_end[j])
        }' "$xray_config_file")
    while read -r line; do
        xray_tag_all+=("$line")
        IFS= read -r line
        xray_tag_line_before+=("$line")
        IFS= read -r line
        xray_tag_line_end+=("$line")
    done <<< "$output_tags"
    for tag in "${xray_tag_all[@]}"; do
        if [[ $tag =~ \"([^\"]+)\" ]]; then
            xray_tags+=("${BASH_REMATCH[1]}")
        fi
    done
    j=1
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    for ((i=1; i < ${#xray_tags[@]}; i++)); do
        echo "$((j++)). ${xray_tags[i]}"
    done
    user_choice=""
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    echo " - 请选择一个要查看的 tag: "
    read -p " - 请输入对应的数字: " user_choice
    clear
    if ((user_choice >= 1 && user_choice < ${#xray_tags[@]})); then
        selected_tag="${xray_tags[user_choice]}"
        echo " - 你所选择的 tag 是: $selected_tag"
        xray_protocol=()
        selected_tag='"tag": "'${selected_tag}'"'
        out_protocol=$(awk '/'"$selected_tag"'/,/'"${xray_tag_line_end[$user_choice]}"'/ {if (NR > 1) print prev; prev=$0} END {if (NR > 1 && !found) print prev}' "$xray_config_file")
        echo "                                 ===== 详 细 信 息 如 下====="
        for ((i = 0; i < path_count; i++)); do
            echo -n -e "${light_gray}-"
        done
        echo -e "${reset_color}"
        xray_protocol+=("${xray_tag_line_before[$user_choice]}")
        while IFS= read -r line; do
            xray_protocol+=("$line")
        done <<< "$(tail -n +2 <<< "$out_protocol")"
        printf "%s\n" "${xray_protocol[@]}"
        for ((i = 0; i < path_count; i++)); do
            echo -n -e "${light_gray}-"
        done
        echo -e "${reset_color}"
    else
        echo " - 无效的选择。请确保输入的数字在有效范围内。"
    fi
    display_pause_info
}
xray_subscription_intro(){
    cdn_domains=() tls_domains=() selected_tls=() selected_cdn=()  xray_tag_all_uuid=() 
    tls_directory="/etc/tls"
    path_count=88
    xray_config_files
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -d "$tls_directory" ] && \
        (find "$tls_directory" -maxdepth 1 -type f \( -name "*.crt" -o -name "*.key" \) | read); then
        all_domains=($(ls -1 "$tls_directory"/*.crt 2>/dev/null | xargs -n1 basename | sed 's/\.crt//'))
        sorted_domains=($(printf "%s\n" "${all_domains[@]}" | sort))
        max_length=0
            for domain in "${sorted_domains[@]}"; do
                length=${#domain}
                if [ "$length" -gt "$max_length" ]; then
                max_length="$length"
                fi
            done
            echo -e "\e[1;31m -- 当前已存在的域名TLS证书及有效期:\e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            i=0
            for domain in "${sorted_domains[@]}"; do
                i=$((i+1))
                local_ip=$(curl -s ifconfig.me)
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("\e[1;32m$i) $domain - TLS\e[0m")
                selected_tls+=($domain)
                is_tls="TLS"
                color_code="\e[1;32m"
                else
                selected_cdn+=($domain)
                cdn_domains+=("\e[1;33m$i) $domain - CDN\e[0m")
                is_tls="CDN"
                color_code="\e[1;33m"
                fi
                if openssl x509 -in "$tls_directory/$domain.crt" -noout -dates &>/dev/null; then
                start_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
                end_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
                if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                    start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                    end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                    printf "${color_code}%2s) %-$((max_length + 5))s - %s   - 证书有效期: %s 至 %s\e[0m\n" "$i" "$domain" "$is_tls" "$start_date" "$end_date"
                else
                    echo "日期解析失败: $domain" >&2
                fi
                else
                echo "无法读取证书或证书无效: $domain" >&2
                fi
            done
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
    fi
    xray_all_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag":\s*"\K[^"]+' | grep -iv "api"))
    if [ "${#xray_all_tags[@]}" -eq 0 ]; then
        echo -e "\e[1;31m - 错误:无法读到xRay文件信息\e[0m"
        display_pause_info
        return 1
    fi
    xray_input_count=0
    while true; do
        read -p "请输入要生成的订阅目录，默认为$xray_subscription_dir（5秒超时自动确认）: " -t 5 input_subscription_dir
        if [ -n "$input_subscription_dir" ]; then
            xray_subscription_dir="$input_subscription_dir"
            break
        elif [ -z "$input_subscription_dir" ]; then
            xray_input_count=$((xray_input_count + 1))
        fi
        if [ "$xray_input_count" -ge 3 ]; then
            random_string=$(openssl rand -hex 4)
            xray_subscription_dir="$random_string"
            echo -e "\n - 生成随机字符串: $xray_subscription_dir"
            break
        else
            echo -e "\n - \e[1;31m等待用户输入超时，已自动确认。\e[0m"
            break
        fi
    done
    html_dir="/usr/share/nginx/html/$xray_type_dir/$xray_subscription_dir"
    for i in "${!xray_all_tags[@]}"; do
        current_tag="${xray_all_tags[i]}"
        next_tag="${xray_all_tags[i+1]}"
        [[ -z "$next_tag" ]] && next_tag="outbounds"
        xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
        xray_tag_all_uuid+=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
        xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
    done
    unique_xray_tag_all_uuids=($(echo "${xray_tag_all_uuid[@]}" | tr ' ' '\n' | awk '!a[$0]++'))
    if [ "${#xray_all_tags[@]}" -eq 0 ]; then
        echo -e "\e[1;31m - 错误:无法读到xRay配置文件信息\e[0m"
        display_pause_info
        return 1
        else
        echo  -e "\e[1;33m - 正在收集用户信息，请稍后...\e[0m"
        mkdir -p "/usr/share/nginx/html/$xray_type_dir"
        mkdir -p "$html_dir"
        mkdir -p "/etc/$xray_type_dir"
        sleep 2
    fi
    xray_domain_array=()
    if [ "${#sorted_domains[@]}" -gt 0 ]; then
        if [ "${#selected_tls[@]}" -gt 0 ]; then
            domain_tls=${selected_tls[0]}
        else
            domain_tls=${selected_cdn[0]}
        fi
        if [ "${#selected_cdn[@]}" -gt 0 ]; then
            domain_cdn=${selected_cdn[0]}
        else
            domain_cdn=${selected_tls[0]}
        fi
        echo  -e "\e[1;31m - 已自动选择: \e[0m\e[1;32mTLS域名 $domain_tls\e[0m  -  \e[1;33mCDN域名 $domain_cdn\e[0m"
        prefix="${domain_tls%%.*}"
        suffix="${domain_tls#*.}"
        numbers=$(echo "$prefix" | tr -cd '0-9')
        letters=$(echo "$prefix" | tr -cd 'A-Za-z')
        no_nomber=false
        if [ -z "$numbers" ]; then
            echo -e " - \e[1;31m当前TLS域名前缀不包含数字。\e[0m"
            domain_array=($domain_tls)
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            echo -e " - \e[1;32m将为 ${domain_array[@]} 生成相关配置信息。\e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            no_nomber=true
        fi
    fi
    if [ "$no_nomber" = false ]; then
        length=${#numbers}
        letters_zero=$(printf '0%.0s' $(seq 1 $length))
    fi
    if [ "$no_nomber" = false ]; then
        timeout_flag=0
        if [[ $numbers =~ ^[0-9]+$ ]]; then
            echo -en " - 检测到前缀\e[1;31m ${length}\e[0m 位数字, 初始序号为 \e[1;31m${letters_zero}\e[0m，请输入域名开始的序号？ (按回车默认, 5秒超时): "
            read -r -p "" -t 5 start_number || timeout_flag=1
            start_number=${start_number:-$letters_zero}
            if [ "$timeout_flag" -eq 1 ]; then
                start_number=$letters_zero
                echo -e "\n - \e[1;31m等待用户输入超时，已自动确认。\e[0m"
            fi
        fi
    fi
    if [ -n "$start_number" ]; then
        length=${#start_number}
        echo -en " - 有多少台机子使用共同前缀(\e[1;32m$letters\e[0m)？ (默认为 10台, 5秒超时): "
        read -t 5 -p  "" domain_count|| timeout_flag=1
        [ "$timeout_flag" -eq 1 ] && echo
        domain_count=${domain_count:-10}  
    fi
    if [ -n "$domain_count" ]; then
        domain_countb=$((start_number + domain_count))
        for ((i = start_number; i < domain_countb; i++)); do
            formatted_number=$(printf "%0${length}d" $i)
            new_domain="${letters}${formatted_number}.${suffix}"
            domain_array+=("$new_domain")
            xray_domain_array+=("$new_domain")
        done
        default_domain=("${xray_domain_array[@]}")
    fi
    if [ ${#default_domain[@]} -lt 1 ]; then
        if [ -z "${xray_domain_array[*]}" ]; then
            echo -e "\e[93m - 请输入域名，每行一个，以回车或空行结束输入。\e[0m"
            IFS=$'\n' read -r -a xray_domain_array
            if [ ${#xray_domain_array[@]} -gt 0 ]; then
                while IFS= read -r line && [ -n "$line" ]; do
                    IFS=$' \t,' read -ra line_array <<< "$line"
                    for domain_input in "${line_array[@]}"; do
                        xray_domain_array+=("$domain_input")
                    done
                done
                xray_domain_array=($(echo "${xray_domain_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
                default_domain=("${xray_domain_array[@]}")
            else
                echo -e "\e[1;31m - 域名订阅清单为空\e[0m"
                for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            fi
            default_domain=("${xray_domain_array[@]}")
        fi
        else
        xray_domain_array=("${default_domain[@]}")
    fi
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        max_line_length=80
        echo -e "\e[1;32m - 当前要生成的域名订阅清单如下: \e[0m"
        current_line_length=0
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        for ((i=0; i<${#xray_domain_array[@]}; i++)); do
            current_line_length=$((current_line_length + ${#xray_domain_array[$i]} + 2))
            echo -n "${xray_domain_array[$i]}  "
            if [ $current_line_length -ge $max_line_length ]; then
                echo
                current_line_length=0
            fi
        done
        [[ $current_line_length -ne 0 ]] && echo
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
    fi
    if [ "${#country_array[@]}" -lt "${#xray_domain_array[@]}" ]; then
        for xray_domain in "${xray_domain_array[@]}"; do
            domain="$xray_domain"
            ip_address=$(dig +short $domain)
            if [ -n "$ip_address" ]; then
                location_info=$(curl -s "https://ipapi.co/$ip_address/json/")
                country=$(echo "$location_info" | grep -o '"country": "[^"]*' | awk -F'": "' '{print $2}')
                [ -z "$country" ] && country="NA"
            else
                country="NA"
            fi
            country_array+=("$country")
        done
    fi
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        echo -e "\e[1;32m - 域名与归属地清单如下: \e[0m"
        current_line_length=0
        for ((i=0; i<${#xray_domain_array[@]}; i++)); do
            xray_domain=${xray_domain_array[$i]}
            prefix="${xray_domain%%.*}"
            country=${country_array[$i]}
            current_line_length=$((current_line_length + ${#country} + ${#xray_domain_array[$i]} + 6))
            echo -n "$xray_domain -$country  "
            if [ $current_line_length -ge $max_line_length ]; then
                echo
                current_line_length=0
            fi
        done
        [[ $current_line_length -ne 0 ]] && echo
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
    fi
    while [ -z "$enable_preferences" ]; do
        echo -e "\e[93m - 未检测到优选域名清单，是否启用优选域名功能 (Y/N)？\e[0m"
        read -r answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        if [ "$answer" = "y" ]; then
            enable_preferences="yes"
        elif [ "$answer" = "n" ]; then
            enable_preferences="no"
        else
            echo "无效的输入，请输入 Y 或 N"
        fi
    done

    if [ "$enable_preferences" = "yes" ]; then
        if [ ${#preferred_sorted_domains[@]} -eq 0 ]; then
            echo -e "\e[93m - 请输入优选域名清单，每行一个，以回车或空行结束输入。\e[0m"
            IFS=$'\n' read -r -a preferred_domains
            if [ ${#preferred_domains[@]} -gt 0 ]; then
                while IFS= read -r line && [ -n "$line" ]; do
                    IFS=$' \t,' read -ra line_array <<< "$line"
                    for domain_input in "${line_array[@]}"; do
                        preferred_domains+=("$domain_input")
                    done
                done
                preferred_domains=($(echo "${preferred_domains[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
                else
                echo -e "\e[1;31m - 优选域名清单为空\e[0m"
                for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            fi
            echo -e "\e[93m - 正在处理优选域名，请稍后【每个域名PING 2 次，取最优前20个】\e[0m"
            declare -A ping_results
            for domain in "${preferred_domains[@]}"; do
                ping_result=$(ping -c 2 -q "$domain" 2>/dev/null | grep 'rtt min/avg/max/mdev' | awk -F '/' '{print $5}')
                if [ -n "$ping_result" ]; then
                    ping_results["$domain"]=$ping_result
                fi
            done
            preferred_sorted_domains=()
            for domain in "${!ping_results[@]}"; do
                preferred_sorted_domains+=("$domain")
            done
            preferred_sorted_domains=($(printf "%s\n" "${preferred_sorted_domains[@]}" | sort | head -n 20))
            else
            echo -e "\e[93m - 优选域名已存在数据，跳过输入。\e[0m"
        fi
        if [ ${#preferred_sorted_domains[@]} -ne 0 ]; then
            max_line_length=80
            echo -e "\e[1;32m - 优选域名清单如下: \e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            current_line_length=0
            for ((i=0; i<${#preferred_sorted_domains[@]}; i++)); do
                domain_info=${preferred_sorted_domains[$i]}
                current_line_length=$((current_line_length + ${#preferred_sorted_domains[$i]} + 2))
                echo -n "$domain_info  "
                if [ $current_line_length -ge $max_line_length ]; then
                    echo
                    current_line_length=0
                fi
            done
            [[ $current_line_length -ne 0 ]] && echo
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        fi
    fi
}
box_subscription_intro(){
    cdn_domains=() tls_domains=() selected_tls=() selected_cdn=()
    path_count=88
    tls_directory="/etc/tls"
    singbox_config_files
    if [ ! "$(find /etc/tls -maxdepth 1 -name '*.crt' -print -quit 2>/dev/null)" ]; then
        echo -e "\e[1;31m错误: $tls_directory 证书存放目录为空，操作中止。\e[0m"
        display_pause_info
        return 1
    fi
    if [ -d "$tls_directory" ] && \
        (find "$tls_directory" -maxdepth 1 -type f \( -name "*.crt" -o -name "*.key" \) | read); then
        all_domains=($(ls -1 "$tls_directory"/*.crt 2>/dev/null | xargs -n1 basename | sed 's/\.crt//'))
        sorted_domains=($(printf "%s\n" "${all_domains[@]}" | sort))
        max_length=0
            for domain in "${sorted_domains[@]}"; do
                length=${#domain}
                if [ "$length" -gt "$max_length" ]; then
                max_length="$length"
                fi
            done
            echo -e "\e[1;31m -- 当前已存在的域名TLS证书及有效期:\e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            i=0
            for domain in "${sorted_domains[@]}"; do
                i=$((i+1))
                local_ip=$(curl -s ifconfig.me)
                if dig +short "$domain" | grep -q "$local_ip"; then
                tls_domains+=("\e[1;32m$i) $domain - TLS\e[0m")
                selected_tls+=($domain)
                is_tls="TLS"
                color_code="\e[1;32m"
                else
                selected_cdn+=($domain)
                cdn_domains+=("\e[1;33m$i) $domain - CDN\e[0m")
                is_tls="CDN"
                color_code="\e[1;33m"
                fi
                if openssl x509 -in "$tls_directory/$domain.crt" -noout -dates &>/dev/null; then
                start_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
                end_date=$(openssl x509 -in "$tls_directory/$domain.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
                if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                    start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                    end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                    printf "${color_code}%2s) %-$((max_length + 5))s - %s   - 证书有效期: %s 至 %s\e[0m\n" "$i" "$domain" "$is_tls" "$start_date" "$end_date"
                else
                    echo "日期解析失败: $domain" >&2
                fi
                else
                echo "无法读取证书或证书无效: $domain" >&2
                fi
            done
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
    fi
    box_input_count=0
    while true; do
        read -e -p "请输入要生成的订阅目录，默认为 $box_subscription_dir (5秒超时自动确认): " -t 5 input_subscription_dir
        if [ -n "$input_subscription_dir" ]; then
            box_subscription_dir="$input_subscription_dir"
            break
        elif [ -z "$input_subscription_dir" ]; then
            box_input_count=$((box_input_count + 1))
        fi
        if [ "$box_input_count" -ge 3 ]; then
            random_string=$(openssl rand -hex 4)
            box_subscription_dir="$random_string"
            echo -e "\n - 生成随机字符串: $box_subscription_dir"
            break
        else
            echo -e "\n - \e[1;31m等待用户输入超时，已自动确认。\e[0m"
            break
        fi
    done
    box_html_dir="/usr/share/nginx/html/$box_type_dir/$box_subscription_dir"
    box_tag_paths=() box_tag_all_uuids=() box_tag_ports=()
    box_all_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag":\s*"\K[^"]+' | sed 's/_in//'))
    for i in "${!box_all_tags[@]}"; do
        box_current_tag="${box_all_tags[i]}"
        box_next_tag="${box_all_tags[i+1]}"
        [[ -z "$box_next_tag" ]] && box_next_tag="outbounds"
        box_content=$(sed -n "/\"$box_current_tag\"/,/\"$box_next_tag\"/ p" "$box_config_file")
        box_current_path=$(echo "$box_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
        [[ -z "$box_current_path" ]] && box_current_path=""
        box_tag_paths+=("$box_current_path")
        box_tag_ports+=($(echo "$box_content" | grep -oP '"listen_port":\s*\K[^,]+' | sed 's/ //g'))
        box_tag_all_uuids+=($(echo "$box_content" | grep -oP '"uuid":\s*"\K[^\"]+'))
    done
    unique_box_tag_all_uuids=($(echo "${box_tag_all_uuids[@]}" | tr ' ' '\n' | awk '!a[$0]++'))
    if [ "${#box_all_tags[@]}" -eq 0 ]; then
        echo -e "\e[1;31m - 错误:无法读到Sing-Box配置文件信息\e[0m"
        display_pause_info
        return 1
        else
        echo  -e "\e[1;33m - 正在收集用户信息，请稍后...\e[0m"
        mkdir -p "/usr/share/nginx/html/$box_type_dir"
        mkdir -p "$box_html_dir"
        mkdir -p "/etc/$box_type_dir"
        sleep 2
    fi
    delete_user=false
    directories=$(ls -l "$box_html_dir" | grep '^d' | awk '{print $9}')
    for compare_uuid in "${unique_box_tag_all_uuids[@]}"; do
        short_uuid="${compare_uuid:0:8}"
        matching_directory=""
        for directory in $directories; do
            if [[ "${directory}" == "$short_uuid" ]]; then
                matching_directory="$directory"
                break
            fi
        done
        if [ -n "$matching_directory" ]; then
            rm -rf "${box_html_dir:?}/$matching_directory"
            delete_user=true
        fi
    done
    if [ "$delete_user" = true ]; then
        echo -e "\e[1;31m - 清理Sing-Box冗余用户订阅...\e[0m"
        sleep 2
        else
        echo -e "\e[1;32m - 当前Sing-Box没有冗余用户订阅...\e[0m"
    fi
    box_domain_array=()
    if [ "${#sorted_domains[@]}" -gt 0 ]; then
        if [ "${#selected_tls[@]}" -gt 0 ]; then
            domain_tls=${selected_tls[0]}
        else
            domain_tls=${selected_cdn[0]}
        fi
        if [ "${#selected_cdn[@]}" -gt 0 ]; then
            domain_cdn=${selected_cdn[0]}
        else
            domain_cdn=${selected_tls[0]}
        fi
        echo  -e "\e[1;31m - 已自动选择: \e[0m\e[1;32mTLS域名 $domain_tls\e[0m  -  \e[1;33mCDN域名 $domain_cdn\e[0m"
        prefix="${domain_tls%%.*}"
        suffix="${domain_tls#*.}"
        numbers=$(echo "$prefix" | tr -cd '0-9')
        letters=$(echo "$prefix" | tr -cd 'A-Za-z')
        no_nomber=false
        if [ -z "$numbers" ]; then
            echo -e " - \e[1;31m当前TLS域名前缀不包含数字。\e[0m"
            domain_array=($domain_tls)
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            echo -e " - \e[1;32m将为 ${domain_array[@]} 生成相关配置信息。\e[0m"
            for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            no_nomber=true
        fi
    fi
    if [ "$no_nomber" = false ]; then
        length=${#numbers}
        letters_zero=$(printf '0%.0s' $(seq 1 $length))
    fi
    if [ "$no_nomber" = false ]; then
        timeout_flag=0
        if [[ $numbers =~ ^[0-9]+$ ]]; then
            echo -en " - 检测到前缀\e[1;31m ${length}\e[0m 位数字, 初始序号为 \e[1;31m${letters_zero}\e[0m，请输入域名开始的序号？ (按回车默认, 5秒超时): "
            read -r -p "" -t 5 start_number || timeout_flag=1
            start_number=${start_number:-$letters_zero}
            if [ "$timeout_flag" -eq 1 ]; then
                start_number=$letters_zero
                echo -e "\n - \e[1;31m等待用户输入超时，已自动确认。\e[0m"
            fi
        fi
    fi
    if [ -n "$start_number" ]; then
        length=${#start_number}
        echo -en " - 有多少台机子使用共同前缀(\e[1;32m$letters\e[0m)？ (默认为 10台, 5秒超时): "
        read -t 5 -p  "" domain_count|| timeout_flag=1
        [ "$timeout_flag" -eq 1 ] && echo
        domain_count=${domain_count:-10}  
    fi
    if [ -n "$domain_count" ]; then
        domain_countb=$((start_number + domain_count))
        for ((i = start_number; i < domain_countb; i++)); do
            formatted_number=$(printf "%0${length}d" $i)
            new_domain="${letters}${formatted_number}.${suffix}"
            domain_array+=("$new_domain")
            box_domain_array+=("$new_domain")
        done
        default_domain=("${box_domain_array[@]}")
    fi

    if [ ${#default_domain[@]} -lt 1 ]; then
        if [ -z "${box_domain_array[*]}" ]; then
            echo -e "\e[93m - 请输入域名，每行一个，以回车或空行结束输入。\e[0m"
            IFS=$'\n' read -r -a box_domain_array
            if [ ${#box_domain_array[@]} -gt 0 ]; then
                while IFS= read -r line && [ -n "$line" ]; do
                    IFS=$' \t,' read -ra line_array <<< "$line"
                    for domain_input in "${line_array[@]}"; do
                        box_domain_array+=("$domain_input")
                    done
                done
                box_domain_array=($(echo "${box_domain_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
            else
                echo -e "\e[1;31m - 域名订阅清单为空\e[0m"
                for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
            fi
            default_domain=("${box_domain_array[@]}")
        fi
        else
        box_domain_array=("${default_domain[@]}")
    fi
    if [ ${#box_domain_array[@]} -gt 0 ]; then
        max_line_length=80
        echo -e "\e[1;32m - 当前要生成的域名订阅清单如下: \e[0m"
        current_line_length=0
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        for ((i=0; i<${#box_domain_array[@]}; i++)); do
            current_line_length=$((current_line_length + ${#box_domain_array[$i]} + 2))
            echo -n "${box_domain_array[$i]}  "
            if [ $current_line_length -ge $max_line_length ]; then
                echo
                current_line_length=0
            fi
        done
        [[ $current_line_length -ne 0 ]] && echo
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
    fi
}
sing_box_neko_auto(){
    clear
    box_subscription_dir="neko"
    box_type_dir="sing-box"
    box_subscription_intro
    if [ ${#box_domain_array[@]} -gt 0 ]; then
        nekobox_trojan_ws_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":listen_port,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"ws","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_vmess_ws_template='{"_v":0,"addr":"predomain.com","aid":0,"id":"full_uuid","name":"tagname","port":listen_port,"sec":"auto","stream":{"ed_len":0,"h_type":"none","host":"example.com","insecure":false,"mux_s":0,"net":"ws","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_shadowsocks_template='{"_v":0,"addr":"example.com","method":"2022-blake3-aes-128-gcm","name":"tagname","pass":"Password:base64_uuid","port":listen_port,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"tcp"},"uot":0}'
        nekobox_vless_ws_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":listen_port,"stream":{"alpn":"h2,h2","ed_len":0,"host":"example.com","insecure":false,"mux_s":0,"net":"ws","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_tuic_tcp_template='{"_v":0,"addr":"example.com","allowInsecure":false,"alpn":"h3","congestionControl":"cubic","disableSni":false,"forceExternal":false,"heartbeat":"10s","name":"tagname","password":"base64_uuid","port":listen_port,"sni":"example.com","uos":false,"uuid":"full_uuid","zeroRttHandshake":false}'
        nekobox_naive_tcp_template='{"_v":0,"addr":"example.com","disable_log":false,"insecure_concurrency":0,"name":"tagname","password":"full_uuid","port":listen_port,"protocol":"quic","username":"short_uuid"}'
        nekobox_hysteria2_tcp_template='{"_v":0,"addr":"example.com","allowInsecure":true,"connectionReceiveWindow":0,"disableMtuDiscovery":false,"disableSni":false,"downloadMbps":0,"forceExternal":false,"hopInterval":10,"name":"tagname","obfsPassword":"obfs_pw","password":"full_uuid","port":listen_port,"sni":"example.com","streamReceiveWindow":0,"uploadMbps":0}'
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_tag_sub.txt
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        for box_uuid in "${unique_box_tag_all_uuids[@]}"; do
            box_short_uuid="${box_uuid:0:8}"
            box_uuid_base64=$(echo -n "$box_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            box_uuid_base64+="=="
            box_all_user_name=()
            mkdir -p "$box_html_dir/$box_short_uuid"
            for i in "${!box_all_tags[@]}"; do
                k=$i
                is_tag=$(echo "${box_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                box_current_tag=${box_all_tags[$i]} box_next_tag=${box_all_tags[$((i+1))]}
                [ -z "$box_next_tag" ] && box_next_tag="outbounds"
                box_content=$(sed -n "/\"$box_current_tag\"/,/\"$box_next_tag\"/ p" "$box_config_file")
                box_tag_path=$(echo "$box_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
                box_tag_domain=$(echo "$box_content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
                box_tag_uuids=($(echo "$box_content" | grep -oP '"uuid":\s*"\K[^\"]+'))
                box_tag_password=($(echo "$box_content" | grep -oP '"password":\s*"\K[^\"]+'))
                box_user_name=()
                if [ "$box_current_tag" == "shadowsocks" ] ; then
                    box_tag_domain=$box_tag_domainb
                fi
                box_tag_domainb=$box_tag_domain
                if [ "$box_current_tag" == "hysteria2" ] || [ "$box_current_tag" == "shadowsocks" ]; then
                    box_password_temp=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
                else
                    box_password_temp=""
                fi
                box_count_id=false
                for is_uuid in "${box_tag_uuids[@]}"; do
                    if [ "$box_uuid" == "$is_uuid" ] ; then
                        box_count_id=true
                        break
                    fi
                done
                for is_base64 in "${box_tag_password[@]}"; do
                    if [ "$box_uuid" == "$is_base64" ] || [ "$box_uuid_base64" == "$is_base64" ]; then
                        box_count_id=true
                        break
                    fi
                done
                if [ "$box_count_id" = true ]; then
                    mkdir -p "$box_html_dir/$box_short_uuid/$is_tag"
                    for ((x=0; x<${#box_domain_array[@]}; x++)); do
                        box_domain=${box_domain_array[x]}
                        country=${country_array[x]}
                        current_template=""
                        prefix="${box_domain%%.*}"
                        case $box_current_tag in
                            "trojan")
                                current_template=$(echo "$nekobox_trojan_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "vmess")
                                current_template=$(echo "$nekobox_vmess_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "shadowsocks")
                                current_template=$(echo "$nekobox_shadowsocks_template" | sed -e "s#Password#$box_tag_password#"  -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#base64_uuid#$box_uuid_base64#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                current_template="nekoray://shadowsocks#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "vless")
                                current_template=$(echo "$nekobox_vless_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "tuic")
                                current_template=$(echo "$nekobox_tuic_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#base64_uuid#$box_uuid_base64#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#example.com#$box_domain#g" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                current_template="nekoray://tuic#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "naive")
                                current_template=$(echo "$nekobox_naive_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#short_uuid#$box_short_uuid#" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                current_template="nekoray://naive#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            "hysteria2")
                                current_template=$(echo "$nekobox_hysteria2_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#obfs_pw#$box_tag_password#g" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                current_template="nekoray://hysteria2#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            *)
                                current_template=""
                                ;;
                        esac
                        box_user_name+=("$current_template")
                        box_all_user_name+=("$current_template")
                    done
                fi
                printf "%s\n" "${box_user_name[@]}" > "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded"
                grep -v '^$' "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded" >  "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid"
                rm -rf "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded"
                echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$is_tag/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_tags_sub.txt
            done
                printf "%s\n" "${box_all_user_name[@]}" > "$box_html_dir/$box_short_uuid/$box_uuid-encoded"
                grep -v '^$' "$box_html_dir/$box_short_uuid/$box_uuid-encoded" >  "$box_html_dir/$box_short_uuid/$box_uuid"
                rm -rf $box_html_dir/$box_short_uuid/$box_uuid-encoded
                echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$box_html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$box_tag_domain/$box_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$box_tag_domain/$box_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
sing_box_quanx_auto(){
    clear
    box_subscription_dir="quanx"
    box_type_dir="sing-box"
    box_subscription_intro
    if [ ${#box_domain_array[@]} -gt 0 ]; then
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        quanx_sing_box_vmess_wss_template="vmess=predomain.com:3610, method=none, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=yourpath, tls-verification=false, fast-open=false, udp-relay=false, aead=true, tag=tagname"
        quanx_sing_box_trojan_wss_template="trojan=predomain.com:listen_port, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=yourpath, tls-verification=false, fast-open=false, udp-relay=false, tag=tagname"
        for box_uuid in "${unique_box_tag_all_uuids[@]}"; do
            box_short_uuid="${box_uuid:0:8}"
            box_uuid_base64=$(echo -n "$box_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            box_uuid_base64+="=="
            mkdir -p "$box_html_dir/$box_short_uuid"
            box_user_name=()
            for ((x=0; x<${#box_domain_array[@]}; x++)); do
                box_domain=${box_domain_array[x]}
                country=${country_array[x]}
                for i in "${!box_all_tags[@]}"; do
                    k=$i
                    is_tag=$(echo "${box_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                    if [[ "$is_tag" == *"trojan"* || "$is_tag" == *"vmess"* ]]; then
                    box_current_tag=${box_all_tags[$i]} box_next_tag=${box_all_tags[$((i+1))]}
                    [ -z "$box_next_tag" ] && box_next_tag="outbounds"
                    box_content=$(sed -n "/\"$box_current_tag\"/,/\"$box_next_tag\"/ p" "$box_config_file")
                    box_tag_path=$(echo "$box_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
                    box_tag_domain=$(echo "$box_content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
                    box_tag_uuids=($(echo "$box_content" | grep -oP '"uuid":\s*"\K[^\"]+'))
                    box_tag_password=($(echo "$box_content" | grep -oP '"password":\s*"\K[^\"]+'))
                    if [ "$box_current_tag" == "shadowsocks" ] ; then
                        box_tag_domain=$box_tag_domainb
                    fi
                    box_tag_domainb=$box_tag_domain
                    if [ "$box_current_tag" == "hysteria2" ] || [ "$box_current_tag" == "shadowsocks" ]; then
                        box_password_temp=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
                    else
                        box_password_temp=""
                    fi
                    box_count_id=false
                    for is_uuid in "${box_tag_uuids[@]}"; do
                        if [ "$box_uuid" == "$is_uuid" ] ; then
                            box_count_id=true
                            break
                        fi
                    done
                    if [ "$box_count_id" = false ]; then
                        for is_base64 in "${box_tag_password[@]}"; do
                            if [ "$box_uuid" == "$is_base64" ] || [ "$box_uuid_base64" == "$is_base64" ]; then
                                box_count_id=true
                                break
                            fi
                        done
                    fi
                    prefix="${box_domain%%.*}"
                    suffix="${box_domain#*.}"
                    if [ "$box_count_id" = true ]; then
                        if [[ "$is_tag" == *"trojan"* || "$is_tag" == *"vmess"* || "$is_tag" == *"shadows"* ]]; then
                            current_template=""
                            case $box_current_tag in
                                "trojan")
                                    current_template=$(echo "$quanx_sing_box_trojan_wss_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${box_current_tag^}_WS_$country#")
                                    ;;
                                "vmess")
                                    current_template=$(echo "$quanx_sing_box_vmess_wss_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${box_current_tag^}_WS_$country#")
                                    ;;
                                *)
                                    current_template=""
                                    ;;
                            esac
                            box_user_name+=("$current_template")
                        fi
                    fi
                    fi
                done
            done
                printf "%s\n" "${box_user_name[@]}" >> "$box_html_dir/$box_short_uuid/$box_uuid"
                echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m正在加密处理，请稍后...\e[0m"
        i=0
        for bas64_code in "${box_uuid[@]}"; do
            short_uuid="${bas64_code:0:8}" 
            mv "$box_html_dir/$short_uuid/${box_uuid[i]}" "$box_html_dir/$short_uuid/${box_uuid[i]}-encoded"
            grep -v '^$' "$box_html_dir/$short_uuid/${box_uuid[i]}-encoded" >  "$box_html_dir/$short_uuid/${box_uuid[i]}"
            rm -rf "$box_html_dir/$short_uuid/${box_uuid[i]}-encoded"
            ((i++))
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$box_html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt\e[0m"
        echo -e "\e[0;33m 订阅链接格式为: \e[0m https://${selected_cdn[0]}/$box_type_dir/quanx/UUID前8位/完整的UUID"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
sing_box_shadowrocket_auto(){
    clear
    box_subscription_dir="rocket"
    box_type_dir="sing-box"
    box_subscription_intro
    if [ ${#box_domain_array[@]} -gt 0 ]; then
        rocket_hysteria2_tcp_template='hysteria2://full_uuid@example.com:listen_port?peer=example.com&alpn=h3&obfs=salamander&obfs-password=obfs_pw#tagname'
        rocket_shadowsocks_template='2022-blake3-aes-128-gcm:Password:base64_uuid'
        rocket_vmess_ws_template='auto:full_uuid@predomain.com:listen_port'
        rocket_trojan_ws_template='trojan://full_uuid@predomain.com:listen_port?peer=example.com&plugin=obfs-local;obfs=websocket;obfs-host=example.com;obfs-uri=yourpath#tagname'
        rocket_vless_ws_template='auto:full_uuid@predomain.com:listen_port'
        rocket_tuic_tcp_template='tuic://full_uuid:base64_uuid@example.com:listen_port?sni=example.com&congestion_control=cubic&udp_relay_mode=native&alpn=h3#tagname'
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_tag_sub.txt
        for box_uuid in "${unique_box_tag_all_uuids[@]}"; do
            box_short_uuid="${box_uuid:0:8}"
            box_uuid_base64=$(echo -n "$box_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            box_uuid_base64+="=="
            box_all_user_name=()
            mkdir -p "$box_html_dir/$box_short_uuid"
            for i in "${!box_all_tags[@]}"; do
                k=$i
                is_tag=$(echo "${box_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                box_current_tag=${box_all_tags[$i]} box_next_tag=${box_all_tags[$((i+1))]}
                [ -z "$box_next_tag" ] && box_next_tag="outbounds"
                box_content=$(sed -n "/\"$box_current_tag\"/,/\"$box_next_tag\"/ p" "$box_config_file")
                box_tag_path=$(echo "$box_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
                box_tag_domain=$(echo "$box_content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
                box_tag_uuids=($(echo "$box_content" | grep -oP '"uuid":\s*"\K[^\"]+'))
                box_tag_password=($(echo "$box_content" | grep -oP '"password":\s*"\K[^\"]+'))
                box_user_name=()
                if [ "$box_current_tag" == "shadowsocks" ] ; then
                    box_tag_domain=$box_tag_domainb
                fi
                box_tag_domainb=$box_tag_domain
                if [ "$box_current_tag" == "hysteria2" ] || [ "$box_current_tag" == "shadowsocks" ]; then
                    box_password_temp=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
                else
                    box_password_temp=""
                fi
                box_count_id=false
                for is_uuid in "${box_tag_uuids[@]}"; do
                    if [ "$box_uuid" == "$is_uuid" ] ; then
                        box_count_id=true
                        break
                    fi
                done
                for is_base64 in "${box_tag_password[@]}"; do
                    if [ "$box_uuid" == "$is_base64" ] || [ "$box_uuid_base64" == "$is_base64" ]; then
                        box_count_id=true
                        break
                    fi
                done
                prefix="${box_domain%%.*}"
                suffix="${box_domain#*.}"
                if [ "$box_count_id" = true ]; then
                    mkdir -p "$box_html_dir/$box_short_uuid/$is_tag"
                    for ((x=0; x<${#box_domain_array[@]}; x++)); do
                        box_domain=${box_domain_array[x]}
                        country=${country_array[x]}
                        prefix="${box_domain%%.*}"
                        case $box_current_tag in
                            "trojan")
                                current_template=$(echo "$rocket_trojan_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                ;;
                            "vmess")
                                current_template=$(echo "$rocket_vmess_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')?remarks=${prefix^^}_${is_tag^}_WS_$country&obfsParam=%7B%22Host%22:%22$box_domain%22%7D&path=$box_tag_path&obfs=websocket&tls=1&peer=$box_domain&alpn=h2"
                                ;;
                            "shadowsocks")
                                current_template=$(echo "$rocket_shadowsocks_template" | sed -e "s#Password#$box_tag_password#"  -e "s#base64_uuid#$box_uuid_base64#")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$box_domain:${box_tag_ports[k]}?plugin=obfs-local;obfs=tls;obfs-host=$box_domain;obfs-uri=/#${prefix^^}_${is_tag^}_WS_$country"
                                ;;
                            "vless")
                                current_template=$(echo "$rocket_vless_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g")
                                current_template="vless://$(echo -n "$current_template" | base64 | tr -d '\n')?remarks=${prefix^^}_${is_tag^}_WS_$country&obfsParam=%7B%22Host%22:%22$box_domain%22%7D&path=$box_tag_path&obfs=websocket&tls=1&peer=$box_domain&alpn=h2"
                                ;;
                            "tuic")
                                current_template=$(echo "$rocket_tuic_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#base64_uuid#$box_uuid_base64#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#example.com#$box_domain#g" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                ;;
                            "hysteria2")
                                current_template=$(echo "$rocket_hysteria2_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#obfs_pw#$box_tag_password#g" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                ;;
                            *)
                                current_template=""
                                ;;
                        esac
                        box_user_name+=("$current_template")
                        box_all_user_name+=("$current_template")
                    done
                fi
                printf "%s\n" "${box_user_name[@]}" > "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid"
                grep -v '^$' "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid" >  "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded"
                reencoded_base64=$(base64 < "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded" | tr -d '\n')
                echo "$reencoded_base64" > "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid"
                rm -rf "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded"
                echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$is_tag/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_tags_sub.txt
            done
                printf "%s\n" "${box_all_user_name[@]}" > "$box_html_dir/$box_short_uuid/$box_uuid"
                grep -v '^$' "$box_html_dir/$box_short_uuid/$box_uuid" >  "$box_html_dir/$box_short_uuid/$box_uuid-encoded"
                reencoded_base64=$(base64  < "$box_html_dir/$box_short_uuid/$box_uuid-encoded" | tr -d '\n')
                echo "$reencoded_base64" > "$box_html_dir/$box_short_uuid/$box_uuid"
                rm -rf $box_html_dir/$box_short_uuid/$box_uuid-encoded
                echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$box_html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$box_tag_domain/$box_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$box_tag_domain/$box_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
sing_box_v2rayn_auto(){
    clear
    box_subscription_dir="v2rayn"
    box_type_dir="sing-box"
    box_subscription_intro
    if [ ${#box_domain_array[@]} -gt 0 ]; then
        box_trojan_ws_template="trojan://full_uuid@predomain.com:listen_port?security=tls&sni=example.com&type=ws&path=yourpath#tagname"
        box_vmess_ws_template='{"add":"predomain.com","aid":"0","host":"example.com","id":"full_uuid","net":"ws","path":"yourpath","port":"listen_port","ps":"tagname","scy":"auto","sni":"example.com","tls":"tls","type":"","v":"2","alpn":"h2"}'
        box_shadowsocks="2022-blake3-aes-128-gcm:Password:base64_uuid"
        box_vless_ws_template="vless://full_uuid@predomain.com:listen_port?security=tls&sni=example.com&alpn=h2&type=ws&path=yourpath&host=example.com&encryption=none&alpn=h2#tagname"
        box_tuic_tcp_template="tuic://full_uuid:base64_uuid@example.com:listen_port?congestion_control=cubic&alpn=h3&sni=example.com&udp_relay_mode=native#tagname"
        box_naive_tcp_template="naive+https://short_uuid:full_uuid@example.com:listen_port#tagname"
        box_hysteria2_tcp_template="hy2://full_uuid@example.com:listen_port?obfs=salamander&obfs-password=obfs_pw&mport=listen_port&insecure=1&sni=example.com#tagname"
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        rm -rf /etc/$box_type_dir/${box_subscription_dir}_box_tag_sub.txt
        for box_uuid in "${unique_box_tag_all_uuids[@]}"; do
            box_short_uuid="${box_uuid:0:8}"
            box_uuid_base64=$(echo -n "$box_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            box_uuid_base64+="=="
            box_all_user_name=()
            mkdir -p "$box_html_dir/$box_short_uuid"
            for i in "${!box_all_tags[@]}"; do
                k=$i
                is_tag=$(echo "${box_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                box_current_tag=${box_all_tags[$i]} box_next_tag=${box_all_tags[$((i+1))]}
                [ -z "$box_next_tag" ] && box_next_tag="outbounds"
                box_content=$(sed -n "/\"$box_current_tag\"/,/\"$box_next_tag\"/ p" "$box_config_file")
                box_tag_path=$(echo "$box_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1)
                box_tag_domain=$(echo "$box_content" | grep -oP '"server_name":\s*"\K[^\"]+' | head -n1)
                box_tag_uuids=($(echo "$box_content" | grep -oP '"uuid":\s*"\K[^\"]+'))
                box_tag_password=($(echo "$box_content" | grep -oP '"password":\s*"\K[^\"]+'))
                box_user_name=()
                if [ "$box_current_tag" == "shadowsocks" ] ; then
                    box_tag_domain=$box_tag_domainb
                fi
                box_tag_domainb=$box_tag_domain
                if [ "$box_current_tag" == "hysteria2" ] || [ "$box_current_tag" == "shadowsocks" ]; then
                    box_password_temp=$(echo "$content" | grep -oP '"password":\s*"\K[^\"]+' | head -n1)
                else
                    box_password_temp=""
                fi
                box_count_id=false
                for is_uuid in "${box_tag_uuids[@]}"; do
                    if [ "$box_uuid" == "$is_uuid" ] ; then
                        box_count_id=true
                        break
                    fi
                done
                for is_base64 in "${box_tag_password[@]}"; do
                    if [ "$box_uuid" == "$is_base64" ] || [ "$box_uuid_base64" == "$is_base64" ]; then
                        box_count_id=true
                        break
                    fi
                done
                prefix="${box_domain%%.*}"
                suffix="${box_domain#*.}"
                if [ "$box_count_id" = true ]; then
                    mkdir -p "$box_html_dir/$box_short_uuid/$is_tag"
                    for ((x=0; x<${#box_domain_array[@]}; x++)); do
                        box_domain=${box_domain_array[x]}
                        country=${country_array[x]}
                        current_template=""
                        prefix="${box_domain%%.*}"
                        case $box_current_tag in
                            "trojan")
                                current_template=$(echo "$box_trojan_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                ;;
                            "vmess")
                                current_template=$(echo "$box_vmess_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n' )"
                                ;;
                            "shadowsocks")
                                current_template=$(echo "$box_shadowsocks" | sed -e "s#Password#$box_tag_password#" -e "s#base64_uuid#$box_uuid_base64#")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$box_domain:${box_tag_ports[k]}#${prefix^^}_${is_tag^}_TCP_$country"
                                ;;
                            "vless")
                                current_template=$(echo "$box_vless_ws_template" | sed -e "s#full_uuid#$box_uuid#" -e "s/predomain.com/$box_domain/g" -e "s#example.com#$box_domain#g"  -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#yourpath#$box_tag_path#" -e "s#tagname#${prefix^^}_${is_tag^}_WS_$country#")
                                ;;
                            "tuic")
                                current_template=$(echo "$box_tuic_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#base64_uuid#$box_uuid_base64#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#example.com#$box_domain#g" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                ;;
                            "naive")
                                current_template=$(echo "$box_naive_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#short_uuid#$short_uuid#" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                ;;
                            "hysteria2")
                                current_template=$(echo "$box_hysteria2_tcp_template" | sed -e "s#full_uuid#$box_uuid#" -e "s#example.com#$box_domain#g" -e "s#listen_port#${box_tag_ports[k]}#g" -e "s#obfs_pw#$box_tag_password#g" -e "s#tagname#${prefix^^}_${is_tag^}_TCP_$country#")
                                ;;
                            *)
                                current_template=""
                                ;;
                        esac
                        box_user_name+=("$current_template")
                        box_all_user_name+=("$current_template")
                    done
                fi
                printf "%s\n" "${box_user_name[@]}" > "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid"
                grep -v '^$' "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid" >  "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded"
                reencoded_base64=$(base64 < "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded" | tr -d '\n')
                echo "$reencoded_base64" > "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid"
                rm -rf "$box_html_dir/$box_short_uuid/$is_tag/$box_uuid-encoded"
                echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$is_tag/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_tags_sub.txt
            done
            printf "%s\n" "${box_all_user_name[@]}" > "$box_html_dir/$box_short_uuid/$box_uuid"
            grep -v '^$' "$box_html_dir/$box_short_uuid/$box_uuid" >  "$box_html_dir/$box_short_uuid/$box_uuid-encoded"
            reencoded_base64=$(base64 < "$box_html_dir/$box_short_uuid/$box_uuid-encoded" | tr -d '\n')
            echo "$reencoded_base64" > "$box_html_dir/$box_short_uuid/$box_uuid"
            rm -rf $box_html_dir/$box_short_uuid/$box_uuid-encoded
            echo "https://$box_tag_domain/$box_type_dir/$box_subscription_dir/$box_short_uuid/$box_uuid" | tee -a /etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$box_html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_box_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$box_tag_domain/$box_type_dir/$box_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$box_type_dir/${box_subscription_dir}_box_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$box_tag_domain/$box_type_dir/$box_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
xRay_neko_auto(){
    clear
    xray_type_dir="xray"
    xray_subscription_dir="neko"
    xray_subscription_intro
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        nekobox_vless_ws_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"ws","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_trojan_ws_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"alpn":"http/1.1","ed_len":0,"insecure":false,"mux_s":0,"net":"tcp","sec":"tls","sni":"example.com"}}'
        nekobox_trojan_grpc_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_vless_xtls_template='{"_v":0,"addr":"example.com","flow":"xtls-rprx-vision","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"tcp","sec":"tls","sni":"example.com","utls":"chrome"}}'
        nekobox_vless_grpc_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_vmess_grpc_template='{"_v":0,"addr":"predomain.com","aid":0,"id":"full_uuid","name":"tagname","port":443,"sec":"none","stream":{"ed_len":0,"h_type":"gun","host":"example.com","insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekobox_vmess_ws_template='{"_v":0,"addr":"predomain.com","aid":0,"id":"full_uuid","name":"tagname","port":443,"sec":"none","stream":{"ed_len":0,"h_type":"none","host":"example.com","insecure":false,"mux_s":0,"net":"ws","path":"yourpath","sec":"tls","sni":"example.com"}}'
        for chosen_uuid in "${unique_xray_tag_all_uuids[@]}"; do
            short_uuid="${chosen_uuid:0:8}"
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            xray_user_all_name=()
            mkdir -p "$html_dir/$short_uuid"
            for i in "${!xray_all_tags[@]}"; do
                current_tag="${xray_all_tags[i]}"
                next_tag="${xray_all_tags[i+1]}"
                [[ -z "$next_tag" ]] && next_tag="outbounds"
                is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                if [[ ${current_tag,,} == *"vless-xtls"* || ${current_tag,,} == *"vless-ws"* || ${current_tag,,} == *"vmess-ws"* || ${current_tag,,} == *"warp"*  || ${current_tag,,} == *"trojan-ws"* || ${current_tag,,} == *"vless-grpc"* || ${current_tag,,} == *"vmess-grpc"* || ${current_tag,,} == *"trojan-grpc"* ]]; then
                    xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                    xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                    xray_tag_uuid=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
                    xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
                    xray_count_id=false
                    if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
                        xray_tag_path=$(echo "$xray_content" |grep -oP '"serviceName":\s*"\K[^\"]+')
                    fi
                    if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
                        xray_tag_path=""
                    fi
                    for is_uuid in "${xray_tag_uuid[@]}"; do
                        if [ "$chosen_uuid" == "$is_uuid" ]; then
                            xray_count_id=true
                            break
                        fi
                    done
                    if [ "$xray_count_id" = false ]; then
                        if [[ "$is_tag" == *"trojan"* ]] ; then
                            for is_uuid in "${xray_tag_password[@]}"; do
                                if [ "$chosen_uuid" == "$is_uuid" ] ; then
                                    xray_count_id=true
                                    break
                                fi
                            done
                        fi
                    fi
                    if [ "$xray_count_id" = false ]; then
                        for is_password in "${xray_tag_password[@]}"; do
                            if [ "$chosen_base64" == "$is_password" ]; then
                                xray_count_id=true
                                break
                            fi
                        done
                    fi
                    if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* ]]; then
                        xray_suffix="${selected_cdn#*.}"
                        else
                        xray_suffix="${selected_tls#*.}"
                    fi
                    for ((i = 0; i < ${#xray_domain_array[@]}; i++)); do
                        original_domain=${xray_domain_array[$i]}
                        dot_position=$(expr index "$original_domain" ".")
                        xray_prefix=${original_domain:0:dot_position-1}
                        xray_new_domain="$xray_prefix.$xray_suffix"
                        xray_domain_array[$i]=$xray_new_domain
                    done
                    if [ "$xray_count_id" = true ]; then
                        mkdir -p "$html_dir/$short_uuid/$is_tag"
                        xray_user_name=()
                        for ((x=0; x<${#xray_domain_array[@]}; x++)); do
                            selected_domain=${xray_domain_array[x]}
                            country=${country_array[x]}
                            prefix_a="${selected_domain%%.*}"
                            current_template=""
                            if [ ${#preferred_sorted_domains[@]} -gt 0 ]; then
                                length=${#preferred_sorted_domains[@]}
                                random_index=$((RANDOM % length))
                                pre_domain=${preferred_sorted_domains[$random_index]}
                                else
                                pre_domain=${xray_domain_array[x]}
                            fi
                            case ${current_tag,,} in
                                *"vless-xtls"*)
                                    current_template=$(echo "$nekobox_vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/"${prefix_a^^}"_${current_tag}_$country/")
                                    current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"trojan-ws"*)
                                    current_template=$(echo "$nekobox_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"trojan-warp"*)
                                    current_template=$(echo "$nekobox_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"trojan-grpc"*)
                                    current_template=$(echo "$nekobox_trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"vless-ws"*)
                                    current_template=$(echo "$nekobox_vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"vless-warp"*)
                                    current_template=$(echo "$nekobox_vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"vless-grpc"*)
                                    current_template=$(echo "$nekobox_vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$xray_tag_path#" -e "s#tagname#${prefix_a^^}_${current_tag}_$country#")
                                    current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"vmess-ws"*)
                                    current_template=$(echo "$nekobox_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"vmess-warp"*)
                                    current_template=$(echo "$nekobox_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *"vmess-grpc"*)
                                    current_template=$(echo "$nekobox_vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                                    ;;
                                *)
                                    current_template=""
                                    ;;
                            esac
                            xray_user_name+=("$current_template")
                            xray_user_all_name+=("$current_template")
                        done
                        printf "%s\n" "${xray_user_name[@]}"  > "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                        grep -v '^$' "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded" >  "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                        rm -rf "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                        echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$is_tag/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt
                    fi
                fi
            done
            printf "%s\n" "${xray_user_all_name[@]}" > "$html_dir/$short_uuid/$chosen_uuid-encoded"
            grep -v '^$' "$html_dir/$short_uuid/$chosen_uuid-encoded" >  "$html_dir/$short_uuid/$chosen_uuid"
            rm -rf "$html_dir/$short_uuid/$chosen_uuid-encoded"
            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
xRay_clash_auto(){
    clear
    path_count=88
    xray_type_dir="xray"
    xray_subscription_dir="clash"
    xray_subscription_intro
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        input_file="/etc/$xray_type_dir/clash_file_temp.yaml"
        rm -rf "$input_file" clash_file_temp.yaml
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/clash_file_temp.yaml > /dev/null 2>&1
        sleep 1
        mv clash_file_temp.yaml "$input_file" -f
        clash_xray_trojan_grcp_template='  - {"name":"tagname","type":"trojan","server":"predomain.com","port":443,"udp":true,"password":"full_uuid","sni":"example.com","skip-cert-verify":true,"network":"grpc","grpc-opts":{"grpc-service-name":"yourpath"},"alpn":["h2"]}'
        clash_xray_vmess_ws_template='  - {"name":"tagname","server":"predomain.com","port":443,"type":"vmess","uuid":"full_uuid","alterId":0,"cipher":"auto","tls":true,"skip-cert-verify":false,"servername":"example.com","network":"ws","ws-opts":{"path":"yourpath","headers":{"Host":"example.com"}},"udp":true}'
        clash_xray_vless_ws_template='  - {"name":"tagname","server":"predomain.com","port":443,"type":"vless","uuid":"full_uuid","tls":true,"skip-cert-verify":false,"servername":"example.com","network":"ws","ws-opts":{"path":"yourpath","headers":{"Host":"example.com"}},"udp":true}'
        for chosen_uuid in "${unique_xray_tag_all_uuids[@]}"; do
            short_uuid="${chosen_uuid:0:8}"
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            mkdir -p "$html_dir/$short_uuid"
            xray_clash_all_tag=() xray_clash_all_name=()
            for i in "${!xray_all_tags[@]}"; do
                current_tag="${xray_all_tags[i]}"
                next_tag="${xray_all_tags[i+1]}"
                [[ -z "$next_tag" ]] && next_tag="outbounds"
                is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                if [[ "$is_tag" == *"trojan-grpc"* || "$is_tag" == *"vmess-ws"* || "$is_tag" == *"vmess-warp"* || "$is_tag" == *"vless-ws"* || "$is_tag" == *"vless-warp"* ]]; then
                    xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                    xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                    xray_tag_uuid=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
                    xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
                    xray_count_id=false
                    if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
                        xray_tag_path=$(echo "$xray_content" |grep -oP '"serviceName":\s*"\K[^\"]+')
                    fi
                    if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
                        xray_tag_path=""
                    fi
                    for is_uuid in "${xray_tag_uuid[@]}"; do
                        if [ "$chosen_uuid" == "$is_uuid" ]; then
                            xray_count_id=true
                            break
                        fi
                    done
                    if [ "$xray_count_id" = false ]; then
                        if [[ "$is_tag" == *"trojan"* ]] ; then
                            for is_uuid in "${xray_tag_password[@]}"; do
                                if [ "$chosen_uuid" == "$is_uuid" ] ; then
                                    xray_count_id=true
                                    break
                                fi
                            done
                        fi
                    fi
                    if [ "$xray_count_id" = false ]; then
                        for is_password in "${xray_tag_password[@]}"; do
                            if [ "$chosen_base64" == "$is_password" ]; then
                                xray_count_id=true
                                break
                            fi
                        done
                    fi
                    if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* || ${current_tag,,} == *"-warp"* ]]; then
                        xray_suffix="${selected_cdn#*.}"
                        else
                        xray_suffix="${selected_tls#*.}"
                    fi
                    for ((i = 0; i < ${#xray_domain_array[@]}; i++)); do
                        original_domain=${xray_domain_array[$i]}
                        dot_position=$(expr index "$original_domain" ".")
                        xray_prefix=${original_domain:0:dot_position-1}
                        xray_new_domain="$xray_prefix.$xray_suffix"
                        xray_domain_array[$i]=$xray_new_domain
                    done
                    if [ "$xray_count_id" = true ]; then
                        mkdir -p "$html_dir/$short_uuid/$is_tag"
                        xray_user_name=() xray_user_tags=()
                        for ((x=0; x<${#xray_domain_array[@]}; x++)); do
                            selected_domain=${xray_domain_array[x]}
                            country=${country_array[x]}
                            prefix_a="${selected_domain%%.*}"
                            current_template=""
                            if [ ${#preferred_sorted_domains[@]} -gt 0 ]; then
                                length=${#preferred_sorted_domains[@]}
                                random_index=$((RANDOM % length))
                                pre_domain=${preferred_sorted_domains[$random_index]}
                                else
                                pre_domain=${xray_domain_array[x]}
                            fi
                            case ${current_tag,,} in
                                *"trojan-grpc"*)
                                    current_template=$(echo "$clash_xray_trojan_grcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vmess-ws"*)
                                    current_template=$(echo "$clash_xray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vmess-warp"*)
                                    current_template=$(echo "$clash_xray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vless-ws"*)
                                    current_template=$(echo "$clash_xray_vless_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vless-warp"*)
                                    current_template=$(echo "$clash_xray_vless_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *)
                                    current_template=""
                                ;;
                            esac
                            xray_user_name+=("$current_template")
                            xray_user_tags+=(${prefix_a^^}_${current_tag}_$country)
                            xray_clash_all_name+=("$current_template")
                            xray_clash_all_tag+=(${prefix_a^^}_${current_tag}_$country)
                        done
                            output_file="$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                            mapfile -t lines < "$input_file"
                            IFS=,
                            clash_proxy="- { name: PROXY, type: select, proxies: [ Auto Select, Load Balance, ${xray_user_tags[*]} ] }"
                            clash_auto="- { name: Auto Select, type: url-test, proxies: [ ${xray_user_tags[*]} ] , url: 'http://www.gstatic.com/generate_204', interval: 86400 }"
                            clash_balance="- { name: Load Balance, type: fallback, proxies: [ ${xray_user_tags[*]} ] , url: 'http://www.gstatic.com/generate_204', interval: 7200 }"
                            IFS=$' \t\n'
                            for i in "${!lines[@]}"; do
                                if [[ ${lines[i]} == "proxies:" ]]; then
                                    lines=("${lines[@]:0:i+1}" "${xray_user_name[@]}" "${lines[@]:i+1}")
                                break
                            fi
                            done
                            for i in "${!lines[@]}"; do
                            if [[ ${lines[i]} == "proxy-groups:" ]]; then
                                lines=("${lines[@]:0:i+1}" "$clash_balance" "${lines[@]:i+1}")
                                lines=("${lines[@]:0:i+1}" "$clash_auto" "${lines[@]:i+1}")
                                lines=("${lines[@]:0:i+1}" "$clash_proxy" "${lines[@]:i+1}")
                                break
                            fi
                            done
                            printf "%s\n" "${lines[@]}" > "$output_file"
                            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$is_tag/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt
                    fi
                fi
            done
            output_file="$html_dir/$short_uuid/$chosen_uuid"
            mapfile -t lines < "$input_file"
            IFS=,
            clash_proxy="- { name: PROXY, type: select, proxies: [ Auto Select, Load Balance, ${xray_clash_all_tag[*]} ] }"
            clash_auto="- { name: Auto Select, type: url-test, proxies: [ ${xray_clash_all_tag[*]} ] , url: 'http://www.gstatic.com/generate_204', interval: 86400 }"
            clash_balance="- { name: Load Balance, type: fallback, proxies: [ ${xray_clash_all_tag[*]} ] , url: 'http://www.gstatic.com/generate_204', interval: 7200 }"
            IFS=$' \t\n'
            for i in "${!lines[@]}"; do
                if [[ ${lines[i]} == "proxies:" ]]; then
                    lines=("${lines[@]:0:i+1}" "${xray_clash_all_name[@]}" "${lines[@]:i+1}")
                break
            fi
            done
            for i in "${!lines[@]}"; do
            if [[ ${lines[i]} == "proxy-groups:" ]]; then
                lines=("${lines[@]:0:i+1}" "$clash_balance" "${lines[@]:i+1}")
                lines=("${lines[@]:0:i+1}" "$clash_auto" "${lines[@]:i+1}")
                lines=("${lines[@]:0:i+1}" "$clash_proxy" "${lines[@]:i+1}")
                break
            fi
            done
            printf "%s\n" "${lines[@]}" > "$output_file"
            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        rm -f "$input_file"
        display_pause_info
    fi
}
xRay_quanx_auto(){
    clear
    xray_type_dir="xray"
    xray_subscription_dir="quanx"
    xray_subscription_intro
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        quanx_xray_vmess_wss_template="vmess=predomain.com:443, method=none, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=/yourpath, tls-verification=false, fast-open=false, udp-relay=false, aead=true, tag=tagname"
        quanx_xray_trojan_wss_template="trojan=predomain.com:443, password=full_uuid, obfs=wss, obfs-host=example.com, obfs-uri=/yourpath, tls-verification=false, fast-open=false, udp-relay=false, tag=tagname"
        quanx_xray_shadowsocks_wss_template="shadowsocks=predomain.com:443, method=chacha20-ietf-poly1305, password=passwordbase64, obfs=wss, obfs-uri=/yourpath, obfs-host=example.com, fast-open=false, udp-relay=false, tag=tagname"
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        for chosen_uuid in "${unique_xray_tag_all_uuids[@]}"; do
            short_uuid="${chosen_uuid:0:8}"
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            mkdir -p "$html_dir/$short_uuid"
            xray_all_name=()
            for i in "${!xray_all_tags[@]}"; do
                current_tag="${xray_all_tags[i]}"
                next_tag="${xray_all_tags[i+1]}"
                xray_user_name=()
                [[ -z "$next_tag" ]] && next_tag="outbounds"
                is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                if [[ "$is_tag" == *"trojan"* || "$is_tag" == *"vmess"* || "$is_tag" == *"shadows"* ]]; then
                    xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                    xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                    xray_tag_uuid=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
                    xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
                    xray_count_id=false
                    if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
                        xray_tag_path=$(echo "$xray_content" |grep -oP '"serviceName":\s*"\K[^\"]+')
                    fi
                    if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
                        xray_tag_path=""
                    fi
                    for is_uuid in "${xray_tag_uuid[@]}"; do
                        if [ "$chosen_uuid" == "$is_uuid" ]; then
                            xray_count_id=true
                            break
                        fi
                    done
                    if [ "$xray_count_id" = false ]; then
                        if [[ "$is_tag" == *"trojan"* ]] ; then
                            for is_uuid in "${xray_tag_password[@]}"; do
                                if [ "$chosen_uuid" == "$is_uuid" ] ; then
                                    xray_count_id=true
                                    break
                                fi
                            done
                        fi
                    fi
                    if [ "$xray_count_id" = false ]; then
                        for is_password in "${xray_tag_password[@]}"; do
                            if [ "$chosen_base64" == "$is_password" ]; then
                                xray_count_id=true
                                break
                            fi
                        done
                    fi
                    if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* || ${current_tag,,} == *"-warp"* ]]; then
                        xray_suffix="${selected_cdn#*.}"
                        else
                        xray_suffix="${selected_tls#*.}"
                    fi

                    if [ "$xray_count_id" = true ]; then
                        mkdir -p "$html_dir/$short_uuid/$is_tag"
                        current_template=""
                        for ((x=0; x<${#xray_domain_array[@]}; x++)); do
                            selected_domain=${xray_domain_array[x]}
                            selected_prefix="${selected_domain%%.*}"
                            xray_new_domain="$selected_prefix.$xray_suffix"
                            selected_domain=$xray_new_domain
                            prefix_a="${selected_domain%%.*}"
                            country=${country_array[x]}
                            if [ ${#preferred_sorted_domains[@]} -gt 0 ]; then
                                length=${#preferred_sorted_domains[@]}
                                random_index=$((RANDOM % length))
                                pre_domain=${preferred_sorted_domains[$random_index]}
                                else
                                pre_domain=${xray_domain_array[x]}
                            fi
                            case ${current_tag,,} in
                                *"trojan-ws"*)
                                    current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"trojan-warp"*)
                                    current_template=$(echo "$quanx_xray_trojan_wss_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vmess-ws"*)
                                    current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vmess-warp"*)
                                    current_template=$(echo "$quanx_xray_vmess_wss_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"shadowsocks-ws"*)
                                    current_template=$(echo "$quanx_xray_shadowsocks_wss_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"shadowsocks-warp"*)
                                    current_template=$(echo "$quanx_xray_shadowsocks_wss_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *)
                                    current_template=""
                                ;;
                            esac
                            xray_user_name+=("$current_template")
                            xray_all_name+=("$current_template")
                        done
                        printf "%s\n" "${xray_user_name[@]}" > "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                        grep -v '^$' "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded" >  "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                        rm -rf "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                        echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$is_tag/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_tag_sub.txt
                    fi
                fi
            done
            printf "%s\n" "${xray_all_name[@]}" > "$html_dir/$short_uuid/$chosen_uuid-encoded"
            grep -v '^$' "$html_dir/$short_uuid/$chosen_uuid-encoded" >  "$html_dir/$short_uuid/$chosen_uuid"
            rm -rf "$html_dir/$short_uuid/$chosen_uuid-encoded"
            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
xRay_v2rayn_auto(){
    clear
    xray_type_dir="xray"
    xray_subscription_dir="v2rayn"
    xray_subscription_intro
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        xray_trojan_tcp_template="trojan://full_uuid@example.com:443?security=tls&alpn=http%2F1.1&type=tcp&headerType=none&host=example.com#tagname"
        xray_trojan_ws_template="trojan://full_uuid@predomain.com:443?security=tls&sni=example.com&type=ws&host=example.com&path=/yourpath#tagname"
        xray_trojan_grpc_template="trojan://full_uuid@predomain.com:443?security=tls&sni=example.com&type=grpc&host=example.com&serviceName=yourpath#tagname"
        xray_vless_xtls_template="vless://full_uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=example.com&fp=chrome&type=tcp&headerType=none&host=example.com#tagname"
        xray_vless_tcp_template="vless://full_uuid@example.com:443?security=tls&type=tcp&headerType=http&path=/yourpath#tagname修改path:/yourpath"
        xray_vless_ws_template="vless://full_uuid@predomain.com:443?security=tls&sni=example.com&fp=chrome&host=example.com&type=ws&path=/yourpath#tagname"
        xray_vless_grpc_template="vless://full_uuid@predomain.com:443?security=tls&sni=example.com&host=example.com&type=grpc&serviceName=yourpath#tagname"
        xray_vmess_tcp_template='{"v":"2","ps":"tagname","add":"example.com","port":"443","id":"full_uuid","aid":"0","scy":"auto","net":"tcp","type":"http","host":"","path":"/yourpath","tls":"tls","sni":"","alpn":"","fp":""}'
        xray_vmess_ws_template='{"v":"2","ps":"tagname","add":"predomain.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"ws","type":"none","host":"example.com","path":"/yourpath","tls":"tls","sni":"example.com","alpn":"","fp":"chrome"}'
        xray_vmess_grpc_template='{"v":"2","ps":"tagname","add":"predomain.com","port":"443","id":"full_uuid","aid":"0","scy":"none","net":"grpc","type":"gun","host":"example.com","path":"yourpath","tls":"tls","sni":"example.com","alpn":"h2","fp":"chrome"}'
        xray_shadowsocks="chacha20-ietf-poly1305:base64_uuid"
        for chosen_uuid in "${unique_xray_tag_all_uuids[@]}"; do
            short_uuid="${chosen_uuid:0:8}"
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            xray_all_user_name=()
            mkdir -p "$html_dir/$short_uuid"
            for i in "${!xray_all_tags[@]}"; do
                current_tag="${xray_all_tags[i]}"
                next_tag="${xray_all_tags[i+1]}"
                [[ -z "$next_tag" ]] && next_tag="outbounds"
                is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                xray_tag_uuid=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
                xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
                xray_count_id=false
                if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
                    xray_tag_path=$(echo "$xray_content" |grep -oP '"serviceName":\s*"\K[^\"]+')
                fi
                if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
                    xray_tag_path=""
                fi
                for is_uuid in "${xray_tag_uuid[@]}"; do
                    if [ "$chosen_uuid" == "$is_uuid" ]; then
                        xray_count_id=true
                        break
                    fi
                done
                if [ "$xray_count_id" = false ]; then
                    if [[ "$is_tag" == *"trojan"* ]] ; then
                        for is_uuid in "${xray_tag_password[@]}"; do
                            if [ "$chosen_uuid" == "$is_uuid" ] ; then
                                xray_count_id=true
                                break
                            fi
                        done
                    fi
                fi
                if [ "$xray_count_id" = false ]; then
                    for is_password in "${xray_tag_password[@]}"; do
                        if [ "$chosen_base64" == "$is_password" ]; then
                            xray_count_id=true
                            break
                        fi
                    done
                fi
                if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* || ${current_tag,,} == *"-warp"* ]]; then
                    xray_suffix="${selected_cdn#*.}"
                    else
                    xray_suffix="${selected_tls#*.}"
                fi
                for ((i = 0; i < ${#xray_domain_array[@]}; i++)); do
                    original_domain=${xray_domain_array[$i]}
                    dot_position=$(expr index "$original_domain" ".")
                    xray_prefix=${original_domain:0:dot_position-1}
                    xray_new_domain="$xray_prefix.$xray_suffix"
                    xray_domain_array[$i]=$xray_new_domain
                done
                if [ "$xray_count_id" = true ]; then
                    mkdir -p "$html_dir/$short_uuid/$is_tag"
                    xray_user_name=()
                    for ((x=0; x<${#xray_domain_array[@]}; x++)); do
                        selected_domain=${xray_domain_array[x]}
                        country=${country_array[x]}
                        prefix_a="${selected_domain%%.*}"
                        current_template=""
                        if [ ${#preferred_sorted_domains[@]} -gt 0 ]; then
                            length=${#preferred_sorted_domains[@]}
                            random_index=$((RANDOM % length))
                            pre_domain=${preferred_sorted_domains[$random_index]}
                            else
                            pre_domain=${xray_domain_array[x]}
                        fi
                        case ${current_tag,,} in
                            *"vless-xtls"*)
                                current_template=$(echo "$xray_vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/"${prefix_a^^}"_${current_tag^}_$country/")
                                ;;
                            *"trojan-tcp"*)
                                current_template=$(echo "$xray_trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"trojan-ws"*)
                                current_template=$(echo "$xray_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"trojan-warp"*)
                                current_template=$(echo "$xray_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"trojan-grpc"*)
                                current_template=$(echo "$xray_trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"vless-tcp"*)
                                current_template=$(echo "$xray_vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"vless-ws"*)
                                current_template=$(echo "$xray_vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"vless-warp"*)
                                current_template=$(echo "$xray_vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                ;;
                            *"vless-grpc"*)
                                current_template=$(echo "$xray_vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$xray_tag_path#" -e "s#tagname#${prefix_a^^}_${current_tag^}_$country#")
                                ;;
                            *"vmess-tcp"*)
                                current_template=$(echo "$xray_vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            *"vmess-ws"*)
                                current_template=$(echo "$xray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            *"vmess-warp"*)
                                current_template=$(echo "$xray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            *"vmess-grpc"*)
                                current_template=$(echo "$xray_vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                                current_template="vmess://$(echo -n "$current_template" | base64 | tr -d '\n')"
                                ;;
                            *"shadowsocks-tcp"*)
                                current_template=$(echo "$xray_shadowsocks" | sed -e "s/base64_uuid/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${country}改Path:/$xray_tag_path,协议tcp，类型http，下方tls"
                                ;;
                            *"shadowsocks-ws"*)
                                current_template=$(echo "$xray_shadowsocks" | sed -e "s/base64_uuid/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${country}改Path:/$xray_tag_path,协议ws，下方tls"
                                ;;
                            *"shadowsocks-grpc"*)
                                current_template=$(echo "$xray_shadowsocks" | sed -e "s/base64_uuid/$chosen_base64/")
                                current_template="ss://$(echo -n "$current_template" | base64 | tr -d '\n')@$selected_domain:443#${prefix_a^^}_${current_tag^}_${country}改Path:$xray_tag_path,协议gRPC,类型gun,下方TLS"
                                ;;
                            *)
                                current_template=""
                                ;;
                        esac
                        xray_user_name+=("$current_template")
                        xray_all_user_name+=("$current_template")
                    done
                    printf "%s\n" "${xray_user_name[@]}"  > "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                    grep -v '^$' "$html_dir/$short_uuid/$is_tag/$chosen_uuid" >  "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                    reencoded_base64=$(base64 < "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded" | tr -d '\n')
                    echo "$reencoded_base64" > "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                    rm -rf "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                    echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$is_tag/$chosen_uuid" | tee -a "/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt"
                fi
            done
            printf "%s\n" "${xray_all_user_name[@]}"  > "$html_dir/$short_uuid/$chosen_uuid"
            grep -v '^$' "$html_dir/$short_uuid/$chosen_uuid" >  "$html_dir/$short_uuid/$chosen_uuid-encoded"
            reencoded_base64=$(base64 < "$html_dir/$short_uuid/$chosen_uuid-encoded" | tr -d '\n')
            echo "$reencoded_base64" > "$html_dir/$short_uuid/$chosen_uuid"
            rm -rf "$html_dir/$short_uuid/$chosen_uuid-encoded"
            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$chosen_uuid" | tee -a "/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt"
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
         display_pause_info
    fi
}
xRay_nekoray_auto(){
    clear
    xray_type_dir="xray"
    xray_subscription_dir="nekoray"
    xray_subscription_intro
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt
        rm -rf /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        nekoray_trojan_tcp_template='{"_v":0,"addr":"example.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"alpn":"http/1.1","ed_len":0,"insecure":false,"mux_s":0,"net":"tcp","sec":"tls"}}'
        nekoray_trojan_ws_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"host":"example.com","insecure":false,"mux_s":0,"net":"ws","sni":"example.com","path":"/yourpath","sec":"tls"}}'
        nekoray_trojan_grpc_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekoray_vless_xtls_template='{"_v":0,"addr":"example.com","flow":"xtls-rprx-vision","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"tcp","sec":"tls","sni":"example.com","utls":"chrome"}}'
        nekoray_vless_tcp_template='{"_v":0,"addr":"example.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"h_type":"http","insecure":false,"mux_s":0,"net":"tcp","path":"/yourpath","sec":"tls"}}'
        nekoray_vless_ws_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"host":"example.com","insecure":false,"mux_s":0,"net":"ws","path":"/yourpath","sec":"tls","sni":"example.com"}}'
        nekoray_vless_grpc_template='{"_v":0,"addr":"predomain.com","name":"tagname","pass":"full_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekoray_vmess_tcp_template='{"_v":0,"addr":"example.com","aid":0,"id":"full_uuid","name":"tagname","port":443,"sec":"auto","stream":{"ed_len":0,"h_type":"http","host":"example.com","insecure":false,"mux_s":0,"net":"tcp","path":"/yourpath","sec":"tls"}}'
        nekoray_vmess_ws_template='{"_v":0,"addr":"predomain.com","aid":0,"id":"full_uuid","name":"tagname","port":443,"sec":"none","stream":{"ed_len":0,"h_type":"none","host":"example.com","insecure":false,"mux_s":0,"net":"ws","path":"/yourpath","sec":"tls","sni":"example.com"}}'
        nekoray_vmess_grpc_template='{"_v":0,"addr":"predomain.com","aid":0,"id":"full_uuid","name":"tagname","port":443,"sec":"none","stream":{"ed_len":0,"h_type":"gun","host":"example.com","insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"}}'
        nekoray_shadowsocks_tcp='{"_v":0,"addr":"example.com","method":"chacha20-ietf-poly1305","name":"tagname","pass":"base64_uuid","port":443,"stream":{"ed_len":0,"h_type":"http","insecure":false,"mux_s":0,"net":"tcp","path":"/yourpath","sec":"tls"},"uot":0}'
        nekoray_shadowsocks_ws='{"_v":0,"addr":"example.com","method":"chacha20-ietf-poly1305","name":"tagname","pass":"base64_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"ws","path":"/yourpath","sec":"tls"},"uot":0}'
        nekoray_shadowsocks_grpc='{"_v":0,"addr":"predomain.com","method":"chacha20-ietf-poly1305","name":"tagname","pass":"base64_uuid","port":443,"stream":{"ed_len":0,"insecure":false,"mux_s":0,"net":"grpc","path":"yourpath","sec":"tls","sni":"example.com"},"uot":0}'
        for chosen_uuid in "${unique_xray_tag_all_uuids[@]}"; do
            short_uuid="${chosen_uuid:0:8}"
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            xray_all_user_name=()
            mkdir -p "$html_dir/$short_uuid"
            for i in "${!xray_all_tags[@]}"; do
                current_tag="${xray_all_tags[i]}"
                next_tag="${xray_all_tags[i+1]}"
                [[ -z "$next_tag" ]] && next_tag="outbounds"
                is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                xray_tag_uuid=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
                xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
                xray_count_id=false
                if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
                    xray_tag_path=$(echo "$xray_content" |grep -oP '"serviceName":\s*"\K[^\"]+')
                fi
                if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
                    xray_tag_path=""
                fi
                for is_uuid in "${xray_tag_uuid[@]}"; do
                    if [ "$chosen_uuid" == "$is_uuid" ]; then
                        xray_count_id=true
                        break
                    fi
                done
                if [ "$xray_count_id" = false ]; then
                    if [[ "$is_tag" == *"trojan"* ]] ; then
                        for is_uuid in "${xray_tag_password[@]}"; do
                            if [ "$chosen_uuid" == "$is_uuid" ] ; then
                                xray_count_id=true
                                break
                            fi
                        done
                    fi
                fi
                if [ "$xray_count_id" = false ]; then
                    for is_password in "${xray_tag_password[@]}"; do
                        if [ "$chosen_base64" == "$is_password" ]; then
                            xray_count_id=true
                            break
                        fi
                    done
                fi
                if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* || ${current_tag,,} == *"-warp"* ]]; then
                    xray_suffix="${selected_cdn#*.}"
                    else
                    xray_suffix="${selected_tls#*.}"
                fi
                for ((i = 0; i < ${#xray_domain_array[@]}; i++)); do
                    original_domain=${xray_domain_array[$i]}
                    dot_position=$(expr index "$original_domain" ".")
                    xray_prefix=${original_domain:0:dot_position-1}
                    xray_new_domain="$xray_prefix.$xray_suffix"
                    xray_domain_array[$i]=$xray_new_domain
                done
                if [ "$xray_count_id" = true ]; then
                    mkdir -p "$html_dir/$short_uuid/$is_tag"
                    xray_user_name=()
                    for ((x=0; x<${#xray_domain_array[@]}; x++)); do
                        selected_domain=${xray_domain_array[x]}
                        country=${country_array[x]}
                        prefix_a="${selected_domain%%.*}"
                        current_template=""
                        if [ ${#preferred_sorted_domains[@]} -gt 0 ]; then
                            length=${#preferred_sorted_domains[@]}
                            random_index=$((RANDOM % length))
                            pre_domain=${preferred_sorted_domains[$random_index]}
                            else
                            pre_domain=${xray_domain_array[x]}
                        fi
                        case ${current_tag,,} in
                        *"vless-xtls"*)
                            current_template=$(echo "$nekoray_vless_xtls_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/"${prefix_a^^}"_${current_tag^}_$country/")
                            current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"trojan-tcp"*)
                            current_template=$(echo "$nekoray_trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"trojan-ws"*)
                            current_template=$(echo "$nekoray_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"trojan-warp"*)
                            current_template=$(echo "$nekoray_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"trojan-grpc"*)
                            current_template=$(echo "$nekoray_trojan_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://trojan#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vless-tcp"*)
                            current_template=$(echo "$nekoray_vless_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vless-ws"*)
                            current_template=$(echo "$nekoray_vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vless-warp"*)
                            current_template=$(echo "$nekoray_vless_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vless-grpc"*)
                            current_template=$(echo "$nekoray_vless_grpc_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s#example.com#$selected_domain#g"  -e "s#yourpath#$xray_tag_path#" -e "s#tagname#${prefix_a^^}_${current_tag^}_$country#")
                            current_template="nekoray://vless#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vmess-tcp"*)
                            current_template=$(echo "$nekoray_vmess_tcp_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vmess-ws"*)
                            current_template=$(echo "$nekoray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vmess-warp"*)
                            current_template=$(echo "$nekoray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"vmess-grpc"*)
                            current_template=$(echo "$nekoray_vmess_grpc_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://vmess#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"shadowsocks-tcp"*)
                            current_template=$(echo "$nekoray_shadowsocks_tcp" | sed -e "s/base64_uuid/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://shadowsocks#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"shadowsocks-ws"*)
                            current_template=$(echo "$nekoray_shadowsocks_ws" | sed -e "s/base64_uuid/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://shadowsocks#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *"shadowsocks-grpc"*)
                            current_template=$(echo "$nekoray_shadowsocks_grpc" | sed -e "s/base64_uuid/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/g" -e "s/tagname/${prefix_a^^}_${current_tag^}_$country/")
                            current_template="nekoray://shadowsocks#$(echo -n "$current_template" | base64 | tr -d '\n')"
                            ;;
                        *)
                            current_template=""
                            ;;
                    esac
                        xray_user_name+=("$current_template")
                        xray_all_user_name+=("$current_template")
                    done
                    printf "%s\n" "${xray_user_name[@]}"  > "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                    grep -v '^$' "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded" >  "$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                    rm -rf "$html_dir/$short_uuid/$is_tag/$chosen_uuid-encoded"
                    echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$is_tag/$chosen_uuid" | tee -a "/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt"
                fi
            done
            printf "%s\n" "${xray_all_user_name[@]}"  > "$html_dir/$short_uuid/$chosen_uuid-encoded"
            grep -v '^$' "$html_dir/$short_uuid/$chosen_uuid-encoded" >  "$html_dir/$short_uuid/$chosen_uuid"
            rm -rf "$html_dir/$short_uuid/$chosen_uuid-encoded"
            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$chosen_uuid" | tee -a "/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt"
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        display_pause_info
    fi
}
xRay_surfboard_auto(){
    clear
    path_count=88
    xray_type_dir="xray"
    xray_subscription_dir="surfboard"
    xray_subscription_intro
    if [ ${#xray_domain_array[@]} -gt 0 ]; then
        input_file="/etc/$xray_type_dir/Surfboard_DOH_AdGuard.conf"
        end_file="/etc/$xray_type_dir/Surfboard_DOH_end.conf"
        rm -f "$input_file" Surfboard_DOH_AdGuard.conf
        rm -f "$end_file" Surfboard_DOH_end.conf
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/Surfboard_DOH_AdGuard.conf > /dev/null 2>&1
        wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/Surfboard_DOH_end.conf > /dev/null 2>&1
        sleep 1
        mv Surfboard_DOH_AdGuard.conf "$input_file" -f
        mv Surfboard_DOH_end.conf "$end_file" -f
        surfboard_xray_trojan_ws_template='tagname = trojan, predomain.com, 443, password=full_uuid, ws=true, ws-path=/yourpath, skip-cert-verify=false, udp-relay=false, sni=example.com'
        surfboard_xray_trojan_tcp_template='tagname = trojan, example.com, 443, password=full_uuid,  ws=false, ws-path=/, skip-cert-verify=false, udp-relay=false'
        surfboard_xray_vmess_ws_template='tagname = vmess, predomain.com, 443, username=full_uuid, ws=true, tls=true, ws-path=/yourpath, skip-cert-verify=false, udp-relay=false, vmess-aead=true, ws-headers=Host:example.com, sni=example.com'
        surfboard_xray_shadowsocks_ws_template='tagname = ss, example.com, 443, encrypt-method=chacha20-ietf-poly1305, password=passwordbase64, udp-relay=false, obfs=http, obfs-uri=/yourpath'
        for chosen_uuid in "${unique_xray_tag_all_uuids[@]}"; do
            short_uuid="${chosen_uuid:0:8}"
            chosen_base64=$(echo -n "$chosen_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            chosen_base64+="=="
            mkdir -p "$html_dir/$short_uuid"
            xray_surfboard_all_tag=() xray_surfboard_all_name=()
            for i in "${!xray_all_tags[@]}"; do
                current_tag="${xray_all_tags[i]}"
                next_tag="${xray_all_tags[i+1]}"
                [[ -z "$next_tag" ]] && next_tag="outbounds"
                is_tag=$(echo "${xray_all_tags[i]}" | tr -d ' ' | tr '[:upper:]' '[:lower:]')
                if [[ "$is_tag" == *"trojan-ws"* || "$is_tag" == *"trojan-warp"* || "$is_tag" == *"trojan-tcp"* || "$is_tag" == *"vmess-ws"* || "$is_tag" == *"vmess-warp"* || "$is_tag" == *"shadowsocks-ws"* ]]; then
                    xray_content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
                    xray_tag_path=$(echo "$xray_content" | grep -oP '"path":\s*"\K[^\"]+' | head -n1 | tr -d '/')
                    xray_tag_uuid=($(echo "$xray_content" | grep -oP '"id":\s*"\K[^\"]+'))
                    xray_tag_password=($(echo "$xray_content" | grep -oP '"password":\s*"\K[^\"]+'))
                    xray_count_id=false
                    if [[ "${xray_all_tags[i]}" == *gRPC* ]]; then
                        xray_tag_path=$(echo "$xray_content" |grep -oP '"serviceName":\s*"\K[^\"]+')
                    fi
                    if [[ "${xray_all_tags[i]}" == *xTLS* ]]; then
                        xray_tag_path=""
                    fi
                    for is_uuid in "${xray_tag_uuid[@]}"; do
                        if [ "$chosen_uuid" == "$is_uuid" ]; then
                            xray_count_id=true
                            break
                        fi
                    done
                    if [ "$xray_count_id" = false ]; then
                        if [[ "$is_tag" == *"trojan"* ]] ; then
                            for is_uuid in "${xray_tag_password[@]}"; do
                                if [ "$chosen_uuid" == "$is_uuid" ] ; then
                                    xray_count_id=true
                                    break
                                fi
                            done
                        fi
                    fi
                    if [ "$xray_count_id" = false ]; then
                        for is_password in "${xray_tag_password[@]}"; do
                            if [ "$chosen_base64" == "$is_password" ]; then
                                xray_count_id=true
                                break
                            fi
                        done
                    fi
                    if [[ ${current_tag,,} == *"-grpc"* || ${current_tag,,} == *"-ws"* || ${current_tag,,} == *"-warp"* ]]; then
                        xray_suffix="${selected_cdn#*.}"
                        else
                        xray_suffix="${selected_tls#*.}"
                    fi
                    for ((i = 0; i < ${#xray_domain_array[@]}; i++)); do
                        original_domain=${xray_domain_array[$i]}
                        dot_position=$(expr index "$original_domain" ".")
                        xray_prefix=${original_domain:0:dot_position-1}
                        xray_new_domain="$xray_prefix.$xray_suffix"
                        xray_domain_array[$i]=$xray_new_domain
                    done
                    if [ "$xray_count_id" = true ]; then
                        mkdir -p "$html_dir/$short_uuid/$is_tag"
                        xray_user_name=() xray_user_tags=()
                        for ((x=0; x<${#xray_domain_array[@]}; x++)); do
                            selected_domain=${xray_domain_array[x]}
                            country=${country_array[x]}
                            prefix_a="${selected_domain%%.*}"
                            if [ ${#preferred_sorted_domains[@]} -gt 0 ]; then
                                length=${#preferred_sorted_domains[@]}
                                random_index=$((RANDOM % length))
                                pre_domain=${preferred_sorted_domains[$random_index]}
                                else
                                pre_domain=${xray_domain_array[x]}
                            fi
                            current_template=""
                            case ${current_tag,,} in
                                *"trojan-tcp"*)
                                    current_template=$(echo "$surfboard_xray_trojan_tcp_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"trojan-ws"*)
                                    current_template=$(echo "$surfboard_xray_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"trojan-warp"*)
                                    current_template=$(echo "$surfboard_xray_trojan_ws_template" | sed -e "s#full_uuid#$chosen_uuid#" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vmess-ws"*)
                                    current_template=$(echo "$surfboard_xray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"vmess-warp"*)
                                    current_template=$(echo "$surfboard_xray_vmess_ws_template" | sed -e "s/full_uuid/$chosen_uuid/" -e "s/predomain.com/$pre_domain/g" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *"shadowsocks-ws"*)
                                    current_template=$(echo "$surfboard_xray_shadowsocks_ws_template" | sed -e "s/passwordbase64/$chosen_base64/" -e "s/example.com/$selected_domain/g" -e "s/yourpath/$xray_tag_path/" -e "s/tagname/${prefix_a^^}_${current_tag}_$country/")
                                    ;;
                                *)
                                    current_template=""
                                ;;
                            esac
                            xray_user_name+=("$current_template")
                            xray_user_tags+=(${prefix_a^^}_${current_tag}_$country)
                            xray_surfboard_all_name+=("$current_template")
                            xray_surfboard_all_tag+=(${prefix_a^^}_${current_tag}_$country)
                        done
                        output_file="$html_dir/$short_uuid/$is_tag/$chosen_uuid"
                        cp "$input_file" "$output_file" -f
                        IFS=,
                        surfboard_proxy="SelectGroup = select, AllProxies, AutoTestGroup, LoadBalanceGroup, DIRECT, REJECT"
                        surfboard_all="AllProxies = select, include-all-proxies = true"
                        surfboard_auto="AutoTestGroup = url-test, ${xray_user_tags[*]}, url=http://www.gstatic.com/generate_204, interval=6000"
                        surfboard_balance="LoadBalanceGroup = load-balance, ${xray_user_tags[*]}"
                        IFS=$' \t\n'
                        printf "%s\n" "${xray_user_name[@]}" >> "$output_file"
                        echo -e "\n" >> "$output_file"
                        echo -e "[Proxy Group]" >> "$output_file"
                        echo "$surfboard_proxy" >> "$output_file"
                        echo "$surfboard_all" >> "$output_file"
                        echo "$surfboard_auto" >> "$output_file"
                        echo "$surfboard_balance" >> "$output_file"
                        cat "$end_file">> "$output_file"
                        echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$is_tag/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt
                    fi
                fi
            done
            output_file="$html_dir/$short_uuid/$chosen_uuid"
            cp "$input_file" "$output_file" -f
            IFS=,
            surfboard_proxy="SelectGroup = select, AllProxies, AutoTestGroup, LoadBalanceGroup, DIRECT, REJECT"
            surfboard_all="AllProxies = select, include-all-proxies = true"
            surfboard_auto="AutoTestGroup = url-test, ${xray_surfboard_all_tag[*]}, url=http://www.gstatic.com/generate_204, interval=6000"
            surfboard_balance="LoadBalanceGroup = load-balance, ${xray_surfboard_all_tag[*]}"
            IFS=$' \t\n'
            printf "%s\n" "${xray_surfboard_all_name[@]}" >> "$output_file"
            echo -e "\n" >> "$output_file"
            echo -e "[Proxy Group]" >> "$output_file"
            echo "$surfboard_proxy" >> "$output_file"
            echo "$surfboard_all" >> "$output_file"
            echo "$surfboard_auto" >> "$output_file"
            echo "$surfboard_balance" >> "$output_file"
            cat "$end_file">> "$output_file"
            echo "https://$selected_cdn/$xray_type_dir/$xray_subscription_dir/$short_uuid/$chosen_uuid" | tee -a /etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt
        done
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m订阅目录: \e[0m\e[1;32m$html_dir\e[0m"
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_tags_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/小写标签名/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
        echo -e " - \e[1;33m日志文件: \e[0m\e[1;32m/etc/$xray_type_dir/${xray_subscription_dir}_xray_all_sub.txt\e[0m"
        echo -e " - \e[1;33m用户链接: \e[0m\e[1;32mhttps://$selected_cdn/$xray_type_dir/$xray_subscription_dir/UUID前8位/完整UUID\e[0m"
        for ((i = 0; i < path_count; i++)); do echo -n -e "-"; done; echo -e "";
    rm -f "$input_file"
    rm -f "$end_file"
    display_pause_info
    fi
}
uninstall_all(){
    clear
    config_files
    GREEN='\033[0;32m'
    NC='\033[0m'
    packages=("jq" "sing-box" "socat" "net-tools" "uuid-runtime" "dnsutils" "lsof" "build-essential" "libssl-dev" "libevent-dev" "zlib1g-dev" "gcc-mingw-w64" "nginx")
    for package in "${packages[@]}"; do
        sudo apt-get purge --auto-remove -y "xray" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}- 卸载成功 $package${NC}"
        else
            echo "  * 卸载 $package 失败 "
        fi
    done
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove
    rm /usr/share/nginx/html/ -rf > /dev/null 2>&1
    rm -f "$xray_config_file" > /dev/null 2>&1
    rm -f "$nginx_config_file" > /dev/null 2>&1
    rm -f "$box_config_file" > /dev/null 2>&1
    rm -f "$nginx_index_file" > /dev/null 2>&1
    rm -rf /etc/nginx/conf.d/*.* > /dev/null 2>&1
    unlink /usr/local/bin/nruan > /dev/null 2>&1
    rm -f /usr/local/bin/nruan.sh > /dev/null 2>&1
    rm -rf /usr/local/bin/nruan > /dev/null 2>&1
    display_pause_info
}
auto_all_subscriptions(){
    clear
    path_count=88
    for ((i = 0; i < path_count; i++)); do echo -n -e "="; done; echo -e "";
    echo -e " - \e[1;33m给你5秒钟反悔，自动清除所有订阅，并重新生成所有订阅\e[0m"
    echo -e " - 结束按  \e[1;31m Ctrl + C\e[0m 键"
    for ((i = 0; i < path_count; i++)); do echo -n -e "="; done; echo -e "";
    sleep 5
    clear_all_subscriptions
    xray_domain_array=()
    enable_preferences=""
    xRay_v2rayn_auto
    xRay_neko_auto
    xRay_quanx_auto
    xRay_clash_auto
    xRay_nekoray_auto
    sing_box_v2rayn_auto
    sing_box_neko_auto
    sing_box_quanx_auto
    sing_box_shadowrocket_auto
    xRay_surfboard_auto
}
client_other_export_choice() {
    choice=$1
    actions=(
        all_subscription
        quanx_all_subscription
        get_xray_new_domain_subscription
        get_xray_old_domain_subscription
        get_sing_box_domain_subscription
        quanx_all_domain_subscription
        get_xray_new_tags_subscription
        get_xray_old_tags_subscription
        get_sing_box_tags_subscription
        auto_xray_all_tags
    )
    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择, 请重新输入。"
    fi
}
client_other_export() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 订阅与配置"
        MENU_TEXT2="Michael Mao"
        equals1=$(( (menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( (menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        output_line1=$(printf "=%.0s" $(seq 1 $equals1))
        output_line2=$(printf " %.0s" $(seq 1 $equals2))
        output1="$output_line1 $MENU_TEXT1 $output_line1"
        output2="$output_line2 $MENU_TEXT2"
        clear
        echo -e "\n\e[93m$output1\e[0m"
        echo -e "\e[90m$output2\e[0m"
        menu_items=(
            "\e[1;32m一键生成\e[0m所有用户v2rayN\e[0m订阅\e[0m"
            "\e[1;32m一键生成\e[0m所有用户QuantumultX\e[0m订阅"
            "\e[1;32m按域名\e[0m生成所有xRay新用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按域名\e[0m生成所有xRay老用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按域名\e[0m生成所有Sing-Box用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按域名\e[0m生成QuantumultX所有用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按标签\e[0m生成所有xRay新用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按标签\e[0m生成所有xRay老用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按标签\e[0m生成所有Sing-Box用户\e[1;93m序列域名\e[0m订阅"
            "\e[1;32m按标签\e[0m生成所有xRay用户\e[1;93m序列域名\e[0m订阅"
            "返回主菜单"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < menu_line; j++)); do
                echo -n -e "\e[90m·"
            done
            if [ $i -eq $((${#menu_items[@]} - 1)) ]; then
                echo -e "\e[0m\n   0.  返回主菜单"
            else
                if [ $i -lt 9 ]; then
                    echo -e "\e[0m\n   $((i + 1)).  $item"
                else
                    echo -e "\e[0m\n   $((i + 1)). $item"
                fi
            fi
        done
        bottom_text="www.nruan.com"
        equals_bottom=$(( (menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -r -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 返回主菜单）: " choice
        case $choice in
            [1-9]|1[0-5])
                client_other_export_choice "$choice";;
            0)
                return;;
            *)
                echo "无效选择, 请重新输入。";;
        esac
    done
}
client_export_choice() {
    choice=$1
    actions=(
        user_xray_new
        user_xray_old
        user_sing_box
        xRay_v2rayn_auto
        xRay_neko_auto
        xRay_nekoray_auto
        xRay_quanx_auto
        xRay_clash_auto
        xRay_surfboard_auto
        sing_box_v2rayn_auto
        sing_box_neko_auto
        sing_box_quanx_auto
        sing_box_shadowrocket_auto
        auto_all_subscriptions
        clear_all_subscriptions
        client_other_export
    )
    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择, 请重新输入。"
    fi
}
client_export() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 订阅与配置"
        MENU_TEXT2="Michael Mao"
        equals1=$(( (menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( (menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        output_line1=$(printf "=%.0s" $(seq 1 $equals1))
        output_line2=$(printf " %.0s" $(seq 1 $equals2))
        output1="$output_line1 $MENU_TEXT1 $output_line1"
        output2="$output_line2 $MENU_TEXT2"
        clear
        echo -e "\n\e[93m$output1\e[0m"
        echo -e "\e[90m$output2\e[0m"
        menu_items=(
            "\e[1;33m查看单个\e[0mxRay新用户V2RayN客户端配置"
            "\e[1;33m查看单个\e[0mxRay老用户V2RayN客户端配置"
            "\e[1;33m查看单个\e[0mSing-Box用户V2RayN客户端配置"
            "\e[1;32m自动生成\e[0m所有xRay用户\e[1;93m序列域名\e[0mV2RayN订阅"
            "\e[1;32m自动生成\e[0m所有xRay用户\e[1;93m序列域名\e[0mNekoBox订阅"
            "\e[1;32m自动生成\e[0m所有xRay用户\e[1;93m序列域名\e[0mNekoRay订阅"
            "\e[1;32m自动生成\e[0m所有xRay用户\e[1;93m序列域名\e[0mQuantumultX订阅"
            "\e[1;32m自动生成\e[0m所有xRay用户\e[1;93m序列域名\e[0mClash订阅"
            "\e[1;32m自动生成\e[0m所有xRay用户\e[1;93m序列域名\e[0mSurfBoard订阅"
            "\e[1;32m自动生成\e[0m所有Sing-Box用户\e[1;93m序列域名\e[0mV2RayN订阅"
            "\e[1;32m自动生成\e[0m所有Sing-Box用户\e[1;93m序列域名\e[0mNekoBox订阅"
            "\e[1;32m自动生成\e[0m所有Sing-Box用户\e[1;93m序列域名\e[0mQuantumultX订阅"
            "\e[1;32m自动生成\e[0m所有Sing-Box用户\e[1;93m序列域名\e[0mShadowRocket订阅"
            "\e[1;32m自动清空订阅\e[0m\e[1;91m后执行 4~13项\e[0m\e[1;33m[序列域名默认\e[0m\e[1;32m 10 \e[0m\e[1;33m个]\e[0m"
            "\e[1;91m清空所有用户的订阅\e[0m"
            "\e[1;33m其他订阅生成配置\e[0m\e[0;33m\e[0m"
            "返回主菜单"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < menu_line; j++)); do
                echo -n -e "\e[90m·"
            done
            if [ $i -eq $((${#menu_items[@]} - 1)) ]; then
                echo -e "\e[0m\n   0.  返回主菜单"
            else
                if [ $i -lt 9 ]; then
                    echo -e "\e[0m\n   $((i + 1)).  $item"
                else
                    echo -e "\e[0m\n   $((i + 1)). $item"
                fi
            fi
        done
        bottom_text="www.nruan.com"
        equals_bottom=$(( (menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -r -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 返回主菜单）: " choice
        case $choice in
            [1-9]|1[0-8])
                client_export_choice "$choice";;
            0)
                return;;
            *)
                echo "无效选择, 请重新输入。";;
        esac
    done
}
set_manage_choice() {
    choice=$1
    actions=(
        show_setting_info
        show_xray_info
        show_singbox_info
        show_domain_tls_info
        force_update_domain
        restart_xray
        restart_singbox
        modify_xray_ng_path
        modify_singbox_path
        dokodemo_door_ports
        hysteria2_password
        shadowsocks_password
        singbox_domain_set2
        xray_path_alone
        singbox_path_alone
        modify_singbox_ports
        reset_xray_set
        reset_nginx
        reset_singbox
    )
    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择, 请重新输入。"
    fi
}
set_manage() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 配置管理"
        MENU_TEXT2="Michael Mao"
        equals1=$(( (menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( (menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        output_line1=$(printf "=%.0s" $(seq 1 $equals1))
        output_line2=$(printf " %.0s" $(seq 1 $equals2))
        output1="$output_line1 $MENU_TEXT1 $output_line1"
        output2="$output_line2 $MENU_TEXT2"
        clear
        echo -e "\n\e[93m$output1\e[0m"
        echo -e "\e[90m$output2\e[0m"
        menu_items=(
            "查看Sing-box/xRay配置信息"
            "查看xRay配置信息"
            "查看Sing-box配置信息"
            "查看域名TLS证书有效期"
            "强制更新当前所有域名TLS证书\e[0;33m [通过Nginx]\e[0m"
            "重启xRay/Nginx"
            "重启Sing-box"
            "修改xRay的新、老Path\e[0;33m [共同前缀]\e[0m"
            "修改Sing-Box的Path\e[0;33m [共同前缀]\e[0m"
            "修改xRay中Dokodemo-Door端口"
            "修改Sing-Box中Hysteria2密码"
            "修改Sing-Box中ShadowSocks密码"
            "修改Sing-Box的域名/证书\e[0;33m [仅适用于多域名/证书]\e[0m"
            "单独修改xRay的Path\e[0;33m [任意]"
            "单独修改Sing-Box的Path\e[0;33m [任意]"
            "单独修改Sing-Box的端口\e[0;33m [任意]"
            "重置xRay配置信息(5秒自动恢复用户信息及UUID)"
            "重置Nginx配置文件(自动设置TLS域名)"
            "重置Sing-box配置文件(5秒自动恢复配置)"
            "返回主菜单"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < menu_line; j++)); do
                echo -n -e "\e[90m·"
            done
            if [ $i -eq $((${#menu_items[@]} - 1)) ]; then
                echo -e "\e[0m\n   0.  返回主菜单"
            else
                if [ $i -lt 9 ]; then
                    echo -e "\e[0m\n   $((i + 1)).  $item"
                else
                    echo -e "\e[0m\n   $((i + 1)). $item"
                fi
            fi
        done
        bottom_text="www.nruan.com"
        equals_bottom=$(( (menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -r -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 返回主菜单）: " choice
        case $choice in
            [1-9]|1[0-9])
                set_manage_choice "$choice";;
            0)
                return;;
            *)
                echo "无效选择, 请重新输入。";;
        esac
    done
}
user_manage_choice() {
    choice=$1
    actions=(
        generate_new_uuids
        generate_new_uuid_with_manual_old
        manual_input_uuids
        base64_uuids
        xray_new_uuids
        xray_new_manual_input_uuids
        xray_old_uuids
        xray_old_manual_input_uuids
        singbox_uuids
        singbox_manual_input_uuids
        show_xray_user_info
        show_singbox_user_info
        restart_xray
        restart_singbox
        reset_xray_user
        reset_nginx
        reset_singbox
    )
    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择, 请重新输入。"
    fi
}
user_manage() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 用户管理"
        MENU_TEXT2="Michael Mao"
        equals1=$(( (menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( (menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        output_line1=$(printf "=%.0s" $(seq 1 $equals1))
        output_line2=$(printf " %.0s" $(seq 1 $equals2))
        output1="$output_line1 $MENU_TEXT1 $output_line1"
        output2="$output_line2 $MENU_TEXT2"
        clear
        echo -e "\n\e[93m$output1\e[0m"
        echo -e "\e[90m$output2\e[0m"
        menu_items=(
            "自动生成xRay新、老UUID和Sing-box的UUID并修改其配置"
            "自动生成xRay新UUID和Sing-box, 手动输入xRay老UUID"
            "手动输入xRay新、老UUID和Sing-box的UUID"
            "将UUID转换为ShadowSocks认可的BASE64格式"
            "自动生成xRay新用户的 UUID"
            "手动输入xRay新用户的 UUID"
            "自动生成xRay老用户的 UUID"
            "手动输入xRay老用户的 UUID"
            "自动生成Sing-Box用户的 UUID"
            "手动输入Sing-Box用户的 UUID"
            "查看xRay所有用户UUID信息"
            "查看Sing-Box所有用户UUID信息"
            "重启xRay/Nginx"
            "重启Sing-box"
            "重置xRay用户信息(5秒自动恢Path等设置)"
            "重置Nginx配置文件(自动设置TLS域名)"
            "重置Sing-box配置文件(5秒自动恢复配置)"
            "返回主菜单"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < menu_line; j++)); do
                echo -n -e "\e[90m·"
            done
            if [ $i -eq $((${#menu_items[@]} - 1)) ]; then
                echo -e "\e[0m\n   0.  返回主菜单"
            else
                if [ $i -lt 9 ]; then
                    echo -e "\e[0m\n   $((i + 1)).  $item"
                else
                    echo -e "\e[0m\n   $((i + 1)). $item"
                fi
            fi
        done
        bottom_text="www.nruan.com"
        equals_bottom=$(( (menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -r -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 返回主菜单）: " choice
        case $choice in
            [1-9]|1[0-7])
                user_manage_choice "$choice";;
            0)
                return;;
            *)
                echo "无效选择, 请重新输入。";;
        esac
    done
}
update_xray() {
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
    display_pause_info
}
update_sing_box(){
    bash <(curl -fsSL https://sing-box.app/deb-install.sh)
    display_pause_info
}
update_menu(){
    curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/nruan.sh
    chmod +x nruan.sh
    rm -rf /usr/local/bin/nruan.sh > /dev/null 2>&1
    mv nruan.sh /usr/local/bin/nruan.sh -f > /dev/null 2>&1
    ln -s /usr/local/bin/nruan.sh /usr/local/bin/nruan > /dev/null 2>&1
    chmod +x /usr/local/bin/nruan.sh > /dev/null 2>&1
    exec bash "$0" "$@"
}
main_menu_choice() {
    choice=$1
    actions=(
        user_manage
        set_manage
        client_export
        install_xRay_SingBox
        domain_set
        reset_xray_singbox_nginx
        show_setting_info
        show_user_info
        install_warp
        restart_all
        show_status
        install_all
        update_xray
        update_sing_box
        update_menu
        uninstall_all
        #xray_protocol_details
    )
    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择, 请重新输入。"
    fi
}
main_menu() {
    color_set
    update_check
    check_warp
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 批量管理"
        MENU_TEXT2="Michael Mao"
        MENU_TEXT3="仅适用于 Debian 12 的全新机"
        equals1=$(( (menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( (menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        equals3=$(( (menu_line - ${#MENU_TEXT3} - 10) / 2 ))
        output_line1=$(printf "=%.0s" $(seq 1 $equals1))
        output_line2=$(printf " %.0s" $(seq 1 $equals2))
        output_line3=$(printf " %.0s" $(seq 1 $equals3))
        output1="$output_line1 $MENU_TEXT1 $output_line1"
        output2="$output_line2 $MENU_TEXT2"
        output3="$output_line3 $MENU_TEXT3"
        clear
        echo -e "\n\e[93m$output1\e[0m"
        echo -e "\e[90m$output2\e[0m"
        echo -e "\e[91m$output3\e[0m"
        menu_items=(
            "\e[93mxRay/Sing-box 批量用户管理\e[0m"
            "\e[1;31mxRay/Sing-box 配置管理\e[0m"
            "\e[1;32mxRay/Sing-box 客户端订阅及生成\e[0m"
            "安装Nginx/Sing-box/xRay及相关依赖包"
            "域名检查/设置/重新生成Let's证书\e[0;33m[支持CDN域名]\e[0m"
            "重置xRay/Sing-box/Nginx配置文件\e[0;33m[自动设置已存在TLS的域名]\e[0m"
            "查看Sing-box/xRay配置信息"
            "查看xRay/Sing-box用户信息"
            "$(check_warp)"
            "重启xRay/Sing-box/Nginx"
            "显示xRay/Sing-box/Nginx运行状态"
            "\e[93m一键安装所有配置 \e[0m[可手动选4, 再选5]"
            "更新/重新安装 xRay        \e[90m当前: v$xray_version / 官方: $xray_latest_version\e[0m"
            "更新/重新安装 Sing-box    \e[90m当前: v$box_version / 官方: $box_latest_version\e[0m"
            "更新并重启当前菜单        \e[90m最后更新: $formatted_date \e[0m"
            "再见，后会有期（卸载/删除已安装的应用及配置）"
            "退出"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < menu_line; j++)); do
                echo -n -e "\e[90m·"
            done
            if [ $i -eq $((${#menu_items[@]} - 1)) ]; then
                echo -e "\e[0m\n   0.  退出"
            else
                if [ $i -lt 9 ]; then
                    echo -e "\e[0m\n   $((i + 1)).  $item"
                else
                    echo -e "\e[0m\n   $((i + 1)). $item"
                fi
            fi
        done
        update_text="当前脚本存在更新"
        equals_update=$(( (menu_line - ${#update_text} - 12) / 2 ))
        output_update=$(printf " %.0s" $(seq 1 $equals_update))
        if [ "$github_last_modified" -gt "$usr_local_bin_last_modified" ]; then
            echo -e "\e[92m$output_update $update_text\e[0m"
        fi
        bottom_text="www.nruan.com"
        equals_bottom=$(( (menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -r -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 退出）: " choice
        case $choice in
            [1-9]|1[0-9])
                main_menu_choice "$choice";;
            0)
                return;;
            *)
                echo "无效选择, 请重新输入。";;
        esac
    done
}
    input_domains=()
    while getopts ":d:" opt; do
    case $opt in
        d)
        input_domains+=("$OPTARG")
        color_set
        install_all
        input_domains=()
        ;;
        \?)
        echo "无效的参数: -$OPTARG  -d exp.yourdomain.com ,可以多个-d 域名" >&2
        exit 1
        ;;
        :)
        echo "选项 -$OPTARG 需要已解析好的域名.  如: -d exp.yourdomain.com ,可以多个-d 域名" >&2
        exit 1
        ;;
    esac
    done
main_menu
