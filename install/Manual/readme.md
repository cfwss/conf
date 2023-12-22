# 纯手动搭建

    先自行安装NGINX 1.23 及以上版本， XRAY 1.8.6 版本。 warp sock 用 40000 端口。

创建证书

curl  https://get.acme.sh | sh 

mkdir -p /etc/tls

sudo ~/.acme.sh/acme.sh --register-account -m my@example.com

sudo ~/.acme.sh/acme.sh --issue -d yourdomain.edu.tw --standalone -k ec-256 --force

sudo ~/.acme.sh/acme.sh --installcert -d yourdomain.edu.tw --key-file /etc/tls/edu.tw.key --fullchain-file /etc/tls/edu.tw.crt

# 建议使用CF的15年证书，需要TLS处开启  完全（FULL)。

删除，重建xray配置 （需要手动修改域名，和证书名称）

    rm -rf /usr/local/etc/xray/config.json

    vi /usr/local/etc/xray/config.json

删除，重建nginx配置 （不需要修改，直接用文档）

    rm -rf /etc/nginx/nginx.conf

    vi /etc/nginx/nginx.conf

删除，重建SNI配置 （需要修改server_name，可以带 星号）

    rm -rf /etc/nginx/conf.d/default.conf

    vi /etc/nginx/conf.d/default.conf

重启NG/XRAY

    sudo systemctl restart nginx xray

    sudo systemctl status nginx xray

# 客户端配置参考：

    vless://00000000-0000-0000-0000-000000000000@yourdomain.edu.tw:443?encryption=none&flow=xtls-rprx-vision&security=tls&sni=yourdomain.edu.tw&fp=chrome&type=tcp&headerType=none&host=yourdomain.edu.tw#VLESS_TLS

    vless://00000000-0000-0000-0000-000000000000@yourdomain.edu.tw:443?encryption=none&security=tls&sni=yourdomain.edu.tw&fp=chrome&type=ws&host=yourdomain.edu.tw&path=%2Fedutwws#VLESS_WS

    trojan://00000000-0000-0000-0000-000000000000@yourdomain.edu.tw:443?security=tls&sni=yourdomain.edu.tw&alpn=h2&fp=chrome&type=grpc&serviceName=edutwtrojangrpc&mode=gun#Trojan_gRPC
