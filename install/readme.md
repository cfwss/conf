# 自用一键xRay/Sing-Box/Nginx脚本
	curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/menu.sh && chmod +x menu.sh && ./menu.sh 

# 主要功能
- 首次使用后，可以输入 nruan 来开启快捷功能
- 前言:
    用了很多年mack-a的v2ray-agent，但某些功能有所欠缺，
    所以自行写了一个一键脚本。
    在此，感谢：mack-a
- 编写目的：
    主要是为有很多小鸡的用户提供方便。如作者。
    当有很多台vps或者很多个域名时，本脚本的优点可以体现。
- 使用说明：
    1.  原v2ray-agent的配置，几乎没作改动，尤其是Path后缀，可以完美过渡。
    2.  选择"一键安装所有配置"，准备好已解析的域名，在输入域名环节，粘贴即可，几乎无交互操作。
    3.  如果出现错误，用主菜单中的重置所有配置功能。
    4.  生成用户UUID以及生成客户端配置，脚本中基本都有提示，但因为xRay中的ss配置，写的比较复杂，所以使用明文。
    5.  xRay中vless等，带有tcp的协议，生成的链接，可能会丢失path，手动添加一下即可使用。
    6.  在使用xRay带有tcp协议时，不能使用开启了CDN的域名，但不开CDN的域名可以用ws/grpc等协议。
    7.  在Sing-Box中，端口不开放修改。如果有需要，可以使用cf的worker来转发一下即可。如转发后，原3600的换成443。
    8.  在Path/Password/Ports等修改选项，已做相应处理，根据提示来操作即可。
    9.  xray与nginx配套使用，sing-box独立区分，主要是为了多一道保障，以防xray挂了后，还能正常使用。不过根据目前测试结果来看，配了ws的，几乎不会挂。挂也只是优选IP/域名。
    10. xRay使用了40000端口的WARP配置，选"为IPv4的VPS安装Warp双栈"安装。也可以自行安装，端口为:40000。
    11. 脚本所使用的Sing-box、acme、xRay及相关依懒包均为官方版本，Nginx为稳定版本。
    13. 关于生成Let's证书，只需要域名解析正确，开启云多亦可成功，完全不需要cloudflare API，安全有保障。详细的及方法已写在选项菜单中。
    14. 关于卸载，暂时没有。
    15. 关于Sing-box及xRay的更新，暂时没有。不过可尝试重新安装（并没有检查官方安装链接是否带有更新功能）
    16. 关于强制更新Let's证书，有证书就没必要去更新，申请成功后，官方acme会自动在60左右进行证书更新，有计划任务。
    17. 关于Let's证书申请失败，别问我为啥，除了DNS解析问题、软件安装问题，以及申请次数过多等情况。处理方法：换个子域名，重来。
    18. 本脚本的开发环境是Debian 12，其他系统环境暂不清楚，也不考虑制作其他版本，如有需要，自行DD系统。目前在ubuntu测试正常。
    19. 支持CF状态下，添加域名TLS证书！不限域名数量。适合批量操作，100台VPS，也只需要一套域名列表清单，同时粘贴即可。
    20. 其他未尽说明，后继不补充。
## 用户管理
- 批量自动生成用户UUID
- 批量手动输入用户UUID
- 三种类型的UUID单独设置
- UUID转换BASE64
## 配置管理
- 查看服务端的各种配置
- TLS证书强制更新
- 单独修改服务端所能修改的配置
- 多域名TLS情况，切换Sing-Box证书
## 其他功能
- 开启Warp [感谢fscarmen]
- 重置所有配置
- 一键安装xRay、Sing-Box和Nginx


支持CF状态下，添加域名TLS证书！不限域名数量。

增加了主菜单更新提醒

自动生成uuid理论不限数量。测试生成500个正常使用。稍微有点慢，大约4分钟。甲骨文非ARM。

xRay使用了40000端口的WARP配置，选15安装。也可以自行安装，端口为:40000。

sing-box的端口修改和其他METHOD没啥必要。端口有需要可以用workers来解决，也可以直接修改配置文件；某些METHOD不支持某些密码，防止失效，不作修改，如有需要，可自行尝试。

xray与nginx配套使用，sing-box独立区分，主要是为了多一道保障，以防xray挂了后，还能正常使用。不过根据目前测试结果来看，配了ws的，几乎不会挂。挂也只是优选IP/域名。

# 首次使用后，可以输入 nruan 来开启快捷功能


![Alt text](https://github.com/cfwss/conf/blob/main/install/Manual/images/az1.jpg)

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

