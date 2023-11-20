使用说明：

创建多个域名回落。建议使用CF的15年证书。

自动配置：
  
    wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/ngx.sh  && bash ngx.sh


证书创建：

    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/Auto/tls.sh && bash tls.sh
    #需要修改证书信息，建议上传到私人git
