# 自用一键xRay/Sing-Box/Nginx脚本
	curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/menu.sh && chmod +x menu.sh && ./menu.sh 

自用，不一定更新

支持CF状态下，添加域名TLS证书！不限域名数量。

自动生成理论不限数量。测试生成200个正常使用。稍微有点慢。GCP 最小配置。

xRay使用了40000端口的WARP配置，选15安装。也可以自行安装，端口为:40000。

sing-box的端口修改和其他METHOD没啥必要。端口有需要可以用workers来解决；某些METHOD不支持某些密码，防止失效，不作修改，如有需要，可自行尝试。

![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/01.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/02.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/03.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/04.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/05.jpg)



![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/06.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/08.jpg)



**输入18，准备好已解析的域名，几乎无交互操作。配置文件这些全部自动抓取。正常情况，全新安装没有问题，可能会首次比较慢，或者可能卡在域名配置处，提供的清单不正确。
**
# 以下废弃！仅供参考
使用说明：



	VLESS+TCP[TLS_Vision] VLESS+WS[TLS] Trojan+gRPC[TLS] VMess+WS[TLS] Trojan+TCP[TLS] VLESS+gRPC[TLS]



# =========【第一部分，安装warp sock 】=========

	  wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/menu.sh  && bash menu.sh [option] [lisence/url/token]

//二选一，这是warp 

//【自用，备份，防丢链接，建议用官方的 https://gitlab.com/fscarmen/warp 】

	  wget -N https://raw.githubusercontent.com/cfwss/conf/main/install/warp-go.sh && bash warp-go.sh [option] [lisence]

//二选一，这是warp go

//【自用，备份，防丢链接，建议用官方的 https://gitlab.com/fscarmen/warp 】

//上面二选一，我用第一个。回车（中文选2再回车），13，回车，回车。

	curl ifconfig.me --proxy socks5://127.0.0.1:40000

//检查端口成功与否

# =========【第二部分，安装V2RAY，各取所需吧】=========

	不再使用

//选2,1,4（带TJ 或者选12345。如果需要开cloudflare的小云朵，建议使用带cdn的选项，可多选）

//如果要开小云朵，又要开TLS，建议使用两套域名，如eu.org用来开云朵，自备域名用Tls，同时要在nginx中配置好回落。具体见最后。

//【自用，备份，防丢链接，建议用官方的 ####】


	  vasma

//脚本命令，后面会用到，如：添加用户，开启BBR，重启xray等。

# =========【第三部分，设置xray的warp参数，如果第二部分不和我选的一样，请忽略这部分】=========

	rm /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force
	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/10_ipv4_outbounds.json
	mv 10_ipv4_outbounds.json  /etc/v2ray-agent/xray/conf/10_ipv4_outbounds.json --force

	rm /etc/v2ray-agent/xray/conf/09_routing.json --force
	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/09_routing.json
	mv 09_routing.json   /etc/v2ray-agent/xray/conf/09_routing.json --force

	vasma

#输入，16-->6 重启xray即可。


# =========【第四部分，多域名Nginx多重回落】=========

首选我选择的是12345套餐。

NG目录：/etc/nginx/conf.d/

其中有一个alone.conf的文件，用cp，复制一个你的a.conf ，如果有多个域名，可以b.conf 

修改：

	listen 127.0.0.1:31312 so_keepalive=on;http2 on;  //端口号修改成与alone.conf不同的即可，如32211等。
 
	server_name yourdomain.eu.org;  //这里有两处要修改，一处在开头，一处在尾部。


删除顶部这几行

    server {
    		listen 127.0.0.1:31300;
    		server_name aws.aeakawa.eu.org;
    		return 403;
    }

处理完后，重启ng。	

	service nginx restart

# =========【第五部分，多域名Nginx ECC证书配置】=========

正常的思路是：默认域不开云朵，方便LET'S证书自动续期。要开云朵也行，配置好CF里的功能，开云朵也是可以自动续期的。。

主域能直接访问，非和谐的域名，只开TLS，二号域名可以是任何域，通过CDN功能，配合优选IP/域名来使用。三号域可以备用，或开或不开云朵均可，但要用TLS最好是配证书。

配合云朵，完全TLS模式。

	wget https://raw.githubusercontent.com/cfwss/conf/main/agent/Auto/add.sh && bash add.sh

 
如果没有错误，那就可以浪了。

=========================【结语】=========================

至此，yourdomain，yourdomain2，yourdomain3 都可以直接访问，同时都可以用统一对应的配置。如sni，每个不一样都OK的。

但是，当只使用TLS时，某些功能并不互用。

所以，可以考虑域名A用作默认参数开云朵，域名B不开云朵，仅TLS，域名C开云朵为备用。

CLOUDFLARE可以批量导入域名IP指向。默认情况，只需要将默认域名在配置时申请LET'S证书，其他的域名可以通过CF的泛域来处理。也就是所有的小鸡用同一本证书，且不需要定时更新。CF后台会给临时证书，一般1个月至3个月不等。

用GRPC需要在CF开启GRPC，WS同理，建议使用TLS 1.3。不需要兼容。

