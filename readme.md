## 无敌一键 xRay/Sing-Box/Nginx 批量管理脚本
	curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/nruan.sh && chmod +x nruan.sh && ./nruan.sh 

### 带参数安装，将bbb.com换成解析好的域名
	curl -O https://raw.githubusercontent.com/cfwss/conf/main/install/nruan.sh && chmod +x nruan.sh && ./nruan.sh -d bbb.com

## 主要功能
- 首次使用后:<br>
    &nbsp;&nbsp;&nbsp;&nbsp;**可以输入 nruan 来开启快捷功能**
- 前言:<br>
    &nbsp;&nbsp;&nbsp;&nbsp;用了多年mack-a的v2ray-agent，但因近期的功能不能满足本人需求，<br>
    &nbsp;&nbsp;&nbsp;&nbsp;于是自行写了这个一键脚本。<br>
    &nbsp;&nbsp;&nbsp;&nbsp;在此，感谢：mack-a<br>
- 编写目的：<br>
    &nbsp;&nbsp;&nbsp;&nbsp;主要是为有很多小鸡的用户**提供便捷操作**。如作者。<br>
    &nbsp;&nbsp;&nbsp;&nbsp;当有很多台vps或者很多个域名时，本脚本的优点可以体现。<br>
- 包含协议：<br>
    &nbsp;&nbsp;&nbsp;&nbsp;**xRay**<br>
    &nbsp;&nbsp;&nbsp;&nbsp;vless-tcp-xtls/vless-tcp/vless-ws/vless-grpc/vmess-tcp/vmess-ws/vmess-grpc/shadowsocks-tcp/shadowsocks-ws/shadowsocks-grpc/trojan-tcp/trojan-ws/trojan-grpc<br>
    &nbsp;&nbsp;&nbsp;&nbsp;**Sing-Box**<br>
    &nbsp;&nbsp;&nbsp;&nbsp;vless-ws/vmess-ws/trojan-ws/shadowsocks-tcp/tuic-tcp/naive-tcp/hysteria2-tcp<br>

<details>
  <summary>点击查看<b>【订阅玩法】</b></summary>
    <h2>喜欢每台机子都生成订阅的另当别论。</h2>
    <ul>
    <li>首先，多台VPS是基本要求。如，有30台，10台命名为：<i>vps0 / vps1 / vps2 .../ vps9</i>,另10台为<i>vpx0 / vpx1 / vpx2 .../ vpx9</i>,再有<i>vpw0 / vpw1 / vpw2 .../ vpw9</i>,</li>
    <li>确保每台机子都有CDN和TLS两套解析</li>
    <li>接着在所有的机子上安装相同的配置和UUID</li>
    <li>再将其中一台添加一个比v更靠前且不带数字的子域名，TLS和CDN同时，如 aaa</li>
    <li>只用aaa这一台机子，生成订阅。脚本会检测是不是数字，非数字需手输。这时，手动粘贴以上带数字的30个域名。</li>
    <li>结束后，用户使用正确的UUID用aaa地址得到30台机子的所有配置。</li>
    <li>好处并没有，还要手动，挺麻烦的，不如数字域名全自动</li>
    <li>喜欢每台机子都生成订阅的另当别论。</li> 
    </ul>
</details>

