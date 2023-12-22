创建证书

curl  https://get.acme.sh | sh 

mkdir -p /etc/tls

sudo ~/.acme.sh/acme.sh --register-account -m my@example.com

sudo ~/.acme.sh/acme.sh --issue -d yourdomain.edu.tw --standalone -k ec-256 --force

sudo ~/.acme.sh/acme.sh --installcert -d yourdomain.edu.tw --key-file /etc/tls/edu.tw.key --fullchain-file /etc/tls/edu.tw.crt

# 建议使用CF的15年证书，需要TLS处开启  完全（FULL)。

删除，重建xray配置

    rm -rf /usr/local/etc/xray/config.json

    vi /usr/local/etc/xray/config.json

删除，重建nginx配置

    rm -rf /etc/nginx/nginx.conf

    vi /etc/nginx/nginx.conf

删除，重建SNI配置

    rm -rf /etc/nginx/conf.d/default.conf

    vi /etc/nginx/conf.d/default.conf

重启NG/XRAY

    sudo systemctl restart nginx xray

    sudo systemctl status nginx xray

