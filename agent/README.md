使用说明：

//不解锁流媒体(适用于落地鸡)

	rm /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/10_ipv4_outbounds.json

	mv 10_ipv4_outbounds.json  /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force


	rm /etc/v2ray-agent/xray/conf/09_routing.json --force

	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/09_routing.json

	mv 09_routing.json   /etc/v2ray-agent/xray/conf/09_routing.json --force


如果小鸡可以解锁，不需要WARP分流，请使用默认配置。

如果启用了warp分流，可使用此配置。

把文件名替换成对应的即可

如果需要落地解锁，使用forward里面的config。

落地机解锁的10_ipv4_outbounds.json文件，内容需要修改成你的解锁机vmess+ws节点信息。包括域名、UUID、PATH等。

如果HK鸡，请使用forHK，通过落地鸡解锁chatGPT等。

=================================【第一部分，安装warp sock 】===============================

	  wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/menu.sh  && bash menu.sh [option] [lisence/url/token]

//二选一，这是warp 

//【自用，备份，防丢链接，建议用官方的https://gitlab.com/fscarmen/warp】

	  wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/warp-go.sh && bash warp-go.sh [option] [lisence]

//二选一，这是warp go

//【自用，备份，防丢链接，建议用官方的https://gitlab.com/fscarmen/warp】

//上面二选一，我用第一个。回车（中文选2再回车），13，回车，回车。

	curl ifconfig.me --proxy socks5://127.0.0.1:40000

//检查端口成功与否

==============================【第二部分，安装V2RAY，各取所需吧】=============================

	wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/cfwss/conf/main/install/install.sh" && chmod 700 /root/install.sh && /root/install.sh

//选2,1,4（带TJ 或者选12345。如果需要开cloudflare的小云朵，建议使用带cdn的选项，可多选）

//如果要开小云朵，又要开TLS，建议使用两套域名，如eu.org用来开云朵，自备域名用Tls，同时要在nginx中配置好回落。具体见最后。

//【自用，备份，防丢链接，建议用官方的https://github.com/mack-a/v2ray-agent】


  vasma

//脚本命令，后面会用到，如：添加用户，开启BBR，重启xray等。

=================【【第三部分，设置xray的warp参数，如果第二部分不和我选的一样，请忽略这部分】=================

	rm /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/10_ipv4_outbounds.json

	mv 10_ipv4_outbounds.json  /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

	rm /etc/v2ray-agent/xray/conf/09_routing.json --force

	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/09_routing.json

	mv 09_routing.json   /etc/v2ray-agent/xray/conf/09_routing.json --force

	vasma

#输入，16-->6 重启xray即可。


=========================【【第四部分，多域名Nginx多重回落】=========================

首选我选择的是12345套餐。

NG目录：/etc/nginx/conf.d/

其中有一个alone.conf的文件，用cp，复制一个你的a.conf ，如果有多个域名，可以b.conf 

修改：

	listen 127.0.0.1:31312 so_keepalive=on;http2 on;  //端口号修改成与alone.conf不同的即可，如32211等。
 
	server_name yourdomain.eu.org;  //这里有两处要修改，一处在开头，一处在尾部。
 

处理完后，重启ng。

	service nginx restart

如果没有错误，那就可以浪了。
