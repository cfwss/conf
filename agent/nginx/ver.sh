
#改新版本配置Nginx >=1.25
sed  -i 's/http2 so_keepalive=on;/so_keepalive=on;http2 on;/g' /etc/nginx/conf.d/a.conf
sed  -i 's/http2 so_keepalive=on;/so_keepalive=on;http2 on;/g' /etc/nginx/conf.d/b.conf
nginx -t
service nginx reload
systemctl restart nginx
systemctl status nginx

#改旧版本配置Nginx <1.25
sed  -i 's/so_keepalive=on;http2 on;/http2 so_keepalive=on;/g' /etc/nginx/conf.d/a.conf
sed  -i 's/so_keepalive=on;http2 on;/http2 so_keepalive=on;/g' /etc/nginx/conf.d/b.conf
nginx -t
service nginx reload
systemctl restart nginx
systemctl status nginx
