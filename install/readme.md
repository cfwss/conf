## 自用一键xRay/Sing-Box/Nginx脚本
	curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/Manual/menu.sh && chmod +x menu.sh && ./menu.sh 

## 主要功能
- 首次使用后:<br>
    &nbsp;&nbsp;&nbsp;&nbsp;**可以输入 nruan 来开启快捷功能**
- 前言:<br>
    &nbsp;&nbsp;&nbsp;&nbsp;用了很多年mack-a的v2ray-agent，但某些功能有所欠缺，<br>
    &nbsp;&nbsp;&nbsp;&nbsp;所以自行写了这个一键脚本。<br>
    &nbsp;&nbsp;&nbsp;&nbsp;在此，感谢：mack-a<br>
- 编写目的：<br>
    &nbsp;&nbsp;&nbsp;&nbsp;主要是为有很多小鸡的用户**提供方便**。如作者。<br>
    &nbsp;&nbsp;&nbsp;&nbsp;当有很多台vps或者很多个域名时，本脚本的优点可以体现。<br>
- 使用说明：<br>
    - 原v2ray-agent的配置，**几乎没作改动**，尤其是Path后缀（如*ws/vws/trjws/grpc/trojangrpc），可以完美过渡。
    - 选择"**一键安装所有配置**"，准备好已解析的域名，在输入域名环节，粘贴即可，几乎无交互操作。
    - 如果出现错误，用主菜单中的**重置所有配置**功能。
    - 生成用户UUID以及生成客户端配置，**脚本中基本都有提示**，但因为xRay中的ss配置，写的比较复杂，所以使用明文。
    - xRay中vless等，带有tcp的协议，生成的链接，可能会**丢失path，手动添加**一下即可使用。
    - 在使用xRay带有tcp协议时，**不能使用**开启了CDN的域名，但不开CDN的域名可以用ws/grpc等协议。
    - 在Sing-Box中，端口**不开放修改**。如果有需要，可以使用cf的worker来转发一下即可。如转发后，原3600的换成443。
    - 在Path/Password/Ports等修改选项，已做相应处理，根据提示来操作即可。（本想着用一套随机生成流，但有点没有必要了，首次安装/重置后，显示默认的才能更容易发现问题）
    - xray与nginx配套使用，sing-box独立区分，主要是为了多一道保障，**以防xray挂了后，还能正常使用**。不过根据目前测试结果来看，配了ws的，几乎不会挂。挂也只是优选IP/域名。
    - xRay使用了**40000端口**的WARP配置，选"为IPv4的VPS安装Warp双栈"安装。也可以自行安装，端口为:40000。
    - 脚本所使用的Sing-box、acme、xRay及相关依懒包均为**官方版本**，Nginx为稳定版本。
    - 关于生成Let's证书，只需要域名解析正确，开启云多亦可成功，**完全不需要cloudflare API，安全有保障**。详细的及方法已写在选项菜单中。
    - 关于Sing-box及xRay的更新，暂时没有。不过可尝试重新安装（并没有检查官方安装链接是否带有更新功能）。
    - 关于**强制更新Let's证书，有证书就没必要去更新**，申请成功后，官方acme会自动在60左右进行证书更新，有计划任务。
    - 关于Let's证书申请失败，别问我为啥，除了DNS解析问题、软件安装问题，以及申请次数过多等情况。**处理方法：换个子域名，重来**。
    - 支持CF状态下，添加域名TLS证书！**不限域名数量**。适合批量操作，100台VPS，也只需要一套域名列表清单，同时粘贴即可。
    - IPV6 only机未测试，理论是可以生成TLS证书。
    - 测试期间，用户需救较大的是生成客户端订阅链接。本脚本不会增加，如有兴趣者，可以外挂一个BASH。一般给到朋友、群员使用的是一串UUID外加一个EXCEL表格，只需填入UUID，所有URL自动生成。尝试过使用POWERSHELL制作URL，太繁琐，放弃了。
    - 本脚本的开发环境是**Debian 12**，其他系统环境暂不清楚，也**不考虑制作其他版本**，如有需要，**自行DD系统**。目前在ubuntu测试正常。
    - 关于卸载，暂时没有（可以选择再次安装，查看相应的依懒包及xRay，Sing-Bos，并使用官方的卸载功能进行卸载）。
    - 关于本脚本的余生，基本上对于本人使用到的功能，已经非常完善，一般不会再增加新功能。
    - 其他未尽说明，后继不补充。
## 操作步骤
- 域名准备，至少两个：abc.edu.eu.org / abc.com / bcd.com
- VPS准备，至少两台：vps0 / vps1 / vps2 /vps3 /vps4 / vps5 /vps6 /vps7 / vps8 / vps9 
- 将以上多个域名DNS放在CLOUDFLARE
- 取得所有vps的ip地址，ipv4即可
- 在cloudflare中，选择abc.edu.eu.org ，解析10台vps，**不要开启云朵**。如 vps1  127.0.0.1 / vps2  127.1.1.1 / vps3  124.0.3.1 / ...
- 将以上解析全部导出，并在导出的文件中**删除不相关的内容**，只保留vps1 127.0.0.1 / vps2  127.1.1.1 / ... 一般会有 vps1.abc.edu.eu.org 要把 .abc.edu.eu.org 全部去除。
- 将以上导的文件**修改好**后，分别导入 abc.com / bcd.com 并勾选开启云朵。此时三个域名的dns A记录应该**都是一致的**，唯一不同的是 abc.com/bcd.com 后面 代理状态 有亮着云朵。
- 再将 abc.com/bcd.com 的 **SSL/TLS 处**，选择 **full 完全（严格）**。
- 再去 cloudflare 左侧菜单 **network （网络）**处，开启 **WebSocket** 和 **gRPC**。
- 将所有的域名，放在Excel单元格或记事本中，清单应该有 30 个域名，**中间不要有空行**。
- 输入 nruan 调用本脚本 ，**首次用顶部的链接**。
- 等跳出输入域名时，将准备好的30个域名，粘贴进去。
- 耐心等待结束。
- 完成后，可以正常使用，但建议**重新生成用户UUID**和**修改相关的服务配置**。
- 接下来可以愉快地玩耍了。
- 理论上单个域名也是OK的。


## 用户管理
- 批量自动生成用户UUID
- 批量手动输入用户UUID
- 三种类型的UUID**单独设置**
- UUID转换BASE64
## 配置管理
- 查看服务端的各种配置(path/ports/domain/pawssword/method等)
- TLS证书强制更新(非必要无需强制更新)
- 单独修改服务端所能修改的配置(默认配置尽量修改成自己的)
- 多域名TLS情况，切换Sing-Box证书
## 其他功能
- 开启Warp [感谢fscarmen]，需要选择13项，不需要全局代理，**只需要开启40000端口**的本地代理即可
- 重置所有配置（Nginx,Sing-Box,xRay）
- **一键安装xRay、Sing-Box和Nginx**
- bbr功能在warp中已集中，不单独使用。**输入warp**后根据选项选择
- 主菜单更新提示
## 鸣谢
- https://github.com/XTLS/Xray-core
- https://github.com/SagerNet/sing-box
- https://github.com/fscarmen/warp-sh
- https://github.com/mack-a/v2ray-agent
- https://github.com/XTLS/Xray-examples/tree/main/All-in-One-fallbacks-Nginx

---

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
