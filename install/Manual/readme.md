curl  https://get.acme.sh | sh 

mkdir -p /etc/tls

sudo ~/.acme.sh/acme.sh --register-account -m my@example.com

sudo ~/.acme.sh/acme.sh --issue -d yourdomain.edu.tw --standalone -k ec-256 --force

sudo ~/.acme.sh/acme.sh --installcert -d yourdomain.edu.tw --key-file /etc/tls/edu.tw.key --fullchain-file /etc/tls/edu.tw.crt




    rm -rf /usr/local/etc/xray/config.json

    vi /usr/local/etc/xray/config.json


    rm -rf /etc/nginx/nginx.conf

    vi /etc/nginx/nginx.conf


rm -rf /etc/nginx/conf.d/default.conf

vi /etc/nginx/conf.d/default.conf


sudo systemctl restart nginx xray

sudo systemctl status nginx xray