<details>
  <summary>点击查看<b>【更新日志】</b></summary>
    <h2>更新日志</h2>
    <ul>
    <li>2024/03/31 修复用户管理中，单独修改某些UUID时，检测错误。</li>
    <li>2024/03/28 优化订阅逻辑，增加优选域名配置及开关，其他修复。</li>
    <li>2024/03/27 优化域名输入时检测，去除冗余信息。</li>
    <li>2024/01/29 修复批量手输时，只有一个UUID的错误，quanx增加按协议订阅。</li>
    <li>2024/01/28 xRay的vless/vmess/trojan加了一套<b>全局Warp</b>。之前安装的要在主菜单重置，重新填UUID。</li>
    <li>2024/01/28 Sing-BOx增加<b>rule_set</b>分流（chatGPT及常用流媒体），需要安装warp，见主菜单。重置配置后，手输（粘贴）UUID。</li>
    <li>2024/01/27 关于归属地标签，作用是某些app自动分流，但IP归属地获取API有频率限制，建议一次不要太多的域名，每次输入的尽量都一致，自动除外，脚本也做了静态处理，相同域名生成全套订阅时只通过API获取一次。</li>
    <li>2024/01/27 原xRAY参数配置存在bug，使用2-->17重置，再10修改 Dokodemo-Door端口</li>
    <li>2024/01/27 订阅标签增加归属地，如VPS1_VMESS_WS_HK;增加NekoRay，这货Shadowsock参数全部能正确读取。增加surfboard，放了三个类型，只有一个能用，看后续软件支持与否吧。</li>
    <li>2024/01/25 优化自动生成订阅逻辑，修复相关bug。新增CFW订阅</li>
    <li>2024/01/24 自动生成功能为xray与sing-box分离，默认按标签和合集，生成中增加日志文件，详见生成后的屏显信息。<b>例：有10台VPS，并以VPS0,VPS1,VPS2...VPS9命名，选择要生成的配置后，啥也不用做。</b></li>
    <li>2024/01/24 增加了“自动生成”功能：多域名且前缀有数字的情况下，自动读取信息，默认以N个0开始，自动生成10台机子的配置，5秒内可手动干预，如果前缀中没有数字，则手输至少两个域名；将“按标签”生成放入到“其他配置”中。</li>
    <li>2024/01/21 增加了“按标签”订阅生成。晚上把xray新老的合一起了，自动判断。</li>
    <li>2024/01/21 增加了“序列域名”订阅生成。如有：vps1,vps2,vp3前缀的域名中有数字1,2,3，手动输入开始数字、数量即可。【例：vas01,vas02,vas03......vas10,输入开始数字是01，数量10。】</li>
    <li>2024/01/20 修复Nginx重置时path不完全跟随xray的问题。</li>
    <li>2024/01/20 完善配置管理菜单中某些修改的判断逻辑，超3次自动结束并5秒回主菜单；优化交互显示信息。</li>
    <li>2024/01/19 其他说明：单cdn能申请到证书，主要是为了传参数方便。如果是批量，建议还是需要至少一个非CDN的域名，否则无法定位，无法使用多台机子混合批量申请功能。</li>
    <li>2024/01/19 新增-d 参数进行一键安装，后面 直接跟域名（可以很多个）【./nruan.sh -d exp.domain.com -d exp.domain.net】；优化域名处理，现在单个cdn域名也能成功（传参数或手动）；新增测试功能。</li>
    <li>2024/01/18 修复Sing-Box重置后自动恢复证书错误。现为：检测域名是否CDN，优先非CDN，若无，则使用CDN，此时只有带ws功能的协议可用。关闭CDN不影响TLS证书，无需重新申请。</li>
    <li>2024/01/18 增加Sing-Box重置前自动备份，过程中5秒提示。证书申请失败时，导出日志。</li>
    <li>2024/01/17 简化暂停过程，5秒自动，按键可暂停，可跳过等待。xRay的用户信息和配置，重置前自动备份，过程中5秒提示恢复/取消，默认自动恢复。</li>
    <li>2024/01/17 优化证书申请，显示过程信息。</li>
    <li>2024/01/16 增加了Sing-Box端口修改。去除了bing.com自签，hy2使用当前域。</li>
    <li>2024/01/16 修复bug，优化自动配置逻辑，新增单独的path修改，详见菜单中 tag。</li>
    <li>2024/01/15 优化了很多内容，Nginx/sing-box/xray单独重置尽可能自动恢复。强化了TLS检测，一键订阅SS不支持的全部丢备注里了。</li>
    <li>2024/01/15 增加quanx订阅(测试)；增加版本检测；增加重置所有配置后，自动设置TLS证书和域名；其他BUG修复。</li>
    <li>2024/01/14 已增加订阅功能。目前v2ray正常，不过hy2的缺少混淆，v2ray不识别。SS明文，自行解码查看详配。</li>
    </ul>
</details>

