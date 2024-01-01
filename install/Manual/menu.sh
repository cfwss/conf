#!/bin/bash
repeat_count=150
reset_color='\e[0m'
light_gray='\e[37m'
dark_gray='\e[90m'
half_repeat_count=$((repeat_count / 3))
new_uuid_array=()
old_uuid_array=()
box_uuid_array=()

generate_new_uuids() {
    read -p "请输入要生成新和旧的UUID数量: " count

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
    process_xray_new
    process_xray_old
    process_sing_box
    singbox_user_info
    xray_user_info
    xray_domain_set
    status_xray
    status_singbox
    status_nginx
    display_pause_info
    fi
}
generate_new_uuid_with_manual_old() {

    read -p "请输入要生成新的UUID数量: " count

    if [ "$count" -eq 0 ]; then
        echo "生成数量为0，退出菜单。"
        exit 0
    fi

    for ((i=1; i<=$count; i++)); do
        new_uuid=$(uuidgen)
        box_uuid=$(uuidgen)
        new_uuid_array+=("$new_uuid")
        box_uuid_array+=("$box_uuid")
    done

    echo -e "请输入xRay 旧的UUID，每行一个，以空行结束："
    while read -r uuid_manual && [ -n "$uuid_manual" ]; do
        old_uuid_array+=("$uuid_manual")
    done

    display_generated_uuids

    process_xray_new
    process_xray_old
    process_sing_box
    singbox_user_info
    xray_user_info
    xray_domain_set
    status_xray
    status_singbox
    status_nginx
    display_pause_info
}
manual_input_uuids() {
    echo "请输入新的xRayyUUID，以空行结束"
    while read -r uuid && [ -n "$uuid" ]; do
        new_uuid_array+=("$uuid")
    done

    echo "请输入旧的xRay UUID，以空行结束"
    while read -r uuid && [ -n "$uuid" ]; do
        old_uuid_array+=("$uuid")
    done

    echo "请输入新的Sing-Box UUID，以空行结束"
    while read -r uuid && [ -n "$uuid" ]; do
        box_uuid_array+=("$uuid")
    done

    display_generated_uuids

    process_xray_new
    process_xray_old
    process_sing_box
    singbox_user_info
    xray_user_info
    xray_domain_set
    status_xray
    status_singbox
    status_nginx
    display_pause_info
}
display_generated_uuids() {
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    printf "\e[1;32m%66s%s\e[0m\n" "" "已生成的新UUID清单"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    printf "%-3s %-50s %-3s %-50s %-3s %-45s %s\n" "No." "xRay New" "No."  "xRay Old" "No."  "Sing-Box"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    for ((i=1; i<=$count; i++)); do
        printf "%-3s %-50s %-3s %-50s %-3s %-50s %s\n" "$i." "${new_uuid_array[i - 1]}" "$i." "${old_uuid_array[i - 1]}" "$i." "${box_uuid_array[i - 1]}"
    done
}
display_pause_info() {
    read -n 1 -s -r -p "按任意键返回主菜单..."
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
reset_xray() {
    rm -rf /usr/local/etc/xray/config.json config.conf
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/config.json > /dev/null 2>&1
    mv config.json /usr/local/etc/xray/config.json -f
}
get_xray_tags() {
    config_file="/usr/local/etc/xray/config.json"
    new_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' | grep -iv "OLD" | grep -iv "api"))
    old_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' | grep -i "OLD"))
}
process_xray_new() {
    reset_xray
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
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
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
                    current_template=("$(echo "$json_template_shadowsocks" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                    tag_name+=("$current_template")
                    ;;
            esac
        done

        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            tag_array["$current_tag"]=$tag_name_str
            found=$(sed -n "/\"tag\": \"$tag_lowercase\"/I,/]/p" "$config_file")
            if [ -n "$found" ]; then
                sed -i "/\"tag\": \"$tag_lowercase\"/I,/]/ {
                    /\"clients\": \[/ {
                        N
                        a \        \"clients\": \[
                        r /dev/stdin
                        d
                    }
                }" "$config_file" <<< "$tag_name_str_escaped"
            fi
        fi
    done
    for ((i = 0; i < ${#unique_new_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_new_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        sed -i "/${unique_new_ids[$i]}/d; /$modified_base64_id/d" "$config_file"
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
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
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
                    current_template=("$(echo "$json_template_shadowsocks" | sed -e "s/method_character/$method_character/" -e "s/base64_uuid/${base64_uuid}/" -e "s/short_uuid/$short_uuid/" -e "s/tag_name/$tag_lowercase/"),")
                    tag_name+=("$current_template")
                    ;;
            esac
        done

        if [[ ${#tag_name[@]} -gt 0 ]]; then
            tag_name_str=$(printf '          %s\n' "${tag_name[@]}")
            tag_name_str="${tag_name_str%,}"
            tag_name_str_escaped=$(printf '%s\n' "$tag_name_str" | sed -e 's/[\/&]/\\&/g')
            tag_array["$current_tag"]=$tag_name_str
            found=$(sed -n "/\"tag\": \"$tag_lowercase\"/I,/]/p" "$config_file")
            if [ -n "$found" ]; then
                sed -i "/\"tag\": \"$tag_lowercase\"/I,/]/ {
                    /\"clients\": \[/ {
                        N
                        a \        \"clients\": \[
                        r /dev/stdin
                        d
                    }
                }" "$config_file" <<< "$tag_name_str_escaped"

            fi
        fi
    done
    for ((i = 0; i < ${#unique_old_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_old_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        sed -i "/${unique_old_ids[$i]}/d; /$modified_base64_id/d" "$config_file"
    done

}
process_sing_box() {
    config_file="/usr/local/etc/sing-box/config.json"
    box_tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' ))
    method_character="chacha20-ietf-poly1305"
    flow=xtls-rprx-vision
    box_ids=()
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
        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"password\"/p }" "$config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))
        for id in "${ids[@]}"; do
            if [[ ! " ${box_ids[@]} " =~ " $id " ]]; then
                box_ids+=("$id")
            fi
        done
    done
    unique_box_ids=($(echo "${box_ids[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
    json_template_trojan='{"name": "nruan", "password": "full_uuid"}'
    json_template_vmess='{"name": "nruan", "uuid": "full_uuid", "alterId": 0 }'
    json_template_vless='{"name": "nruan", "uuid": "full_uuid", "flow": "" }'
    json_template_tuic='{"name": "nruan", "uuid": "full_uuid", "password": "full_uuid" }'
    json_template_naive='{"username": "nruan", "password": "full_uuid" }'
    json_template_shadowsocks='{"name": "nruan", "password": "base64_uuid" }'

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
                    current_template=("$(echo "$json_template_tuic" | sed -e "s/full_uuid/${box_uuid_array[j]}/" -e "s/nruan/$short_uuid/"),")
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
            found=$(sed -n "/\"tag\": \"$tag_lowercase\"/I,/]/p" "$config_file")
            if [ -n "$found" ]; then
                sed -i "/\"tag\": \"$tag_lowercase\"/I,/]/ {
                    /\"users\": \[/ {
                        N
                        a \        \"users\": \[
                        r /dev/stdin
                        d
                    }
                }" "$config_file" <<< "$tag_name_str_escaped"

            fi
        fi
    done
    for ((i = 0; i < ${#unique_box_ids[@]}; i++)); do
        base64_encoded_id=$(echo -n "${unique_box_ids[$i]}" | base64)
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        sed -i "/${unique_box_ids[$i]}/d; /$modified_base64_id/d" "$config_file"
    done
}
xray_user_info(){

    get_xray_tags


    reset_color='\e[0m'
    dark_gray='\e[90m'
    light_gray='\e[37m'
    half_repeat_count=$((repeat_count / 3))

    all_ids=()
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "新用户信息 (左边是除ShadowSock之外的UUID)"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}+"; done; echo -e "${reset_color}"

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

        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))

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
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        printf "%-5s %-50s %s\n" "$((i+1))." "${unique_ids[$i]}" "$modified_base64_id"
        if [ $i -lt $(( ${#unique_ids[@]} - 1 )) ]; then
            for ((j = 0; j < repeat_count; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
        fi
    done
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"

    printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "旧用户信息 (左边是除ShadowSock之外的UUID)"
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

        ids=($(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ { /\"id\"/p }" "$config_file" | awk -F'"' '{print $4}' | awk '!a[$0]++'))

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
        modified_base64_id=$(echo -n "$base64_encoded_id" | tr -d '/+' | cut -c 1-22)
        printf "%-5s %-50s %s\n" "$((i+1))." "${unique_ids[$i]}" "$modified_base64_id"
        if [ $i -lt $(( ${#unique_ids[@]} - 1 )) ]; then
            for ((j = 0; j < repeat_count; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
        fi
    done

    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"

}
singbox_user_info(){
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
    repeat_count=150 reset_color='\e[0m' dark_gray='\e[90m' light_gray='\e[37m'
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
status_xray(){
    sudo systemctl stop xray
    sudo systemctl start xray
    status=$(systemctl status xray.service | grep "Active:")
    if [[ $status == *"active (running)"* ]]; then
        printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "        xRay 已重启并在正常运行"

    else
        printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" "        xRay 启动失败，请自查！"
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"

}
status_singbox(){
    sudo systemctl stop sing-box
    sudo systemctl start sing-box
    status=$(systemctl status sing-box.service | grep "Active:")
    if [[ $status == *"active (running)"* ]]; then
        printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "    Sing-Box 已重启并在正常运行"

    else
        printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" "    Sing-Box 启动失败，请自查！"
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"

}
status_nginx(){
    sudo systemctl stop nginx
    sudo systemctl start nginx
    status=$(systemctl status nginx.service | grep "Active:")
    if [[ $status == *"active (running)"* ]]; then
        printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "      Nginx 已重启并在正常运行"

    else
        printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" "      Nginx 启动失败，请自查！"
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"

}
show_singbox_setting() {
    config_file="/usr/local/etc/sing-box/config.json"
    tags=() type=() ports=()

    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' | sed 's/_in//'))
    type=($(echo "${tags[@]}" | sed 's/_in//g' | tr ' ' '\n'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"listen_port": \K[^,]+'))
    repeat_count=125 reset_color='\e[0m' dark_gray='\e[90m' light_gray='\e[37m'

    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}";
    printf "%50s""Sing-Box 配置清单\n"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done;echo -e "${reset_color}"
    printf "\e[1;32m%-3s %-12s %-6s %-20s %-6s %-15s %-28s %-20s\e[0m\n" "No." "Protocol" "Ports" "Domains or sni" "Type" "Path" "Password" "Method"
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"

    for i in "${!tags[@]}"; do
        current_tag=${tags[$i]} next_tag=${tags[$((i+1))]} line_cont=${tags[$((i+1))]}
    [ -z "$next_tag" ] && next_tag="outbounds"
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$config_file")
        path_t=$(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n1)
        type_t=$(echo "$content" | grep -oP '"type": "\K[^\"]+' | sed -n '2p')
        Domain_t=$(echo "$content" | grep -oP '"server_name": "\K[^\"]+' | head -n1)

    if [ "$current_tag" == "hysteria2" ] || [ "$current_tag" == "shadowsocks" ]; then
        password_t=$(echo "$content" | grep -oP '"password": "\K[^\"]+' | head -n1)
        method_t=$(echo "$content" | grep -oP '"method": "\K[^\"]+' | head -n1)
    else
        password_t=""
        method_t=""
    fi
    echo "$content" | grep -q '"transport"' && type2+="1" && [ -z "$type_t" ] && type_t=" " || type2+=" " && type_t=" "
    printf "%-3s %-12s %-6s %-20s %-6s %-15s %-28s %-20s\n" "$((i+1))." "${type[i]}" "${ports[i]}" "$Domain_t" "$type_t" "$path_t" "$password_t" "$method_t"
    [ -n "$line_cont" ] && for ((i = 0; i < repeat_count; i++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}" || echo

    done
}
show_xray_setting() {
    config_file="/usr/local/etc/xray/config.json"

    tags=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"tag": "\K[^"]+' ))
    type=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"protocol": "\K[^"]+'))
    ports=($(sed -n '/"inbounds"/,/outbounds/ p' "$config_file" | grep -oP '"port": \K[^,]+'))

    repeat_count=125 reset_color='\e[0m' dark_gray='\e[90m' light_gray='\e[37m'

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
        content=$(sed -n "/\"$current_tag\"/,/\"$next_tag\"/ p" "$config_file")
        path_t=$(echo "$content" | grep -oP '"path": "\K[^\"]+' | head -n1)
        method_t=$(echo "$content" | awk -F'"' '/"method":/{print $4}' | awk '!seen[$0]++')
        if [ "${type[i]}" != "dokodemo-door" ]; then
            ports[i]="443"
        fi
        if [[ "${tags[i]}" == *gRPC* ]]; then
            path_t=$(echo "$content" | awk -F'"' '/"serviceName":/{print $4}' | awk '!seen[$0]++')
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
    rm -rf /etc/nginx/conf.d/*.*
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root > /dev/null 2>&1
    # 安装XRay官方版本，使用User=root，这将覆盖现有服务文件中的User
    apt -y update
    apt -y install curl git build-essential libssl-dev libevent-dev zlib1g-dev gcc-mingw-w64 nginx > /dev/null 2>&1
    useradd nginx -s /sbin/nologin -M
    bash <(curl -fsSL https://sing-box.app/deb-install.sh)  > /dev/null 2>&1
    mkdir -p /usr/local/etc
    mkdir -p /usr/local/etc/sing-box/
    rm -rf /usr/local/etc/sing-box/config.json config.json
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/singbox_exp.json > /dev/null 2>&1
    mv singbox_exp.json /usr/local/etc/sing-box/config.json -f

    systemctl status nginx
    systemctl status xray
    systemctl status sing-box
    display_pause_info
}
domain_input(){
    echo "请输入你的域名，以空行结束（可以很多行，Excel可直接复制粘贴）"
    domains=()
    while read -r domain && [ -n "$domain" ]; do
        domains+=("$domain")
    done

    local_ip=$(curl -s ifconfig.me)
    matched_prefix=""
    matched_domain=""
    full_domain=""

    sudo rm -fr /etc/tls/*.*
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

}
singbox_domain_set() {
    config_file="/usr/local/etc/sing-box/config.json"
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
    
    bing_self

    ls /etc/tls  
    ls /etc/hysteria

}
xray_domain_set() {
    config_file="/usr/local/etc/xray/config.json"
    json_file="/usr/local/etc/xray/xray_domain.json"
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
    sudo systemctl restart xray 
    systemctl status xray
}
nginx_domain_set(){
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
}
bing_self() {
  cert_path="/etc/hysteria/hysteria.crt"
  key_path="/etc/hysteria/hysteria.key"
  config_file="/usr/local/etc/sing-box/config.json"
  sudo mkdir -p /etc/hysteria
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

  sb_sn=($(grep -oP '"server_name": "\K[^"]+' "$config_file"))
  sbsn_new=($(echo "${sb_sn[@]}" | tr ' ' '\n' | sort -u))

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
        print "        \"certificate_path\": \"/etc/hysteria/hysteria.crt\",";
        print "        \"key_path\": \"/etc/hysteria/hysteria.key\"";
        found=0;
        next;
     }
     !found {print $0}
    ' "$config_file" > /usr/local/etc/sing-box/config.json.new

  mv /usr/local/etc/sing-box/config.json.new /usr/local/etc/sing-box/config.json
  
  for sn in "${sbsn_new[@]}"; do
    matched=false
    for ((i=0; i<${#full_domain[@]}; i++)); do
        if [[ "${full_domain[$i]}" == *"$sn"* ]]; then
            matched=true
            break
        fi
    done
    if [ "$matched" = false ]; then
        sed -i "s/$sn/$full_domain/g" "$config_file"
    fi
  done

  sed -i "s#https://$full_domain#https://www.bing.com#g" "$config_file"
}
domain_set(){
    domain_input
    singbox_domain_set
    nginx_domain_set
    xray_domain_set
    display_pause_info
}
show_user_info(){
    clear
    singbox_user_info
    xray_user_info
    display_pause_info
}
show_setting_info(){
    clear
    show_singbox_setting
    show_xray_setting
    display_pause_info
}
show_status(){
    clear
    repeat_count=80
    reset_color='\e[0m'
    dark_gray='\e[90m'
    light_gray='\e[37m'
    half_repeat_count=$((repeat_count / 3))
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" " xRay/Sing-box/Nginx运行状态 "
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    status=$(systemctl status xray.service | grep "Active:")
    if [[ $status == *"active (running)"* ]]; then
        printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "      xRay 正常运行"
    else
        printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" "      xRay 启动失败，请自查！"
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    status=$(systemctl status sing-box.service | grep "Active:")
    if [[ $status == *"active (running)"* ]]; then
        printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "      Sing-box 正常运行"
    else
        printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" "      Sing-box 启动失败，请自查！"
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    status=$(systemctl status nginx.service | grep "Active:")
    if [[ $status == *"active (running)"* ]]; then
        printf "\e[1;32m%${half_repeat_count}s%s\e[0m\n" "" "      Nginx 正常运行"
    else
        printf "\e[1;91m%${half_repeat_count}s%s\e[0m\n" "" "      Nginx 启动失败，请自查！"
    fi
    for ((i = 0; i < repeat_count; i++)); do echo -n -e "${light_gray}="; done; echo -e "${reset_color}"
    display_pause_info
}
install_xRay() {
    clear
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
while true; do
    menu_line=60
    clear
    echo -e "\n\e[93m================== xRay/Sing-box 批量管理 ==================\e[0m\n"
    echo -e "\e[91m                仅适用于Debian 12的全新机\e[0m"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${light_gray}-"; done; echo -e "${reset_color}"
    echo -e "   1. 自动生成xRay新、旧UUID和Sing-box的UUID"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   2. 自动生成xRay新UUID和Sing-box，手动输入xRay旧UUID"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   3. 手动输入xRay新、旧UUID和Sing-box的UUID"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   4. 将UUID转换为SS认可的BASE64格式"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   5. 安装Nginx/Sing-box/xRay"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   6. 域名检查/设置/重新生成Let's证书"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   7. 显示Sing-box/xRay配置"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   8. 显示xRay/Sing-box用户信息"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   9. 显示xRay/Sing-box/Nginx运行状态"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "   0. 退出"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "${dark_gray}·"; done; echo -e "${reset_color}"
    echo -e "\e[90m                     www.nruan.com\e[0m"
    for ((j = 0; j < $menu_line; j++)); do echo -n -e "\e[93m="; done; echo -e "${reset_color}"
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
            install_xRay_SingBox
            ;;
        6)
            domain_set
            ;;
        7)
            show_setting_info
            ;;
        8)
            show_user_info
            ;;
        9)
            show_status
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
