
默认将 url.hostname="domain.eu.org"; 中引号里面的换成需要反代的域名，不需要加http://或https://.


url.port="443"; 为默认即可，除非装了不止一套xray或v2ray。需要开启额外的端口处理。


    Cloudflare支持的HTTP端口：80，8080，8880，2052，2082，2086，2095
    Cloudflare支持的HTTPS端口：443，2053，2083，2087，2096，8443


可以增加其他功能，如：添加        url.pathname="/test"; 
原码地址：

    https://github.com/cfwss/conf/raw/main/agent/workers/workers.js

表示将二级/三级站点目录变为主目录。也就是将客户端的path填里面，那客户端只需一个/或不需要path


七天轮播源码地址：

    https://raw.githubusercontent.com/cfwss/conf/main/agent/workers/7%20days.js

需要将每台VPS的端口、UUID、PATH等信息，设为一致。