<details>
  <summary>点击查看<b>【使用说明】</b></summary>
    <h2>使用说明</h2>
    <ul>
    <li>原v2ray-agent的配置，<b>几乎没作改动</b>，尤其是Path后缀（如*ws/vws/trjws/grpc/trojangrpc），可以完美过渡。</li>
    <li>选择"<b>一键安装所有配置</b>"，准备好已解析的域名，在输入域名环节，粘贴即可，几乎无交互操作。</li>
    <li>如果出现错误，用主菜单中的<b>重置所有配置</b>功能。</li>
    <li>生成用户UUID以及生成客户端配置，<b>脚本中基本都有提示</b>，但因为xRay中的ss配置，写的比较复杂，所以使用明文。</li>
    <li>xRay中vless等，带有tcp的协议，生成的链接，可能会<b>丢失path，手动添加</b>一下即可使用。</li>
    <li>在使用xRay带有tcp协议时，<b>不能使用</b>开启了CDN的域名，但不开CDN的域名可以用ws/grpc等协议。</li>
    <li>在Sing-Box中，端口<b>不开放修改</b>。如果有需要，可以使用cf的workers来转发一下即可。如转发后，原3600的换成443，域名用新加的别名，不是原来的那个。</li>
    <li>在Path/Password/Ports等修改选项，已做相应处理，根据提示来操作即可。（本想着用一套随机生成流，但有点没有必要了，首次安装/重置后，显示默认的才能更容易发现问题）</li>
    <li>xray与nginx配套使用，sing-box独立区分，主要是为了多一道保障，<b>以防xray挂了后，还能正常使用</b>。不过根据目前测试结果来看，配了ws的，几乎不会挂。挂也只是优选IP/域名。</li>
    <li>xRay使用了<b>40000端口</b>的WARP配置，选"为IPv4的VPS安装Warp双栈"安装。也可以自行安装，端口为:40000。</li>
    <li>脚本所使用的Sing-box、acme、xRay及相关依懒包均为<b>官方版本</b>，Nginx为稳定版本。</li>
    <li>关于生成Let's证书，只需要域名解析正确，开启云朵亦可成功，<b>完全不需要cloudflare API，安全有保障</b>。详细的及方法已写在选项菜单中。</li>
    <li>关于Sing-box及xRay的更新，暂时没有。不过可尝试重新安装（2023/01/13在主菜单添加了更新/重装功能）。</li>
    <li>关于<b>强制更新Let's证书，证书在有效期内就没必要去更新</b>，申请成功后，官方acme会自动在60天左右进行证书更新，有计划任务。</li>
    <li>关于Let's证书申请失败，别问我为啥，除了DNS解析问题、软件安装问题，以及申请次数过多等情况。<b>处理方法：换个子域名，重来</b>。</li>
    <li>支持CDN状态下，添加域名TLS证书！<b>不限域名数量</b>。适合批量操作，100台VPS，也只需要一套域名列表清单，同时粘贴即可。</li>
    <li>IPV6 only机未测试，理论是可以生成TLS证书。</li>
    <li>关于不用Reality协议，没啥必要了，自用与分享，目前足矣。何况还有Sing-Box。</li>
    <li>关于Sing-Box端口转发（通过ClourFlare的Workers 路由），转发代码见 操作步骤 中的【表三】,同时在触发器中的“自定义域”添加相应的别名。</li>
    <li>测试期间，用户需求较大的是生成客户端订阅链接。本脚本不会增加，如有兴趣者，可以外挂一个BASH。一般给到朋友、群员使用的是一串UUID外加一个EXCEL表格，只需填入UUID，所有URL自动生成。尝试过使用POWERSHELL制作URL，太繁琐，放弃了。</li>
    <li>本脚本的开发环境是<b>Debian 12</b>，其他系统环境暂不清楚，也<b>不考虑制作其他版本</b>，如有需要，<b>自行DD系统</b>。目前在ubuntu测试正常。</li>
    <li>关于卸载，暂时没有（可以选择再次安装，查看相应的依懒包及xRay，Sing-Bos，并使用官方的卸载功能进行卸载）。</li>
    <li>关于本脚本的余生，基本上对于本人使用到的功能，已经非常完善，一般不会再增加新功能。</li>
    <li>其他未尽说明，后继不补充。</li>
    </ul>
</details>

