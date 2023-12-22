curl  https://get.acme.sh | sh 
mkdir -p /etc/tls
sudo ~/.acme.sh/acme.sh --register-account -m my@example.com
sudo ~/.acme.sh/acme.sh --issue -d yourdomain.edu.tw --standalone -k ec-256 --force
sudo ~/.acme.sh/acme.sh --installcert -d yourdomain.edu.tw --key-file /etc/tls/edu.tw.key --fullchain-file /etc/tls/edu.tw.crt



