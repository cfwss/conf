# 自动添加TLS证书

    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/Auto/tls.sh && bash tls.sh

把TLS.SH证书部分的内容换成自己的15年证书。创建到私有GIT，以后新建VPS时，都可以使用。

通过SH，不需要像之前那样VI去写，记得一定要放到私有GIT里！链接也要替换一下。

添加域名前，请先配置对应的TLS证书，模板可参照上方。

# 定义域名数组，不需要的可以删除整行或者用 # 在行首注释

    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/Auto/domain.sh && bash domain.sh

# 纯手输入版本：

    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/Auto/add.sh && bash add.sh

    
# NG通配符*：

    wget https://raw.githubusercontent.com/cfwss/conf/main/agent/Auto/all.sh && bash all.sh
