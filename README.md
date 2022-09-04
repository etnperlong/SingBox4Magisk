English | [简体中文](README_zh_CN.md)

# SingBox4Magisk
A fork of [Xray4Magisk](https://github.com/Asterisk4Magisk/Xray4Magisk)

This is a sing-box module for Singbox, and includes binaries for arm, arm64, x86, x64.



## Disclaimer
I'm not responsible for bricked devices, dead SD cards, or burning your SoC.

Make sure you are not going to loopback traffic again and again. It might cause your phone reset, then bootloop.

If you really don't know how to configure this module, you mignt need apps like v2rayNG, SagerNet(or AnXray) etc.



## Install

You can download the release installer zip file and install it via the Magisk Manager App.

### Download sing-box binary: Auto
NOTE: This module doesn't contain sing-box binary. Instead, the installation process download the latest binary file from [sing-box's github releases](https://github.com/SagerNet/sing-box/releases).

### Download sing-box binary: Manual
Download the sing-box zip file, rename it to "sing-box-core.tar.gz" and put it in `/sdcard/Download`.

NOTICE: It is important to check your device's CPU Architecture, and select the correct .zip file.  
For example, for sdm855, we choose "sing-box-1.0-rc1-linux-arm64.tar.gz".



## Config

- sing-box config files are store in `/data/adb/sing-box/confs/config.json`.

- Tips: Please notice that the default configuration has already set inbounds section to cooperate work with transparent proxy script. It is recommended that you only edit the `proxy.json` to your proxy server and edit file `/data/adb/sing-box/appid.list` to select which App to proxy. Edit file `ignore_out.list` can help you to ignore some OUTPUT interfaces.



## Usage

### Normal usage ( Default and Recommended )

#### Manage service start / stop

- sing-box service is auto-run after system boot up by default.
- You can use Magisk Manager App to manage it. Be patient to wait it take effect (about 3 second).
- Check out [Manage service start / stop
](https://github.com/Asterisk4Magisk/Xray4Magisk#manage-service-start--stop-1) and [Manage transparent proxy enable / disable](https://github.com/Asterisk4Magisk/Xray4Magisk#manage-transparent-proxy-enable--disable)


#### Select which App to proxy

- Check out [Select which UID to proxy](https://github.com/Asterisk4Magisk/Xray4Magisk#select-which-uid-to-proxy)


### Advanced usage ( for Debug and Develop only )

#### Enter manual mode

If you want to control sing-box by running command totally, just add a file `/data/adb/sing-box/manual`.  In this situation, sing-box service won't start on boot automatically and you cann't manage service start/stop via Magisk Manager App. 


#### Select which UID to proxy

- If you expect transparent proxy ( read Transparent proxy section for more detail ) for specific Apps, just write down these Apps' uid in file `/data/adb/sing-box/appid.list` . 

  Each App's uid should separate by space or just one App's uid per line. ( for Android App's uid , you can search App's package name in file `/data/system/packages.list` , or you can look into some App like Shadowsocks. )

- If you expect all Apps proxy by sing-box with transparent proxy, just write `ALL` in file `/data/adb/sing-box/appid.list` .

- If you expect all Apps proxy by sing-box with transparent proxy EXCEPT specific Apps, write down `bypass` at the first line then these Apps' uid separated as above in file `/data/adb/sing-box/appid.list`. 

- Transparent proxy won't take effect until the sing-box service start normally and file `/data/adb/sing-box/appid.list` is not empty.


#### Manage service start / stop

- sing-box service script is `$MODDIR/scripts/sing-box.service`.

- For example, in my environment ( Magisk-alpha version: 23001 )

  - Start service : 

    `/data/adb/sing-box/scripts/sing-box.service start`

  - Stop service :

    `/data/adb/img/sing-box/scripts/sing-box.service stop`


#### Manage transparent proxy enable / disable

- Transparent proxy script is `/data/adb/sing-box/scripts/sing-box.tproxy`.

- For example, in my environment ( Magisk-alpha version: 23001 )

  - Enable Transparent proxy : 

    `/data/adb/sing-box/scripts/sing-box.tproxy enable`

  - Disable Transparent proxy :

    `/data/adb/sing-box/scripts/sing-box.tproxy disable`


#### Bypass Transparent proxy when connecting to WLAN
TODO


#### Select which App to proxy, and which App to second proxy
TODO


#### Enable IPv6
For best compatibility, this module disable IPv6 by default.

To enable IPv6 proxy, execute `touch /data/adb/sing-box/ipv6`

To enable DNS AAAA record querying, edit `dns.json`, change `"queryStrategy"` from "UseIPv4" to "UseIP".

To enable local IPv6 out, edit `base.json`, find the first inbound with "freedom" tag, change its `"domainStrategy"` from "UseIPv4" to "UseIP".

To enable proxy IPv6 out, edit `proxy.json`, change its `"domainStrategy"` as what you do in `base.json`.




## Uninstall

1. Uninstall the module via Magisk Manager App.
2. You can clean sing-box data dir by running command `rm -rf /data/adb/sing-box && rm -rf /data/adb/service.d/singbox4magisk_service.sh` .



## FAQ
No such file or directory?
> You might need Busybox for Android NDK

Error calling service activity?
> This module is designed to automatically turn on and off Flight mode, in order to clear DNS cache. However, this only work when SELinux is premissive. So just ignore this error message in `service.log`, and if you like, do turn on and off Flight mode manually.

Why I need turn on WIFI hotspot otherwise I cannot connect to Internet?
Why I cannot connect to proxy server while using **domain name**?
> It is a DNS issue. You need add `"sockopt": { "domainStrategy": "UseIP" }` to your proxy's `"streamSettings"`. By the way, this fix needs correct dns and routing configuration. If you don't know how to do, I suggest use IP address instead of domain name. Or use a Xray binary compiled with CGO enabled. Reference: [#12](https://github.com/CerteKim/Xray4Magisk/issues/12)

This module cause battery drain really quick.
> It might be a DNS issue, check `/data/adb/sing-box/run/error.log`.

GUI support?
> Not done yet.

Why not store config files in Internal Storage?
> For privacy. Some apps may read your data, check [Storage Isolation](https://sr.rikka.app/guide/)

## Contact
- ...


## sing-box

sing-box is a The universal proxy platform. See [sing-box](https://github.com/SagerNet/sing-box) for more information.



## License

[GNU GENERAL PUBLIC LICENSE Version 3 (GPLv3)](https://raw.githubusercontent.com/etnperlong/SingBox4Magisk/master/LICENSE)
