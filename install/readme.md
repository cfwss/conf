# 自用一键xRay/Sing-Box/Nginx脚本
	curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/menu.sh && chmod +x menu.sh && ./menu.sh 

自用，不一定更新

支持CF状态下，添加域名TLS证书！不限域名数量。

自动生成uuid理论不限数量。测试生成500个正常使用。稍微有点慢，大约4分钟。甲骨文非ARM。

xRay使用了40000端口的WARP配置，选15安装。也可以自行安装，端口为:40000。

sing-box的端口修改和其他METHOD没啥必要。端口有需要可以用workers来解决，也可以直接修改配置文件；某些METHOD不支持某些密码，防止失效，不作修改，如有需要，可自行尝试。

xray与nginx配套使用，sing-box独立区分，主要是为了多一道保障，以防xray挂了后，还能正常使用。不过根据目前测试结果来看，配了ws的，几乎不会挂。挂也只是优选IP/域名。

# 首次使用后，可以输入 nruan 来开启快捷功能


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/a1.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/a2.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/a3.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/00x.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/02.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/03.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/04.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/05.jpg)



![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/06.jpg)


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/08.jpg)



# **输入11，准备好已解析的域名，几乎无交互操作。配置文件这些全部自动抓取。正常情况，全新安装没有问题，可能会首次比较慢，或者可能卡在域名配置处，提供的域名清单不正确。
**