<details>
  <summary>点击查看<b>【操作步骤】</b></summary>
  <h2>操作步骤【以CloudFlare为例】</h2><b>表一和表三的内容是用于cloudflare中的，表二的内容是用于脚本中的</b>
  <li>域名准备，至少两个：<i>abc.edu.eu.org / abc.com / bcd.com</i></li>
  <li>VPS准备，至少两台：<i>vps0 / vps1 / vps2 /vps3 /vps4 / vps5 /vps6 /vps7 / vps8 / vps9</i></li>
  <li>将以上多个域名DNS放在 CloudFlare</li>
  <li>取得所有VPS的ip地址，ipv4即可。</li>
  <li>在CloudFlare中，选择 <i>abc.edu.eu.org</i> ，解析10台vps，<b>不要开启云朵</b>。如 <i>vps1  127.0.0.1 / vps2  127.1.1.1 / vps3  124.0.3.1 / </i>...</li>
  <li>将以上解析全部导出，并在导出的文件中<b>删除不相关的内容</b>，【见表一】只保留<i>vps1 127.0.0.1 / vps2  127.1.1.1 /</i> ... 一般会有 <i>vps1.abc.edu.eu.org</i> 要把 <b>.abc.edu.eu.org</b> 全部去除。</li>
  <li>将以上导的文件<b>修改好</b>后【见表一】，分别导入 <i>abc.com / bcd.com</i> 并勾选开启云朵。此时三个域名的dns A记录应该<b>都是一致的</b>，唯一不同的是 <i>abc.com / bcd.com</i> 后面 代理状态 有亮着云朵。</li>
  <li>再将 <i>abc.com / bcd.com</i> 的 <b>SSL/TLS 处</b>，选择 <b>full 完全（严格）</b>。</li>
  <li>再去点开 CloudFlare 左侧菜单 <b>Network （网络）</b>，开启 <b>WebSocket</b> 和 <b>gRPC</b>。</li>
  <li>将所有的域名，放在Excel单元格或记事本中，清单应该有 30 个域名，<b>中间不要有空行</b>。</li>
  <li>输入 nruan 调用本脚本 ，<b>首次用顶部的链接</b>。</li>
  <li>等跳出输入域名时，将准备好的30个域名，粘贴进去【见表二】,按回车，某些情况可能要按两次回车。</li>
  <li>耐心等待结束。</li>
  <li>完成后，可以正常使用，但建议<b>重新生成用户UUID</b>和<b>修改相关的服务配置</b>。</li>
  <li>接下来可以愉快地玩耍了。</li>
  <li>理论上单个域名也是OK的。</li><br>

  <li><b>注意：这里有一个逻辑问题，如果有两个不同的域名都没开启CDN，会以第一优先匹配原则，使用NGINX申请证书时也会查找第一匹配的前缀。如：<i>vap0.abc.com / vps0.abc.com </i>谁在清单前谁优先。如果提供的域名列表都是vps？开头的且只存在vps？的A记录，那么，其他域名无法申请到相应的TLS证书，因为优先选择了vap0，其他域名并没有vap0子域名的解析。</b></li> <br> <br>

   

  **表一：CloudFlare DNS 解析导入表【这是在cf后台使用的，脚本中不需要，但要先做好解析，脚本中只需要表二】**

  |;; A Records| || | |
  |-----|-----|-----|-----|-----|
  |vps0|1|IN|A|127.0.1.1|
  |vps1|1|IN|A|127.0.0.1|
  |vps2|1|IN|A|127.0.0.2|
  |vps3|1|IN|A|127.0.0.3|
  |vps4|1|IN|A|127.0.0.4|
  |vps5|1|IN|A|127.0.0.5|
  |vps6|1|IN|A|127.0.0.6|
  |vps7|1|IN|A|127.0.0.7|
  |vps8|1|IN|A|127.0.0.8|
  |vps9|1|IN|A|127.0.0.9|
