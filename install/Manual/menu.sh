#!/bin/bash
color_set() {
    repeat_count=150
    reset_color='\e[0m'
    light_gray='\e[37m'
    dark_gray='\e[90m'
    half_repeat_count=$((repeat_count / 3))
    xpath_count=80
    path_count=80
}
array_assignment() {
    new_uuid_array=()
    old_uuid_array=()
    box_uuid_array=()
}
generate_new_uuids() {
    array_assignment
    read -p $'\e[93m请输入要生成新和旧的UUID数量: \e[0m' count
    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        old_uuid=$(uuidgen)
        box_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
        old_uuid_array+=("$old_uuid")
        box_uuid_array+=("$box_uuid")
    done
    display_generated_uuids
    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    elif [ "$count" -ne 0 ]; then
        config_files
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
    array_assignment
    read -p $'\e[93m请输入要生成新的UUID数量: \e[0m' count
    if [ "$count" -eq 0 ]; then
        echo -e "\e[1;91m生成数量为0，退出菜单。\e[0m"
        exit 0
    fi
    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        box_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
        box_uuid_array+=("$box_uuid")
    done
    echo -e "\e[93m请输入xRay 旧的UUID，每行一个，以空行结束：\e[0m"
    while read -r uuid_manual && [ -n "$uuid_manual" ]; do
        old_uuid_array+=("$uuid_manual")
    done
    if [ ${#box_uuid_array[@]} -eq 0 ]; then
        box_uuid_array+=("$(uuidgen)")
    fi
    display_generated_uuids
    config_files
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
    array_assignment
    echo -e "\e[93m请输入新的xRay UUID，以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        new_uuid_array+=("$uuid")
    done
    if [ ${#new_uuid_array[@]} -eq 0 ]; then
        new_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空，已自动生成 1 枚UUID。\e[0m"
    fi
    echo -e "\e[93m请输入旧的xRay UUID，以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        old_uuid_array+=("$uuid")
    done
    if [ ${#old_uuid_array[@]} -eq 0 ]; then
        old_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空，已自动生成 1 枚UUID。\e[0m"
    fi
    echo -e "\e[93m请输入新的Sing-Box UUID，以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        box_uuid_array+=("$uuid")
    done
    if [ ${#box_uuid_array[@]} -eq 0 ]; then
        box_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空，已自动生成 1 枚UUID。\e[0m"
    fi
    display_generated_uuids
    config_files
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
    printf "%-3s %-50s %-3s %-50s %-3s %-45s %s\n" "No." "xRay New" "No."  "xRay Old" "No."  "Sing-Box"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}-";
    done
    echo -e "${reset_color}"
    for ((i=1; i<=$count; i++)); do
        printf "%-3s %-50s %-3s %-50s %-3s %-50s %s\n" "$i." "${new_uuid_array[i - 1]}" "$i." "${old_uuid_array[i - 1]}" "$i." "${box_uuid_array[i - 1]}"
    done
}
display_pause_info() {
    read -n 1 -s -r -p "按任意键返回主菜单..."
}
base64_uuids() {
    echo "请输入要转换的 UUID，以空行或回车结束"
    
    while read -r uuid && [ -n "$uuid" ]; do
        your_uuid_array+=("$uuid")
    done
    
    if [ "${#your_uuid_array[@]}" -ne 0 ]; then
        for ((i=0; i<"${#your_uuid_array[@]}"; i++)); do
            your_uuid="${your_uuid_array[i]}"
            base64_uuid=$(echo -n "$your_uuid" | base64 | tr -d '/+' | cut -c 1-22)
            base64_uuid+="=="
            base64_uuid_array+=("    $base64_uuid")  # 在追加到数组前添加四个空格
        done
        
        echo -e "BASE64 CODEs:\n"
        for ((i=0; i<"${#base64_uuid_array[@]}"; i++)); do
            echo "${base64_uuid_array[i]}"
        done
        
        echo -e "\n============操作结束============\n"
        exit 0
    else
        echo -e "输入的内容为空或错误，退出，请重新选择"
    fi
    
    display_pause_info
}
reset_xray_files() {
    rm -rf "$xray_config_file" config.conf
    
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/config.json > /dev/null 2>&1
    
    mv config.json "$xray_config_file" -f
}
reset_nginx_files() {
    rm -rf "$nginx_index_file"
    
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
    
    mv default.conf "$nginx_index_file" -f
}
reset_singbox_files() {
    rm -rf "$box_config_file" "config.json"
    
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/singbox_exp.json > /dev/null 2>&1
    
    mv singbox_exp.json "$box_config_file" -f
}
get_xray_tags() {
    new_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag": "\K[^"]+' | grep -iv "OLD" | grep -iv "api"))
    
    old_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag": "\K[^"]+' | grep -i "OLD"))
}
process_xray_new() {
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    get_xray_tags
    new_ids=()
    if [ ${#new_tags[@]} -eq 0 ]; then
        echo "No new tags found. Exiting."
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
            if [[ ! " ${new_ids[@]} " =~ " $id " ]]; then
                new_ids+=("$id")
            fi
        done
    done
    unique_new_ids=($(echo "${new_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
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
                        current_template=("$(echo "$json_template_vmess" | sed -e "s/full_uuid/${new_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                        tag_name+=("$current_template")
                    else
                        current_template=("$(echo "$json_template_xtls" | sed -e "s/full_uuid/${new_uuid_array[j]}/" -e "s/flow2/$flow/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                        tag_name+=("$current_template")
                    fi
                    ;;
                *"trojan"*)
                    current_template=("$(echo "$json_template_trojan" | sed -e "s/full_uuid/${new_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                    tag_name+=("$current_template")
                    ;;
                *"shadowsocks"*)
                    current_template=("$(echo "$json_template_shadowsocks" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid[0]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                    tag_name+=("$current_template")
                    ;;
            esac
        done
        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            tag_array["$current_tag"]=$tag_name_str
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
    for ((i = 0; i < ${#unique_new_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_new_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        sed -i "/${unique_new_ids[$i]}/d; /$modified_base64_id/d" "$xray_config_file"
    done
}
process_xray_old() {
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    get_xray_tags
    old_ids=()
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo "No new tags found. Exiting."
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
            if [[ ! " ${old_ids[@]} " =~ " $id " ]]; then
                old_ids+=("$id")
            fi
        done
    done
    unique_old_ids=($(echo "${old_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
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
                        current_template=("$(echo "$json_template_vmess" | sed -e "s/full_uuid/${old_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                        tag_name+=("$current_template")
                    else
                        current_template=("$(echo "$json_template_xtls" | sed -e "s/full_uuid/${old_uuid_array[j]}/" -e "s/flow2/$flow/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                        tag_name+=("$current_template")
                    fi
                    ;;
                *"trojan"*)
                    current_template=("$(echo "$json_template_trojan" | sed -e "s/full_uuid/${old_uuid_array[j]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                    tag_name+=("$current_template")
                    ;;
                *"shadowsocks"*)
                    current_template=("$(echo "$json_template_shadowsocks" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid[0]}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                    tag_name+=("$current_template")
                    ;;
            esac
        done
        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            tag_array["$current_tag"]=$tag_name_str
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
    for ((i = 0; i < ${#unique_old_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_old_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        sed -i "/${unique_old_ids[$i]}/d; /$modified_base64_id/d" "$xray_config_file"
    done
}
process_sing_box() {
    box_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag": "\K[^"]+' ))
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    all_passwords=()
    if [ ${#box_tags[@]} -eq 0 ]; then
        echo "No new tags found. Exiting."
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
    unique_box_ids=($(echo "${all_passwords[@]}" | tr ' ' '\n' | awk '!a[$0]++'))
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
                    current_template=("$(echo "$json_template_trojan" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),")
                    tag_name+=("$current_template")
                    ;;
                *"vless"*)
                    current_template=("$(echo "$json_template_vless" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),")
                    tag_name+=("$current_template")
                    ;;
                *"vmess"*)
                    current_template=("$(echo "$json_template_vmess" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),")
                    tag_name+=("$current_template")
                    ;;
                *"naive"*)
                    current_template=("$(echo "$json_template_naive" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),")
                    tag_name+=("$current_template")
                    ;;
                *"tuic"*)
                    current_template=("$(echo "$json_template_tuic" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/" -e "s/base64_uuid/${base64_uuid[0]}/"),")
                    tag_name+=("$current_template")
                    ;;
                *"shadowsocks"*)
                    current_template=("$(echo "$json_template_shadowsocks" | sed  -e "s/nruan/$short_uuid/" -e "s/base64_uuid/${base64_uuid[0]}/"),")
                    tag_name+=("$current_template")
                    ;;
            esac
        done
        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            tag_array["$current_tag"]=$tag_name_str
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
    for ((i = 0; i < ${#unique_box_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_box_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        sed -i "/${unique_box_ids[$i]}/d; /$modified_base64_id/d" "$box_config_file"
    done
}
xray_user_info() {
    get_xray_tags
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "xRay 新用户信息 (左边是除 ShadowSock 之外的 UUID)"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}+"; done; echo -e "${reset_color}"
    if [ ${#new_tags[@]} -eq 0 ]; then
        echo "No new tags found. Exiting."
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
            if [[ ! " ${all_ids[@]} " =~ " $id " ]]; then
                all_ids+=("$id")
            fi
        done
    done
    unique_ids=($(echo "${all_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    printf "\e[1m%-5s %-50s %s\e[0m\n" "No." "UUID for other" "ShadowSock Password"
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
    printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "xRay 旧用户信息 (左边是除 ShadowSock 之外的 UUID)"
    all_ids=()
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}+"; done; echo -e "${reset_color}"
    if [ ${#old_tags[@]} -eq 0 ]; then
        echo "No old tags found. Exiting."
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
            if [[ ! " ${all_ids[@]} " =~ " $id " ]]; then
                all_ids+=("$id")
            fi
        done
    done
    unique_ids=($(echo "${all_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    printf "\e[1m%-5s %-50s %s\e[0m\n" "No." "UUID for other" "ShadowSock Password"
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
    is_valid_uuid() {
        local uuid=$1
        [[ $uuid =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
    }
    uuid_to_base64() {
        local uuid=$1
        local base64_uuid=$(echo -n "$uuid" | base64 | tr -d '/+' | cut -c 1-22)
        echo "$base64_uuid=="
    }
    names=($(sed -n '/"vless"\|shadowsocks/,/"outbounds"/ { /"name"/p }' "$box_config_file"))
    names=($(echo "${names[@]}" | tr -d ' ' | tr -d '"' | sed 's/,flow://g' | sed 's/name:nruan,//g' | tr ',' '\n'))
    names=($(echo "${names[@]}" | sed 's/uuid://g' | sed 's/password://g'))
    names=($(echo "${names[@]}" | tr -d '{}'))
    names=($(echo "${names[@]}" | awk '{gsub(/(.{8})(.{4})(.{4})(.{4})(.{12})/, "\\1-\\2-\\3-\\4-\\5")}1'))
    names=($(for uuid in "${names[@]}"; do is_valid_uuid "$uuid" && echo "$uuid"; done | sort -u))
    base64_names=()
    tag_box="Sing-Box   "
    for tag in "vless" "shadowsocks"; do
        [[ "$tag" == "vless" ]] && base64_names=("${names[@]}")
        [[ "$tag" == "shadow"* ]] && base64_names=($(for uuid in "${names[@]}"; do uuid_to_base64 "$uuid"; done))
        for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
        capitalized_tag=$(echo "${tag}" | sed 's/.*/\u&/')
        printf "\e[1;32m%65s%s\e[0m\n" "$tag_box" "${capitalized_tag}"
        for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
        column_width=50
        for ((i = 0; i < ${#base64_names[@]}; i += 3)); do
            for ((j = 0; j < 3 && i + j < ${#base64_names[@]}; j++)); do
                printf "%02d. %-50s" "$((i + j + 1))" "${base64_names[i + j]}"
            done
            echo
            [[ $((i + 3)) -lt ${#base64_names[@]} ]] && { for ((k = 0; k < repeat_count; k++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"; }
        done
    done
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
}
status_all() {
    printf "%-50s %-50s %-45s %s\n" "$nginx_status" "$xray_status" "$box_status" 
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
}
show_singbox_setting() {
    tags=() type=() ports=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag": "\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port": \K[^,]+'))
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%60s""Sing-Box 配置清单\n"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-18s %-8s %-28s %-6s %-20s %-32s %-20s\e[0m\n" "No." "Protocol" "Ports" "Domains or sni" "Type" "Path" "Password" "Method"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t=$(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n1)
        type_t=$(echo "$content" | grep -oP '"type": "\K[^\"]+' | sed -n '2p')
        Domain_t=$(echo "$content" | grep -oP '"server_name": "\K[^\"]+' | head -n1)
         [[ $type_t == *'ws'* ]] && type_x="ws" || type_x=""
        if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password": "\K[^\"]+' | head -n1)
            method_t=$(echo "$content" | grep -oP '"method": "\K[^\"]+' | head -n1)
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
        [ -n "$line_cont" ] && for ((i = 0; i < repeat_count; i++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}" || echo -e "${reset_color}"
    done | sed '$d'
}
show_xray_setting() {
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag": "\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol": "\K[^"]+'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"port": \K[^,]+'))
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%50s""xRay 配置清单\n"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-22s %-18s  %-10s %-20s %-15s %-28s %-20s\e[0m\n" "No." "Name"  "Protocol" "Ports" "Path" "Method"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        current_tag="${tags[i]}"
        next_tag="${tags[i+1]}"
        if [ -z "$next_tag" ]; then
            next_tag="outbounds"
        fi
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$xray_config_file")
        path_t=$(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n1)
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
        [ -n "$line_cont" ] && { for ((i = 0; i < repeat_count; i++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"; } || for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done;
    done
    printf "\n"
}
install_xRay_SingBox() {
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    config_files
    rm -rf /etc/nginx/conf.d/*.*
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root > /dev/null 2>&1
    apt -y update
    clear
    echo -e "\n\e[1;32m  正在安装相关依赖包，首次安装时间比较久，请耐心等待...\e[0m\n"
    echo -e "\e[1;33m  超过15分钟无反应，请重启系统后，再安装\e[0m\n"
    echo -e "\e[1;32m  当前时间：\e[0m$(date +"%Y-%m-%d %H:%M:%S")\n"
    packages=("curl" "uuid-runtime" "dnsutils" "lsof" "build-essential" "libssl-dev" "libevent-dev" "zlib1g-dev" "gcc-mingw-w64" "nginx")
    
    for package in "${packages[@]}"
    do
        apt -y install $package > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "   ${GREEN}成功安装 $package${NC}"
        else
            echo "   安装 $package 失败 "
        fi
    done
    echo ""
    useradd nginx -s /sbin/nologin -M > /dev/null 2>&1
    bash <(curl -fsSL https://sing-box.app/deb-install.sh)> /dev/null 2>&1
    mkdir -p /usr/local/etc
    mkdir -p /etc/sing-box/
    systemctl status nginx > /dev/null
    systemctl status xray > /dev/null
    systemctl status sing-box > /dev/null
    reset_xray_files
    reset_nginx_files
    reset_singbox_files
    display_pause_info
}
domain_input(){
    curl -s https://get.acme.sh | sh > /dev/null 2>&1
    sudo apt-get install -y dnsutils > /dev/null 2>&1
    clear
    for ((j = 0; j < 88; j++)); do echo -n -e "\e[93m="; done; echo -e "\e[0m"
    echo -e "   输入的清单中\e[1;32m至少包含\e[0m一个\e[1;91m未开云朵的域名\e[0m，如 gcp.domain.com 未开云朵。"
    echo -e "   列表如下："
    echo -e "    gcp.domain.com"
    echo -e "    aaa.xyx.org"
    echo -e "    bbb.edu.eu.org"
    echo -e "    bbb.adobe.net"
    echo -e "    ccc.adobe.net"
    echo -e "   确保\e[1;32m每个子域名所含的前缀解析\e[0m是一致的。"
    echo -e "   如gcp.xyx.org解析到了gcp.domain.com的ip，但是开了云朵。"
    echo -e "   如adobe.net中有gcp.adobe.net子域名解析到了\e[1;91mgcp.domain.com\e[0m的ip，但是开了云朵。"
    for ((j = 0; j < 88; j++)); do echo -n -e "\e[90m."; done; echo -e "\e[0m"
    echo -e "   \e[93m--本功能可以获取开了云朵的域名Let's证书\e[0m"
    echo -e "   以上操作主要是有多个域名的情况下，在域名服务商处可以\e[1;32m批量导入\e[0m解析，如Cloudflare:"
    echo -e "        \e[1;91mgcp    127.0.0.1\e[0m"
    echo -e "   把这种格式的文件分别导入到不同的域名DNS记录中，可与本脚本匹配使用。"
    echo -e "   也就是说，有一个域名，解析了20台VPS，但某些原因不能全部用WS或GRPC功能，"
    echo -e "   所以，要用另一个域名来辅助它完成，\e[93m用相同的前缀\e[0m\e[1;32m再次解析\e[0m这20台VPS的IP，并开云朵功能。"
    echo -e "   同样的，可以将不同域名分配给不同的用户群体。"
    echo -e "   \e[93m没有使用单域名别名功能，也就是同一个主域名下的多个子域名，这个可以用Workers解决\e[0m"
    for ((j = 0; j < 88; j++)); do echo -n -e "\e[90m."; done; echo -e "\e[0m"
    echo -e "   因为Sing-Box的特殊性，以及某些协议不能走ws，请确保\e[1;91m至少有一个域名\e[0m是不开云朵的域名）"
    echo -e "   \e[93m注：\e[0mSing-Box的端口与xRay是独立的，如果需要，请自行在\e[1;91mCloudflare\e[0m平台配置\e[1;32mWorkers\e[0m"
    for ((j = 0; j < 88; j++)); do echo -n -e "\e[93m="; done; echo -e "\e[0m"
    echo -e "  请输入你的\e[1;32m域名列表\e[0m，以空行或回车结束（可以很多行，Excel可直接复制粘贴）"
    declare -a domains=()
    while read -r domain && [ -n "$domain" ]; do
        domains+=("$domain")
    done
    local_ip=$(curl -s ifconfig.me)
    
    clear
    echo ""
    echo -e "\e[1;32m正在检测域名与IP匹配情况，请稍候...\e[0m"
    matched_prefix=""
    matched_domain=""
    full_domain=""
    for domain in "${domains[@]}"; do
        result=$(dig +short "$domain" | tr -d '[:space:]')
        if [ "$result" == "$local_ip" ]; then
            matched_prefix=$(echo "$domain" | awk -F'.' '{print $1}')
            matched_domain=$(echo "$domain" | sed "s/$matched_prefix\.//")
            full_domain=$domain
            break
        fi
    done
    processed_domains=()
    unique_domains_new=()
    unique_domains_nginx=()
    for domain in "${domains[@]}"; do
        processed_domains+=("$(echo "$domain" | sed 's/^[^.]*\.//')")
    done
    unique_domains=($(echo "${processed_domains[@]}" | tr ' ' '\n' | sort -u))
    for prefix in "${unique_domains[@]}"; do
        if [ "$prefix" != "$matched_domain" ]; then
            unique_domains_new+=("$matched_prefix.$prefix")
            unique_domains_nginx+=("*.$prefix")
        fi
    done
    echo -e "\e[1;91m 清空/etc/tls目录\e[0m"
    mkdir -p /etc/tls 
    mkdir -p /var/www
    mkdir -p /etc/hysteria
    mkdir -p /var/www/letsencrypt
    rm -rf /etc/tls/*
    systemctl stop nginx > /dev/null 2>&1
    echo -e "\e[1;32m停止Nginx成功\e[0m" 
    if [ -n "$full_domain" ]; then
        if [ -e "/root/.acme.sh/${full_domain}_ecc/fullchain.cer" ]; then
            echo -e "\e[1;32m * 当前域名 $full_domain 已存在 TLS 证书  \e[0m"
        else
            sudo ~/.acme.sh/acme.sh --register-account -m admin@$matched_domain > /dev/null 2>&1
            sudo ~/.acme.sh/acme.sh --issue -d $full_domain --keylength ec-256 --standalone > /dev/null 2>&1
        fi
        if [ -e "/root/.acme.sh/${full_domain}_ecc/fullchain.cer" ]; then
            sudo ~/.acme.sh/acme.sh --installcert -d $full_domain --fullchainpath /etc/tls/$full_domain.crt --keypath /etc/tls/$full_domain.key > /dev/null 2>&1
        fi
    fi
    for ((i=0; i<"${#full_domain[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${full_domain[i]}_ecc/fullchain.cer" ]; then
            :
        else
            sudo rm -f "/etc/tls/${full_domain[i]}.key" "/etc/tls/${full_domain[i]}.crt" > /dev/null 2>&1
        fi
    done
    for ((i=0; i<"${#full_domain[@]}"; i++)); do
        cert_path="/root/.acme.sh/${full_domain[i]}_ecc/fullchain.cer"
        nginx_cert_path="/etc/nginx/cert"
        cert_path="$nginx_cert_path/$domain.crt"
        key_path="$nginx_cert_path/$domain.key"
        if [ -e "/root/.acme.sh/${full_domain[i]}_ecc/fullchain.cer" ]; then
            echo -e "\e[1;32m$full_domain TLS证书申请成功。\e[0m"
        else
            echo -e "\e[1;91m$full_domain TLS证书申请失败，尝试为Nginx申请自签名证书\e[0m"
            sudo mkdir -p "$nginx_cert_path"
            echo "\e[1;32m生成 $domain 自签名证书\e[0m"
            
            openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout "$key_path" -out "$cert_path" -subj "/CN=$domain"
            chmod 777 "$cert_path"
            chmod 777 "$key_path"
            echo -e "\e[1;91m生成 $domain 自签名证书生成完毕\e[0m"
            
            echo -e "\e[1;93m正在配置Nginx使用自签证书相关内容 \e[0m"
            rm -rf "$nginx_config_file" nginx.conf
            wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
            mv nginx.conf "$nginx_config_file"
            sed -i "s/yourdomain\.com/$domain/g" "$nginx_config_file"
            rm -rf $nginx_index_file default.conf
            wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
            mv default.conf "$nginx_index_file"
            
            rm -rf $xray_config_filen config.conf
            wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/config.json > /dev/null 2>&1
            mv config.json $xray_config_file -f
            
            rm -rf /etc/tls/domain.tw.key
            rm -rf /etc/tls/domain.tw.crt 
            rm -rf /etc/tls/domain2.tw.key
            rm -rf /etc/tls/domain2.tw.crt
            cp $key_path /etc/tls/domain.tw.key
            cp $cert_path /etc/tls/domain.tw.crt
            cp $key_path /etc/tls/domain2.tw.key
            cp $cert_path /etc/tls/domain2.tw.crt
            
            systemctl stop nginx xray > /dev/null 2>&1
            systemctl start nginx xray > /dev/null 2>&1
            echo -e "\e[1;32mNginx配置已更新，使用自签名证书\e[0m"
            
            sudo ~/.acme.sh/acme.sh --issue -d $full_domain -w /var/www/letsencrypt > /dev/null 2>&1
        fi
        if [ -e "/root/.acme.sh/${full_domain[i]}_ecc/fullchain.cer" ]; then
            sudo ~/.acme.sh/acme.sh --installcert -d $full_domain --fullchainpath /etc/tls/$full_domain.crt --keypath /etc/tls/$full_domain.key > /dev/null 2>&1
        fi
    done
    systemctl start nginx > /dev/null 2>&1
    echo -e "\e[1;31m启动Nginx成功\e[0m" 
    [ ${#unique_domains_new[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        echo -e "尝试通过 Nginx 申请证书的域名: ${unique_domains_new[i]}"
        if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
            echo -e "\e[1;32m * 当前域名 ${unique_domains_new[i]} 已存在TLS证书  \e[0m"
            else
            sudo ~/.acme.sh/acme.sh --issue -d ${unique_domains_new[i]} -w /var/www/letsencrypt > /dev/null 2>&1
        fi
            sudo ~/.acme.sh/acme.sh --installcert -d ${unique_domains_new[i]}  --fullchainpath /etc/tls/${unique_domains_new[i]}.crt  --keypath /etc/tls/${unique_domains_new[i]}.key > /dev/null 2>&1
    done
    rm -rf /etc/tls/domain.tw.key
    rm -rf /etc/tls/domain.tw.crt
    rm -rf /etc/tls/domain2.tw.key
    rm -rf /etc/tls/domain2.tw.crt
    [ ${#unique_domains_new[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
    for ((i=0; i<"${#unique_domains_new[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${unique_domains_new[i]}_ecc/fullchain.cer" ]; then
            :
        else
            sudo rm -f "/etc/tls/${unique_domains_new[i]}.key" "/etc/tls/${unique_domains_new[i]}.crt" > /dev/null 2>&1
        fi
    done
}
singbox_domain_set() {
 
    files_without_extension=($(find "/etc/tls" -type f \( -name "*.crt" -o -name "*.key" \) -exec basename {} \; | sed -E 's/\.(crt|key)//' | awk '!seen[$0]++'))
    echo -e "\e[1;32m当前存在多个有效域名TLS证书,请为Sing-Box指定一个域名:\e[0m"
    for i in "${!files_without_extension[@]}"; do
        if openssl x509 -in "/etc/tls/${files_without_extension[i]}.crt" -noout -dates &>/dev/null; then
            start_date=$(openssl x509 -in "/etc/tls/${files_without_extension[i]}.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
            end_date=$(openssl x509 -in "/etc/tls/${files_without_extension[i]}.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
            if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                printf "%-2s %-20s - 证书有效期: %s 至 %s\n" "$((i+1)))" "${files_without_extension[i]}" "$start_date" "$end_date"
            else
                echo "日期解析失败: ${files_without_extension[i]}" >&2
            fi
        else
            echo "无法读取证书或证书无效: ${files_without_extension[i]}" >&2
        fi
    done
    while true; do
        read -p $'\e[1;33m请输入域名序号: \e[0m' selected_number
        if [[ "$selected_number" =~ ^[0-9]+$ ]] && [ "$selected_number" -ge 1 ] && [ "$selected_number" -le "${#files_without_extension[@]}" ]; then
            selected_file=${files_without_extension[$((selected_number-1))]}
            echo  -e "\e[1;32m 您选择了域名: $selected_file\e[0m"
            break  # 用户输入正确，退出循环
        else
            echo -e "\e[0;91m无效的输入，请输入有效的数字.\e[0m"
        fi
    done
    full_domain=$selected_file
    sb_sn=($(grep -oP '"server_name": "\K[^"]+' "$box_config_file"))
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
            for ((j = 0; j < 88; j++)); do echo -n -e "="; done; echo -e "\n"
            echo -e "  \e[91m已在Sing-Box配置文件中的域名:\e[0m"
            printf "%s\n" "   ${sbsn_new[@]}"
            for ((j = 0; j < 88; j++)); do echo -n -e "-"; done; echo -e "\n"
            sed -i "s/$sn/$full_domain/g" "$box_config_file"
            echo -e " \e[92m已完成Sing-Box的Server_Name更新\e[0m"
            sed -i '/"certificate_path"/d' "$box_config_file"
            sed -i "/\"key_path\"/i \\\t\"certificate_path\": \"/etc/tls/$full_domain.crt\"," "$box_config_file"
            sed -i '/"key_path"/d' "$box_config_file"
            sed -i "/\"certificate_path\"/a \\\t\"key_path\": \"/etc/tls/$full_domain.key\"" "$box_config_file"
            echo -e " \e[92m已完成Sing-Box证书路径更新\e[0m"
            for ((j = 0; j < 88; j++)); do echo -n -e "-"; done; echo -e "\n"
            sudo ~/.acme.sh/acme.sh --register-account -m admin@$full_domain > /dev/null 2>&1
            sudo ~/.acme.sh/acme.sh --issue -d $full_domain --standalone --keylength ec-256  > /dev/null 2>&1
            sudo ~/.acme.sh/acme.sh --installcert -d $full_domain  --fullchainpath /etc/tls/$full_domain.crt  --keypath /etc/tls/$full_domain.key > /dev/null 2>&1
        else
            echo -e "\n  \e[92mSing-Box证书和域名配置正确，无需操作\n\e[0m"
        fi
    done
    sudo mkdir -p /etc/hysteria
    rm -rf /etc/hysteria/*.*
    cert_path="/etc/hysteria/bing.com.crt"
    key_path="/etc/hysteria/bing.com.key"
    openssl ecparam -genkey -name prime256v1 -out "$key_path"
    openssl req -new -x509 -days 36500 -key "$key_path" -out "$cert_path" -subj "/CN=www.bing.com"
    chmod 777 "$cert_path"
    chmod 777 "$key_path"
    awk 'BEGIN {found=0}
        /"ignore_client_bandwidth": false,/ { found=1; print $0; next }
        found && /"key_path": ".*\.key"/ {
            print "      \"masquerade\": \"https://www.bing.com\",";
            print "      \"tls\": {";
            print "        \"enabled\": true,";
            print "        \"server_name\": \"www.bing.com\",";
            print "        \"alpn\": [";
            print "          \"h3\"";
            print "        ],";
            print "        \"certificate_path\": \"/etc/hysteria/bing.com.crt\",";
            print "        \"key_path\": \"/etc/hysteria/bing.com.key\"";
            found=0;
            next;
        }
        !found {print $0}
        ' "$box_config_file" > $box_config_file.new
    mv $box_config_file.new $box_config_file
    sed -i "s/www.bing.com/$full_domain/g" "$box_config_file"
    sed -i "s#https://$full_domain#https://www.bing.com#g" "$box_config_file"
}
xray_domain_set() {
    json_file="/usr/local/etc/xray/xray_domain.json"
    certname=($(ls -1 /etc/tls | sed 's/\(.*\)\..*/\1/' | sort -u))
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
    start_line=$((last_line - (certificate_count - cert_count-1)))
    delete_lines=$((certificate_count - cert_count + 1))
    sed -i "${start_line},${last_line}d" "$xray_config_file"
    sudo systemctl restart xray
}
xray_domain_update(){
    json_file="/usr/local/etc/xray/xray_domain_updata.json"
    certname=($(ls -1 /etc/tls | sed 's/\(.*\)\..*/\1/' | sort -u))
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
    start_line=$((last_line - (certificate_count - cert_count-1)))
    delete_lines=$((certificate_count - cert_count + 1))
    sed -i "${start_line},${last_line}d" "$xray_config_file"
    sudo systemctl restart xray > /dev/null 2>&1
    sudo systemctl restart nginx > /dev/null 2>&1
}
nginx_domain_set(){
    unique_domains_nginx+=("*.$matched_domain")
    declare -A unique_domains_nginx_map
    
    for domain in "${unique_domains_nginx[@]}"; do
        unique_domains_nginx_map["$domain"]=1
    done
    unique_domains_nginx=("${!unique_domains_nginx_map[@]}")
    rm -rf $nginx_config_file nginx.conf
    
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/nginx.conf > /dev/null 2>&1
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i "/$domain/d" nginx.conf
    done
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" nginx.conf
    done
    sed -i "/yourdomain.com/d" nginx.conf
    mv nginx.conf $nginx_config_file
    rm -rf $nginx_index_file default.conf
    
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/default.conf > /dev/null 2>&1
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i "/$domain/d" default.conf
    done
    for domain in "${unique_domains_nginx[@]}"; do
        sed -i -e "/$server_name yourdomain.com/a\\
        server_name $domain;" default.conf
    done
    sed -i "/yourdomain.com/d" default.conf
    mv default.conf $nginx_index_file
    
    sudo systemctl restart nginx xray sing-box
}
cert_names(){
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
    echo -e "\e[1;32m已保存在/etc/tls的 TLS 域名证书:\e[0m"
    for element in "${unique_array[@]}"; do
        echo "  - $element"
    done
    cd "$original_directory" || exit
    original_directory=$(pwd)
    cd /etc/hysteria || exit
    file_array=()
    for file in *; do
        if [ -f "$file" ]; then
            file_name=$(basename "$file")
            file_array+=("${file_name%.*}")
        fi
    done
    unique_array=($(echo "${file_array[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    echo -e "\e[1;31m已保存的自签名证书:\e[0m"
    for element in "${unique_array[@]}"; do
        echo "  - $element"
    done
    cd "$original_directory" || exit
}
domain_set(){
    clear
    config_files
    domain_input
    cert_names
    nginx_domain_set
    xray_domain_set
    singbox_domain_set
    xray_domain_update
    display_pause_info
}
show_user_info(){
    clear
    config_files
    singbox_user_info
    xray_user_info
    display_pause_info
}
show_setting_info(){
    clear
    config_files
    show_singbox_setting
    show_xray_setting
    display_pause_info
}
show_xray_info(){
    clear
    xray_config_files
    show_xray_setting
    display_pause_info
}
show_singbox_info(){
    clear
    singbox_config_files
    show_singbox_setting
        for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    display_pause_info
}
show_status(){
    clear
    show_all_status
    display_pause_info
}
show_all_status(){
    reset_color='\e[0m'
    dark_gray='\e[90m'
    light_gray='\e[37m'
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}="
    done
    echo -e "${reset_color}"
    display_status() {
        local service_name="$1"
        local service_status=$(systemctl status "$service_name.service" | grep "Active:")
        if [[ $service_status == *"active (running)"* ]]; then
            printf "\e[1;32m%s\e[0m" " $service_name 正常运行"
        else
            printf "\e[1;91m%s\e[0m" " $service_name 启动失败，请自查！可尝试恢复相关配置文件"
        fi
    }
    display_status "xray"
    echo -n -e "·"
    display_status "sing-box"
    echo -n -e "·"
    display_status "nginx"
    echo -e -n "\n"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}="
    done
    echo -e "${reset_color}\n"
}
reset_xray_singbox(){
    echo -e "\e[1;91m注意：本操作具有一定风险，请再次输入 Y 确认，输入其他字符或回车退出。\e[0m"
    
    read -p "确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m操作已取消。\e[0m"
        return
    fi
    config_files
    reset_xray_files
    reset_nginx_files
    reset_singbox_files
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m=";
    done
    echo -e "\e[0m"
    printf "\e[1;32m%-60s\e[0m\n" "           ----- Xray 和 Sing-Box的配置文件已重置 -----"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[90m·";
    done
    echo -e "\e[0m"
    echo -e "\e[1;91m注意：\e[0m\e[1;32m操作已完成。\e[0m\e[1;93m请重新运行主菜单中的 \e[0m\e[1;32m域名检查/设置/重新生成Let's证书 \e[0m\e[1;93m选项\e[0m"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m-";
    done
    echo -e "\e[0m"
    display_pause_info
}
reset_xray(){
    echo -e "\e[1;91m注意：本操作具有一定风险，请再次输入 Y 确认，输入其他字符或回车退出。\e[0m"
    
    read -p "确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m操作已取消。\e[0m"
        return
    fi
    xray_config_files
    nginx_config_files
    reset_xray_files
    reset_nginx_files
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m=";
    done
    echo -e "\e[0m"
    printf "\e[1;32m%-60s\e[0m\n" "           ----- xRay 的配置文件已重置 -----"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[90m·";
    done
    echo -e "\e[0m"
    echo -e "\e[1;91m注意：\e[0m\e[1;32m操作已完成。\e[0m\e[1;93m请重新运行主菜单中的 \e[0m\e[1;32m域名检查/设置/重新生成Let's证书 \e[0m\e[1;93m选项\e[0m"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m-";
    done
    echo -e "\e[0m"
    display_pause_info
}
reset_nginx(){
    echo -e "\e[1;91m注意：本操作具有一定风险，请再次输入 Y 确认，输入其他字符或回车退出。\e[0m"
    
    read -p "确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m操作已取消。\e[0m"
        return
    fi
    nginx_config_files
    reset_nginx_files
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m=";
    done
    echo -e "\e[0m"
    printf "\e[1;32m%-60s\e[0m\n" "           ----- Nginx 的配置文件已重置 -----"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[90m·";
    done
    echo -e "\e[0m"
    echo -e "\e[1;91m注意：\e[0m\e[1;32m操作已完成。\e[0m\e[1;93m请重新运行主菜单中的 \e[0m\e[1;32m域名检查/设置/重新生成Let's证书 \e[0m\e[1;93m选项\e[0m"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m-";
    done
    echo -e "\e[0m"
    display_pause_info
}
reset_singbox(){
    echo -e "\e[1;91m注意：本操作具有一定风险，请再次输入 Y 确认，输入其他字符或回车退出。\e[0m"
    
    read -p "确认重置操作请输入 Y: " user_confirmation
    if [ "${user_confirmation,,}" != "y" ]; then
        echo -e "\e[1;93m操作已取消。\e[0m"
        return
    fi
    singbox_config_files
    reset_singbox_files
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m=";
    done
    echo -e "\e[0m"
    printf "\e[1;32m%-60s\e[0m\n" "           ----- Sing-Box 的配置文件已重置 -----"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[90m·";
    done
    echo -e "\e[0m"
    echo -e "\e[1;91m注意：\e[0m\e[1;32m操作已完成。\e[0m\e[1;93m请重新运行主菜单中的 \e[0m\e[1;32m域名检查/设置/重新生成Let's证书 \e[0m\e[1;93m选项\e[0m"
    for ((j = 0; j < $path_count; j++)); do
        echo -n -e "\e[93m-";
    done
    echo -e "\e[0m"
    display_pause_info
}
modify_singbox_path(){
    clear
    config_files
    tags=() path_t=()
    path_count=60 reset_color='\e[0m' light_gray='\e[37m'
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag": "\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-20s %-42s\e[0m\n" "No." "Type" "Path"
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        path_t+=($(echo "$content" | grep -oP '"path": "\K[^\"]+' | tr -s '\n' | grep -v '^$'))
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
    echo -e "\e[1;93m请输入一个前缀 (只允许包含英文字母和数字):\e[0m"
    read -r -e user_prefix
    while [[ ! "$user_prefix" =~ ^[a-zA-Z0-9]+$ ]]; do
        echo "输入无效，请只输入英文字母和数字。"
        read -r -e user_prefix
    done
    echo -e "输入的前缀是: \e[1;91m${user_prefix}\e[0m"
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
    config_files
    tags=() path_t=()
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"tag": "\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol": "\K[^"]+'))
    path_t=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"path": "\K[^\"]+' | head -n 1))
    for ((i = 0; i < xpath_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%32s""当前 xRay Path 清单\n"
    for ((i = 0; i < xpath_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-22s %-18s %-20s  %-28s %-20s\e[0m\n" "No." "Name"  "Protocol" "Path"
    for ((i = 0; i < xpath_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
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
        path_t=($(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n 1))
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
    for ((i = 0; i < xpath_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"; 
    for ((i = 0; i < ${#all_path_t[@]}; i++)); do
        all_path_t[i]="${all_path_t[i]//\//}"
    done
    common_prefix=$(printf "%s\n" "${all_path_t[@]}" | awk -F "" 'NR==1{p=$0; next} {p=substr(p, 1, length <= length($0) ? length : length($0)); for(i=1;i<=length && substr($0,i,1)==substr(p,i,1);i++); p=substr(p, 1, i-1)} END{print p}')
    if [ -n "$common_prefix" ]; then
        echo -e "当前前缀: \e[1;32m${common_prefix}\e[0m"
    else
        echo "No Common Prefix Found"
    fi
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "\e[1;93m请输入一个前缀 (只允许包含英文字母和数字):\e[0m"
    read -r -e user_prefixaaaa
    while [[ ! "$user_prefix" =~ ^[a-zA-Z0-9]+$ ]]; do
        echo "输入无效，请只输入英文字母和数字。"
        read -r -e user_prefix
    done
    echo -e "输入的前缀是: \e[1;91m${user_prefix}\e[0m"
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
    printf "\e[1;91m%-3s %-22s %-18s %-20s  %-28s %-20s\e[0m\n" "No." "Name"  "Protocol" "Path"
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
        path_t=($(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n 1))
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
    restart_xray_info
    display_pause_info
}
restart_all(){
    clear
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
    sudo systemctl start sing-box
    sudo systemctl restart sing-box
    sudo systemctl status sing-box
    display_pause_info
}
restart_xray_info(){
    clear
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
        local service_status=$(systemctl status "$service_name.service" | grep "Active:")
        if [[ $service_status == *"active (running)"* ]]; then
            printf "\e[1;32m%s\e[0m" " $service_name 正常运行"
        else
            printf "\e[1;91m%s\e[0m" " $service_name 启动失败，请自查！可尝试恢复相关配置文件"
        fi
    }
    display_status "xray"
    echo -n -e "·"
    display_status "nginx"
    echo -e -n "\n"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}."
    done
    echo -e "${reset_color}\n"
}
restart_singbox_info(){
    clear
    sudo systemctl stop sing-box
    sudo systemctl start sing-box
    sudo systemctl restart sing-box
    color_set
    display_status() {
        local service_name="$1"
        local service_status=$(systemctl status "$service_name.service" | grep "Active:")
        if [[ $service_status == *"active (running)"* ]]; then
            printf "\e[1;32m%s\e[0m" " $service_name 正常运行"
        else
            printf "\e[1;91m%s\e[0m" " $service_name 启动失败，请自查！可尝试恢复相关配置文件"
        fi
    }
    display_status "sing-box"
    echo -e -n "\n"
    for ((i = 0; i < repeat_count; i++)); do
        echo -n -e "${light_gray}."
    done
    echo -e "${reset_color}\n"
}
config_files(){
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*sing-box/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            box_config_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 Sing-Box 的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    box_config_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m Sing-Box 配置文件路径为: \e[0m\e[93m$box_config_file\e[0m"
    else
        box_config_file="/etc/sing-box/config.json"
    fi
    config_files=$(find / -type f -path "*xray/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            xray_config_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 xRay 的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    xray_config_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m xRay 配置文件路径为: \e[0m\e[93m$xray_config_file\e[0m"
    else
        xray_config_file="/usr/local/etc/xray/config.json"
    fi
    config_files=$(find / -type f -path "*nginx/nginx.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            nginx_config_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 Nginx 网站的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    nginx_config_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的nginx.conf\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m Nginx 配置文件路径为: \e[0m\e[93m$nginx_config_file\e[0m"
    else
        nginx_config_file="/etc/nginx/nginx.conf"
    fi
    config_files=$(find / -type f -path "*conf.d/default.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            nginx_index_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 Nginx 网站的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    nginx_index_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的default.conf\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m Nginx 网站配置文件路径为: \e[0m\e[93m$nginx_index_file\e[0m"
    else
        nginx_index_file="/etc/nginx/conf.d/default.conf"
    fi
}
xray_config_files(){
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*xray/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            xray_config_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 xRay 的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    xray_config_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m xRay 配置文件路径为: \e[0m\e[93m$xray_config_file\e[0m"
    else
        xray_config_file="/usr/local/etc/xray/config.json"
    fi
}
nginx_config_files(){
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*nginx/nginx.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            nginx_config_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 Nginx 网站的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    nginx_config_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的nginx.conf\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m Nginx 配置文件路径为: \e[0m\e[93m$nginx_config_file\e[0m"
    else
        nginx_config_file="/etc/nginx/nginx.conf"
    fi
    config_files=$(find / -type f -path "*conf.d/default.conf" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            nginx_index_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 Nginx 网站的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    nginx_index_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的default.conf\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m Nginx 网站配置文件路径为: \e[0m\e[93m$nginx_index_file\e[0m"
    else
        nginx_index_file="/etc/nginx/conf.d/default.conf"
    fi
}
singbox_config_files(){
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    config_files=$(find / -type f -path "*sing-box/config.json" 2>/dev/null)
    if [ -n "$config_files" ]; then
        if [ $(echo "$config_files" | wc -l) -eq 1 ]; then
            box_config_file=$config_files
        else
            echo -e "\e[93m系统中存在多个 Sing-Box 的配置，请在以下配置文件中选择:\e[0m"
            options=($config_files)
            select choice in "${options[@]}"; do
                if [ -n "$choice" ]; then
                    echo "您选择了文件: $choice"
                    box_config_file=$choice
                    echo -e "\e[92m为了减少你的交互操作，请在本次操作完全结束后，删除\e[91m多余的config.json\e[92m文件\e[0m"
                    break
                else
                    echo "无效的选择，请重新选择。"
                fi
            done
        fi
        echo -e "\e[91m Sing-Box 配置文件路径为: \e[0m\e[93m$box_config_file\e[0m"
    else
        box_config_file="/etc/sing-box/config.json"
    fi
}
install_warp(){
   wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh d
}
dokodemo_door_ports(){
    clear
    xray_config_files
    singbox_config_files
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"protocol": "\K[^"]+'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$xray_config_file" | grep -oP '"port": \K[^,]+'))
    for i in "${!type[@]}"; do
        if [ "${type[i]}" == "dokodemo-door" ]; then
            ports_t=${ports[i]}
        fi
    done
    box_ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"listen_port": \K[^,]+'))
    echo -e "\e[1;91m不可用端口: 80 443 ${box_ports[*]}\e[0m"
    echo -e "\e[1;92m当前dokodemo-door端口号为: $ports_t\e[0m"
    while true; do
        read -re -p $'\e[93m请输入dokodemo-door的新端口号: \e[0m' new_port
        new_port=$(echo "$new_port" | sed 's/^0*//')
        if [[ ! "$new_port" =~ ^[0-9]+$ ]]; then
            echo "无效输入，请输入数字。"
        elif [ "$new_port" -eq 0 ]; then
            echo "无效端口。"
        elif [ "$new_port" -gt 65535 ]; then
            echo "超出端口范围。"
        elif [[ " ${box_ports[*]} " =~ " $new_port " || " ${ports[*]} " =~ " $new_port " || "$new_port" -eq 32000 ||  "$new_port" -eq 30000 || "$new_port" -eq 80 ]]; then
            echo "端口被占用，请重新修改。"
        else
            sed -i "s/\"port\": $ports_t/\"port\": $new_port/" "$xray_config_file"
            echo -e "\e[1;92m新的dokodemo-door端口号为: $new_port\e[0m"
            break
        fi
    done
    restart_xray_info
    display_pause_info
}
hysteria2_password(){
    clear
    singbox_config_files
    tags=() 
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag": "\K[^"]+' | sed 's/_in//'))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password": "\K[^\"]+' | head -n1)
        fi
    done
    echo -e "\e[1;91m当前Hysteria2的PassWord为： $password_t\e[0m"
    while true; do
        if [ "$current_tag" == "hysteria2" ]; then
            read -p "是否随机生成12位数密码？选择 Y/N: " random_password_choice
            if [ "$random_password_choice" == "Y" ] || [ "$random_password_choice" == "y" ]; then
                new_password=$(openssl rand -base64 12)
                break  
            elif [ "$random_password_choice" == "N" ] || [ "$random_password_choice" == "n" ]; then
                read -re -p $'\e[93m请输入 Hysteria2 的 Password，建议为 6-12 位: \e[0m' new_password
                if [ -z "$new_password" ]; then
                    echo -e "\n\e[93m当前输入为空，已为你自动生成12位密码: $new_password\e[0m"
                    new_password=$(openssl rand -base64 12)
                fi
                break  
            else
                echo -e "\e[1;91m无效的选择。请输入 Y 或 N。\e[0m"
                continue 
            fi
        fi
    done
    echo -e "\e[1;92m新的Hysteria2的PassWord为: $new_password\e[0m"
    sed -i "s|\"password\": \"$password_t\"|\"password\": \"$new_password\"|" "$box_config_file"
    restart_singbox_info
    display_pause_info
}
shadowsocks_password(){
    clear
    singbox_config_files
    tags=() 
    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$box_config_file" | grep -oP '"tag": "\K[^"]+' | sed 's/_in//'))
    for ((i = 0; i < path_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
        [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$box_config_file")
        if [ "$current_tag" == "shadowsocks" ] || [ "$current_tag" == "shadowsocks" ]; then
            password_t=$(echo "$content" | grep -oP '"password": "\K[^\"]+' | head -n1)
        fi
    done
    echo -e "\e[1;91m当前ShadowSocks的PassWord为： $password_t\e[0m"
    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} 
        if [ "$current_tag" == "shadowsocks" ] ; then
            while true; do
                read -p "是否随机生成12位数密码？选择 Y/N: " random_password_choice
                if [ "$random_password_choice" == "Y" ] || [ "$random_password_choice" == "y" ]; then
                    ss_password=$(openssl rand -base64 12)
                    break  
                elif [ "$random_password_choice" == "N" ] || [ "$random_password_choice" == "n" ]; then
                    read -re -p $'\e[93m请输入 Shadowsocks 的 Password，建议为 6-12 位: \e[0m' ss_password
                    if [ -z "$ss_password" ]; then
                        echo -e "\n\e[93m当前输入为空，已为你自动生成12位密码: $ss_password\e[0m"
                        ss_password=$(openssl rand -base64 12)
                    fi
                    break  
                else
                    echo -e "\e[1;91m无效的选择。请输入 Y 或 N。\e[0m"
                fi
            done
            break  
        fi
    done
    echo -e "\e[1;92m新的ShadowSocks的PassWord为: $ss_password\e[0m"
    sed -i "s|\"password\": \"$password_t\"|\"password\": \"$ss_password\"|" "$box_config_file"
    restart_singbox_info
    display_pause_info
}
install_all(){
    install_xRay_SingBox
    domain_set
}
xray_new_uuids() {
    array_assignment
    read -p $'\e[93m请输入要生成新和旧的UUID数量: \e[0m' count
    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
    done
    display_generated_uuids
    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    elif [ "$count" -ne 0 ]; then
        xray_config_files
        process_xray_new
        xray_user_info
        restart_xray_info
        display_pause_info
    fi
}
xray_new_manual_input_uuids() {
    array_assignment
    echo -e "\e[93m请输入新的xRay UUID，以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        new_uuid_array+=("$uuid")
    done
    if [ ${#new_uuid_array[@]} -eq 0 ]; then
        new_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空，已自动生成 1 枚UUID。\e[0m"
    fi
    display_generated_uuids
    xray_config_files
    process_xray_new
    xray_user_info
    restart_xray_info
    display_pause_info
}
xray_old_uuids() {
    array_assignment
    read -p $'\e[93m请输入要生成新和旧的UUID数量: \e[0m' count
    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
    done
    display_generated_uuids
    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    elif [ "$count" -ne 0 ]; then
        xray_config_files
        process_xray_new
        xray_user_info
        restart_xray_info
        display_pause_info
    fi
}
xray_old_manual_input_uuids() {
    array_assignment
    echo -e "\e[93m请输入新的xRay UUID，以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        old_uuid_array+=("$uuid")
    done
    if [ ${#old_uuid_array[@]} -eq 0 ]; then
        old_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空，已自动生成 1 枚UUID。\e[0m"
    fi
    display_generated_uuids
    xray_config_files
    process_xray_old
    xray_user_info
    restart_xray_info
    display_pause_info
}
singbox_uuids() {
    array_assignment
    read -p $'\e[93m请输入要生成新和旧的UUID数量: \e[0m' count
    for ((i=1; i<=$count; i++)); do
        box_uuid=$(uuidgen)
        box_uuid_array+=("$box_uuid")
    done
    display_generated_uuids
    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    elif [ "$count" -ne 0 ]; then
        singbox_config_files
        process_sing_box
        singbox_user_info
        restart_singbox_info
        display_pause_info
    fi
}
singbox_manual_input_uuids() {
    array_assignment
    echo -e "\e[93m请输入新的Sing-Box UUID，以空行结束\e[0m"
    while read -r uuid && [ -n "$uuid" ]; do
        box_uuid_array+=("$uuid")
    done
    if [ ${#box_uuid_array[@]} -eq 0 ]; then
        box_uuid_array+=("$(uuidgen)")
        echo -e "\e[1;32m输入为空，已自动生成 1 枚UUID。\e[0m"
    fi
    display_generated_uuids
    singbox_config_files
    process_sing_box
    singbox_user_info
    restart_singbox_info
    display_pause_info
}
show_xray_user_info(){
    clear
    xray_config_files
    xray_user_info
    display_pause_info
}
show_singbox_user_info(){
    clear
    singbox_config_files
    singbox_user_info
    display_pause_info
}
show_domain_tls_info(){
    clear
    files_without_extension=($(find "/etc/tls" -type f \( -name "*.crt" -o -name "*.key" \) -exec basename {} \; | sed -E 's/\.(crt|key)//' | awk '!seen[$0]++'))
    echo -e "\e[1;32m当前已保存的域名TLS证书及有效期\e[0m"
    for i in "${!files_without_extension[@]}"; do
        if openssl x509 -in "/etc/tls/${files_without_extension[i]}.crt" -noout -dates &>/dev/null; then
            start_date=$(openssl x509 -in "/etc/tls/${files_without_extension[i]}.crt" -noout -dates | awk '/notBefore/ {gsub(/notBefore=/, "", $0); print $0}' 2>/dev/null)
            end_date=$(openssl x509 -in "/etc/tls/${files_without_extension[i]}.crt" -noout -dates | awk '/notAfter/ {gsub(/notAfter=/, "", $0); print $0}' 2>/dev/null)
            if [ -n "$start_date" ] && [ -n "$end_date" ]; then
                start_date=$(date -d "$start_date" '+%Y-%m-%d' 2>/dev/null)
                end_date=$(date -d "$end_date" '+%Y-%m-%d' 2>/dev/null)
                printf "%-2s %-20s - 证书有效期: %s 至 %s\n" "$((i+1)))" "${files_without_extension[i]}" "$start_date" "$end_date"
            else
                echo "日期解析失败: ${files_without_extension[i]}" >&2
            fi
        else
            echo "无法读取证书或证书无效: ${files_without_extension[i]}" >&2
        fi
    done
    display_pause_info
}
force_update_domain(){
    clear
    systemctl start nginx > /dev/null 2>&1
    echo -e "\e[1;31m启动Nginx成功\e[0m" 
    domain_tls=($(find "/etc/tls" -type f \( -name "*.crt" -o -name "*.key" \) -exec basename {} \; | sed -E 's/\.(crt|key)//' | awk '!seen[$0]++'))
    [ ${#domain_tls[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
    for ((i=0; i<"${#domain_tls[@]}"; i++)); do
        echo -e "尝试通过 Nginx 申请证书的域名: ${domain_tls[i]}"
        sudo ~/.acme.sh/acme.sh --issue -d ${domain_tls[i]} -w /var/www/letsencrypt --force > /dev/null 2>&1
        sudo ~/.acme.sh/acme.sh --installcert -d ${domain_tls[i]}  --fullchainpath /etc/tls/${domain_tls[i]}.crt  --keypath /etc/tls/${domain_tls[i]}.key  > /dev/null 2>&1
    done
    [ ${#domain_tls[@]} -gt 0 ] && printf '%.s-' {1..88} && echo
    for ((i=0; i<"${#domain_tls[@]}"; i++)); do
        if [ -e "/root/.acme.sh/${domain_tls[i]}_ecc/fullchain.cer" ]; then
            :
        else
            sudo rm -f "/etc/tls/${domain_tls[i]}.key" "/etc/tls/${domain_tls[i]}.crt" > /dev/null 2>&1
        fi
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
        singbox_domain_set
        reset_xray
        reset_nginx
        reset_singbox
    )
    if [ $choice -ge 1 ] && [ $choice -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择，请重新输入。"
    fi
}
set_manage() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 配置管理"
        MENU_TEXT2="Michael Mao"
        equals1=$(( ($menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( ($menu_line - ${#MENU_TEXT2} - 2) / 2 ))
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
            "强制更新当前域名TLS证书[通过Nginx]"
            "重启xRay/Nginx"
            "重启Sing-box"
            "修改xRay的新、旧Path"
            "修改Sing-Box的Path"
            "修改xRay中Dokodemo-Door端口"
            "修改Sing-Box中Hysteria2密码"
            "修改Sing-Box中ShadowSocks密码"
            "修改Sing-Box的域名/证书（仅适用于多域名/证书）"
            "重置xRay配置文件"
            "重置Nginx配置文件"
            "重置Sing-box配置文件"
            "返回主菜单"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < $menu_line; j++)); do
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
        equals_bottom=$(( ($menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < $menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 返回主菜单）: " choice
        case $choice in
            [1-9]|1[0-9])
                set_manage_choice $choice;;
            0)
                return;;
            *)
                echo "无效选择，请重新输入。";;
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
        reset_xray
        reset_nginx
        reset_singbox
    )
    if [ $choice -ge 1 ] && [ $choice -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择，请重新输入。"
    fi
}
user_manage() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 用户管理"
        MENU_TEXT2="Michael Mao"
        equals1=$(( ($menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( ($menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        output_line1=$(printf "=%.0s" $(seq 1 $equals1))
        output_line2=$(printf " %.0s" $(seq 1 $equals2))
        output1="$output_line1 $MENU_TEXT1 $output_line1"
        output2="$output_line2 $MENU_TEXT2"
        clear
        echo -e "\n\e[93m$output1\e[0m"
        echo -e "\e[90m$output2\e[0m"
        menu_items=(
            "自动生成xRay新、旧UUID和Sing-box的UUID并修改其配置"
            "自动生成xRay新UUID和Sing-box，手动输入xRay旧UUID"
            "手动输入xRay新、旧UUID和Sing-box的UUID"
            "将UUID转换为ShadowSocks认可的BASE64格式"
            "自动生成xRay新用户的 UUID"
            "手动输入xRay新用户的 UUID"
            "自动生成xRay旧用户的 UUID"
            "手动输入xRay旧用户的 UUID"
            "自动生成Sing-Box用户的 UUID"
            "手动输入Sing-Box用户的 UUID"
            "查看xRay所有用户UUID信息"
            "查看Sing-Box所有用户UUID信息"
            "重启xRay/Nginx"
            "重启Sing-box"
            "重置xRay配置文件"
            "重置Nginx配置文件"
            "重置Sing-box配置文件"
            "返回主菜单"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < $menu_line; j++)); do
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
        equals_bottom=$(( ($menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < $menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 返回主菜单）: " choice
        case $choice in
            [1-9]|1[0-9])
                user_manage_choice $choice;;
            0)
                return;;
            *)
                echo "无效选择，请重新输入。";;
        esac
    done
}
main_menu_choice() {
    choice=$1
    actions=(
        user_manage
        set_manage
        install_xRay_SingBox
        domain_set
        reset_xray_singbox
        show_setting_info
        show_user_info
        install_warp
        restart_all
        show_status
        install_all
    )
    if [ $choice -ge 1 ] && [ $choice -le ${#actions[@]} ]; then
        ${actions[$choice - 1]}
    else
        echo "无效选择，请重新输入。"
    fi
}
main_menu() {
    color_set
    while true; do
        menu_line=66
        MENU_TEXT1="xRay/Sing-box 批量管理"
        MENU_TEXT2="Michael Mao"
        MENU_TEXT3="仅适用于 Debian 12 的全新机"
        equals1=$(( ($menu_line - ${#MENU_TEXT1} - 6) / 2 ))
        equals2=$(( ($menu_line - ${#MENU_TEXT2} - 2) / 2 ))
        equals3=$(( ($menu_line - ${#MENU_TEXT3} - 10) / 2 ))
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
            "xRay/Sing-box 配置管理"
            "安装Nginx/Sing-box/xRay及相关依赖包"
            "域名检查/设置/重新生成Let's证书\e[0;33m[可处理开云朵的域名]\e[0m"
            "重置xRay/Sing-box/Nginx配置文件"
            "查看Sing-box/xRay配置信息"
            "查看xRay/Sing-box用户信息"
            "为IPv4的VPS安装Warp双栈\e[90m[作者:fscarmen]\e[0m"
            "重启xRay/Sing-box/Nginx"
            "显示xRay/Sing-box/Nginx运行状态"
            "\e[93m一键安装所有配置 \e[0m[可手动选3，再选4]"
            "退出"
        )
        for ((i = 0; i < ${#menu_items[@]}; i++)); do
            item=${menu_items[$i]}
            for ((j = 0; j < $menu_line; j++)); do
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
        bottom_text="www.nruan.com"
        equals_bottom=$(( ($menu_line - ${#bottom_text} - 2) / 2 ))
        output_bottom=$(printf " %.0s" $(seq 1 $equals_bottom))
        echo -e "\n\e[90m$output_bottom $bottom_text\e[0m"
        for ((j = 0; j < $menu_line; j++)); do
            echo -n -e "\e[93m="
        done
        echo -e "\e[0m"
        read -p "选择操作（1-$(( ${#menu_items[@]} - 1 )); 0 退出）: " choice
        case $choice in
            [1-9]|1[0-9])
                main_menu_choice $choice;;
            0)
                return;;
            *)
                echo "无效选择，请重新输入。";;
        esac
    done
}
main_menu
