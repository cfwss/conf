#!/bin/bash

# 创建新数组用于存储new_uuid和old_uuid
declare -a new_uuid_array
declare -a old_uuid_array

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
     
     # 初始化vless和vmess数组
     vless_tcp=() vmess_tcp=() trojan_tcp=() shadowsocks_tcp=() vless_ws=() vmess_ws=() trojan_ws=() shadowsocks_ws=() vless_gRPC=() vmess_gRPC=() trojan_gRPC=() shadowsocks_gRPC=() vless_OLD=() vmess_OLD=() trojan_OLD=() shadowsocks_OLD=()
     
     
     # 替换JSON字符串中的uuid字段
     json_template_vless_tcp='{"id":"full_uuid","email":"short_uuid-VLess_TCP","level":0}'
     json_template_vmess_tcp='{"id":"full_uuid","email":"short_uuid-VMess_TCP","level":0}'
     json_template_trojan_tcp='{"password":"full_uuid","email":"short_uuid-Trojan_TCP","level":0}'
     json_template_shadowsocks_tcp='{"method":"method_character","password":"base64_uuid","level":0}'
     
     for ((i=0; i<${#full_uuid_array[@]}; i++)); do
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
    exit 0

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

while true; do
    echo -e "\n===========格式化xRay用户信息===========\n"
    echo -e "   1. 自动生成新UUID和旧UUID\n"
    echo -e "   2. 自动生成新UUID，手动输入旧UUID\n"
    echo -e "   3. 手动输入新UUID和旧UUID\n"
    echo -e "   4. 将UUID转换为SS认可的BASE64格式\n"
    echo -e "   0. 退出\n"
    echo -e "========================================\n"
    read -p "选择操作（0-4）: " choice

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
        0)
            echo "退出菜单。"
            exit 0
            ;;
        *)
            echo "无效选择，请重新输入。"
            ;;
    esac
done