<br>


  **表二：域名清单（脚本中使用，可以一列，也可以多列）**

  |              |                 |                     |
  |--------------|-----------------|---------------------|
  | vps0.abc.com | vps0.bcd.com    | vps0.abc.edu.eu.org |
  | vps1.abc.com | vps1.bcd.com    | vps1.abc.edu.eu.org |
  | vps2.abc.com | vps2.bcd.com    | vps2.abc.edu.eu.org |
  | vps3.abc.com | vps3.bcd.com    | vps3.abc.edu.eu.org |
  | vps4.abc.com | vps4.bcd.com    | vps4.abc.edu.eu.org |
  | vps5.abc.com | vps5.bcd.com    | vps5.abc.edu.eu.org |
  | vps6.abc.com | vps6.bcd.com    | vps6.abc.edu.eu.org |
  | vps7.abc.com | vps7.bcd.com    | vps7.abc.edu.eu.org |
  | vps8.abc.com | vps8.bcd.com    | vps8.abc.edu.eu.org |
  | vps9.abc.com | vps9.bcd.com    | vps9.abc.edu.eu.org |

<br>




  **表三：Worker.js**
  >addEventListener(<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;"fetch",event => {<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;let url=new URL(event.request.url);<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;url.protocol="https";<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;url.hostname="vps9.abc.eu.org"; //修改为你的域名，并去掉本行注释<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;url.port="3600"; //修改为你要转发的协议端口，可在SING-BOX配置中查看<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;let request=new Request(url,event.request);<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;event. respondWith(<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fetch(request)<br>
  >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;)<br>
  >&nbsp;&nbsp;&nbsp;}<br>
  >)<br>
<br>

</details>

<details>
  <summary>点击查看<b>【订阅格式】</b></summary>
    <h2>订阅格式</h2>
    <ul>

<li> <b>xRay配置[按协议 For v2RayN]</b> </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vless-xtls/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vless-tcp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vmess-tcp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/trojan-tcp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/shadowsocks-tcp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vless-warp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vmess-warp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/trojan-warp/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vless-grpc/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/vmess-grpc/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/trojan-grpc/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/shadowsocks-grpc/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/old-vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/old-vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/old-trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/old-shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/old-vless-grpc/完整UUID </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/old-trojan-grpc/完整UUID </li>

<li> <b>xRay配置[全套 For v2RayN]</b> </li>
<li> https://任意一个域名/xray/v2rayn/UUID前8位/完整UUID </li>

SING-BOX配置[按协议 For v2RayN]</b> </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/trojan/完整UUID </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/vmess/完整UUID </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/shadowsocks/完整UUID </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/vless/完整UUID </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/tuic/完整UUID </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/naive/完整UUID </li>
<li> https://任意一个域名/sing-box/v2rayn/UUID前8位/hysteria2/完整UUID </li>

<li> <b>SING-BOX配置[全套 For v2RayN]</b> </li>
<li> https://任意一个域名/sing-box/UUID前8位/trojan/完整UUID </li>


<li> <b>xRay配置[按协议 For Nekobox]</b> </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vless-xtls/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vless-tcp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vmess-tcp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/trojan-tcp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/shadowsocks-tcp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vless-warp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vmess-warp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/trojan-warp/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vless-grpc/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/vmess-grpc/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/trojan-grpc/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/shadowsocks-grpc/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/old-vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/old-vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/old-trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/old-shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/old-vless-grpc/完整UUID </li>
<li> https://任意一个域名/xray/neko/UUID前8位/old-trojan-grpc/完整UUID </li>

<li> <b>xRay配置[全套 For Nekobox]</b> </li>
<li> https://任意一个域名/xray/neko/UUID前8位/完整UUID </li>

<li> <b>SING-BOX配置[按协议 For Nekobox]</b> </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/trojan/完整UUID </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/vmess/完整UUID </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/shadowsocks/完整UUID </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/vless/完整UUID </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/tuic/完整UUID </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/naive/完整UUID </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/hysteria2/完整UUID </li>

<li> <b>SING-BOX配置[全套 For Nekobox]</b> </li>
<li> https://任意一个域名/sing-box/neko/UUID前8位/完整UUID </li>


<li> <b>xRay配置[全套 For QuantumultX]</b> </li>
<li> https://任意一个域名/xray/quanx/UUID前8位/完整UUID </li>

<li> <b>SING-BOX[全套 For QuantumultX]</b> </li>
<li> https://任意一个域名/sing-box/quanx/UUID前8位/完整UUID </li>

