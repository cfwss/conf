

使用说明

    rm /usr/share/nginx/html/index.html --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/html/index.html
    mv index.html  /usr/share/nginx/html/index.html --force
    service nginx restart

NG默认页

    rm /usr/share/nginx/html/index.html --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/html/default.html
    mv default.html  /usr/share/nginx/html/index.html --force
    service nginx restart
    
跳转到Google

    rm /usr/share/nginx/html/index.html --force
    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/html/Google.html
    mv Google.html  /usr/share/nginx/html/index.html --force
    service nginx restart