<li> <b>SING-BOX配置[按协议 For ShadowRocket]</b> </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/trojan/完整UUID </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/vmess/完整UUID </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/shadowsocks/完整UUID </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/vless/完整UUID </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/tuic/完整UUID </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/naive/完整UUID </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/hysteria2/完整UUID </li>

<li> <b>SING-BOX配置[全套 For ShadowRocket]</b> </li>
<li> https://任意一个域名/sing-box/rocket/前8位UUID/完整UUID </li>

<li> <b>xRay配置[Clash Fow Win]</b> </li>
<li> https://任意一个域名/xray/clash/UUID前8位/vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/vless-warp/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/vmess-warp/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/trojan-warp/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/trojan-grpc/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/old-vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/old-vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/clash/UUID前8位/old-trojan-grpc/完整UUID </li>


<li> <b>xRay配置[按协议 For NekoRay]</b> </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vless-xtls/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vless-tcp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vmess-tcp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/trojan-tcp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/shadowsocks-tcp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vless-warp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vmess-warp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/trojan-warp/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vless-grpc/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/vmess-grpc/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/trojan-grpc/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/shadowsocks-grpc/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/old-vless-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/old-vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/old-trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/old-shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/old-vless-grpc/完整UUID </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/old-trojan-grpc/完整UUID </li>

<li> <b>xRay配置[全套 For NekoRay]</b> </li>
<li> https://任意一个域名/xray/nekoray/UUID前8位/完整UUID </li>

<li> <b>xRay配置[按协议 For surfboard]</b> </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/trojan-tcp/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/vmess-warp/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/trojan-warp/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/shadowsocks-ws/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/old-vmess-ws/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/old-trojan-ws/完整UUID </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/old-shadowsocks-ws/完整UUID </li>
<li> <b>*注：目前只有vmess-ws/old可用


<li> <b>xRay配置[全套 For NekoRay]</b> </li>
<li> https://任意一个域名/xray/surfboard/UUID前8位/完整UUID </li>
    </ul>
</details>

### 非CDN域名一键安装视频（单域名，带参数）

[![YouTube 视频](https://img.youtube.com/vi/16iWFUQHwS4/0.jpg)](https://www.youtube.com/watch?v=16iWFUQHwS4)

点击上面的图片查看视频。

### CDN域名一键安装视频（单域名，带参数）
[![YouTube 视频](https://img.youtube.com/vi/4-q6ibldewg/0.jpg)](https://www.youtube.com/watch?v=4-q6ibldewg)

点击上面的图片查看视频。
## 用户管理
- 批量自动生成用户UUID
- 批量手动输入用户UUID
- 三种类型的UUID**单独设置**
- UUID转换BASE64
## 配置管理
- 查看服务端的各种配置(path/ports/domain/pawssword/method等)
- TLS证书强制更新(非必要无需强制更新)
- 单独修改服务端所能修改的配置(默认配置尽量修改成自己的)
- 多域名TLS情况，手动选择/切换Sing-Box证书（域名）
## 其他功能
- 开启Warp [感谢fscarmen]，只需要选择第13项，不需要全局代理。运行warp 后，**第13项输入端口时保持默认40000 即可**的本地代理即可
- 重置所有配置（Nginx,Sing-Box,xRay）
- **一键安装xRay、Sing-Box和Nginx**
- bbr功能在warp中已集成，不单独使用。**输入warp**后根据选项选择
- 主菜单更新提示
---
![Alt text](https://github.com/cfwss/conf/blob/main/install/images/warp.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/main_menu.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/sub_01.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/sub_02.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/sub_03.jpg)

<details>
  <summary>点击查看<b>【更多图片】</b></summary>

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/warp2.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/install.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/domain.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/domain2.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/reseta.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/new_uuid.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/all_set.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/all_uuid.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/sb_user_d.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/xray_user.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/sb_ports.jpg)

![Alt text](https://github.com/cfwss/conf/blob/main/install/images/auto.jpg)

</details>


## 鸣谢
- https://github.com/XTLS/Xray-core
- https://github.com/SagerNet/sing-box
- https://github.com/fscarmen/warp-sh
- https://github.com/mack-a/v2ray-agent
- https://github.com/XTLS/Xray-examples/tree/main/All-in-One-fallbacks-Nginx

---
