#####################
# sing-box Customization
#####################

SKIPUNZIP=1
ASH_STANDALONE=1

if [ $BOOTMODE ! = true ]; then
  abort "Error: Please install in Magisk Manager"
fi

# migrate old configuration
if [ -d "/data/sing-box" ]; then
  ui_print "- Old configuration detected, migrating."
  if [ -d "/data/adb/sing-box" ]; then
    abort "Please remove \"/data/adb/sing-box\" first!"
  fi
  mv /data/sing-box/ /data/adb/sing-box/
fi

# prepare sing-box execute environment
ui_print "- Prepare sing-box execute environment."
mkdir -p /data/adb/sing-box
mkdir -p /data/adb/sing-box/run
mkdir -p /data/adb/sing-box/bin
mkdir -p /data/adb/sing-box/confs
mkdir -p /data/adb/sing-box/scripts

download_singbox_tar="/data/adb/sing-box/run/sing-box-core.tar.gz"
download_singbox_geoip="/data/adb/sing-box/run/geoip.db"
download_singbox_geosite="/data/adb/sing-box/run/geosite.db"
custom="/sdcard/Download/sing-box-core.tar.gz"

if [ -f "${custom}" ]; then
  cp "${custom}" "${download_singbox_tar}"
  ui_print "Info: Custom sing-box core found, starting installer"
  latest_singbox_version=custom
else
  # download latest sing-box core from official link
  ui_print "- Connect official sing-box download link."

  official_singbox_link="https://github.com/SagerNet/sing-box/releases"

  if [ -x "$(which wget)" ]; then
    latest_singbox_version=$(wget -qO- https://api.github.com/repos/SagerNet/sing-box/releases | grep -m 1 "tag_name" | grep -o "v.*" | sed -e 's/v//g' -e 's/"//g' -e 's/,//g')
  elif [ -x "$(which curl)" ]; then
    latest_singbox_version=$(curl -ks https://api.github.com/repos/SagerNet/sing-box/releases | grep -m 1 "tag_name" | grep -o "v.*" | sed -e 's/v//g' -e 's/"//g' -e 's/,//g')
  elif [ -x "/data/adb/magisk/busybox" ]; then
    latest_singbox_version=$(/data/adb/magisk/busybox wget -qO- https://api.github.com/repos/SagerNet/sing-box/releases | grep -m 1 "tag_name" | grep -o "v.*" | sed -e 's/v//g' -e 's/"//g' -e 's/,//g')
  else
    ui_print "Error: Could not find curl or wget, please install one."
    abort
  fi

  if [ "${latest_singbox_version}" = "" ]; then
    ui_print "Error: Connect official sing-box download link failed."
    ui_print "Tips: You can download sing-box core manually,"
    ui_print "      rename it into sing-box-core.tar.gz,"
    ui_print "      and put it in /sdcard/Download"
    abort
  fi

  case "${ARCH}" in
    arm)
      version="sing-box-${latest_singbox_version}-linux-armv7"
      ;;
    arm64)
      version="sing-box-${latest_singbox_version}-linux-arm64"
      ;;
    x64)
      version="sing-box-${latest_singbox_version}-linux-amd64"
      ;;
  esac

  ui_print "- Download latest sing-box core ${latest_singbox_version}-${ARCH}"

  if [ -x "$(which wget)" ]; then
    wget "${official_singbox_link}/download/v${latest_singbox_version}/${version}.tar.gz" -O "${download_singbox_tar}" >&2
  elif [ -x "$(which curl)" ]; then
    curl "${official_singbox_link}/download/v${latest_singbox_version}/${version}.tar.gz" -kLo "${download_singbox_tar}" >&2
  elif [ -x "/data/adb/magisk/busybox" ]; then
    /data/adb/magisk/busybox wget "${official_singbox_link}/download/v${latest_singbox_version}/${version}.tar.gz" -O "${download_singbox_tar}" >&2
  else
    ui_print "Error: Could not find curl or wget, please install one."
    abort
  fi

  ui_print "- Download latest sing-box resources"
  if [ -x "$(which wget)" ]; then
    wget "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db" -O "${download_singbox_geoip}" >&2
    wget "https://github.com/SagerNet/sing-geoip/releases/latest/download/geosite.db" -O "${download_singbox_geosite}" >&2
  elif [ -x "$(which curl)" ]; then
    curl "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db" -kLo "${download_singbox_geoip}" >&2
    curl "https://github.com/SagerNet/sing-geoip/releases/latest/download/geosite.db" -kLo "${download_singbox_geosite}" >&2
  elif [ -x "/data/adb/magisk/busybox" ]; then
    /data/adb/magisk/busybox wget "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db" -O "${download_singbox_geoip}" >&2
    /data/adb/magisk/busybox wget "https://github.com/SagerNet/sing-geoip/releases/latest/download/geosite.db" -O "${download_singbox_geosite}" >&2
  else
    ui_print "Error: Could not find curl or wget, please install one."
    abort
  fi

  if [ "$?" != "0" ]; then
    ui_print "Error: Download sing-box core failed."
    ui_print "Tips: You can download sing-box core manually,"
    ui_print "      rename it into sing-box-core.tar.gz,"
    ui_print "      and put it in /sdcard/Download"
    abort
  fi
fi

# install scripts
unzip -j -o "${ZIPFILE}" 'sing-box/scripts/*' -d /data/adb/sing-box/scripts >&2
if [ ! -d /data/adb/service.d ]; then
  mkdir -p /data/adb/service.d
fi
unzip -j -o "${ZIPFILE}" 'singbox4magisk_service.sh' -d /data/adb/service.d >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2
set_perm /data/adb/sing-box/scripts/sing-box.service 0 0 0755

# stop service
/data/adb/sing-box/scripts/sing-box.service stop

# install sing-box execute file
ui_print "- Install sing-box core $ARCH execute files"
tar -xOzf "${download_singbox_tar}" "${version}/LICENSE" > /data/adb/sing-box/bin/LICENSE
tar -xOzf "${download_singbox_tar}" "${version}/sing-box" > /data/adb/sing-box/bin/sing-box
rm "${download_singbox_tar}"

# start service
/data/adb/sing-box/scripts/sing-box.service start

# copy sing-box data and config
ui_print "- Copy sing-box config and data files"
[ -f /data/adb/sing-box/confs/config.json ] ||
  unzip -j -o "${ZIPFILE}" "sing-box/etc/confs/*" -d /data/adb/sing-box/confs >&2
[ -f /data/adb/sing-box/appid.list ] ||
  echo "ALL" >/data/adb/sing-box/appid.list
[ -f /data/adb/sing-box/ignore_out.list ] ||
  touch /data/adb/sing-box/ignore_out.list
[ -f /data/adb/sing-box/ap.list ] ||
  #temporary fix for Redmi K50, need a generic fix for devices imcompatible with the entry "wlan+" here and instead replace with "ap+"
  [ "$(getprop ro.product.device)" = "rubens" ] && echo "ap+" >/data/adb/sing-box/ap.list || echo "wlan+" >/data/adb/sing-box/ap.list
[ -f /data/adb/sing-box/ipv6 ] ||
  echo "enable" >/data/adb/sing-box/ipv6

# generate module.prop
ui_print "- Generate module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=singbox4magisk" >$MODPATH/module.prop
echo "name=SingBox4Magisk" >>$MODPATH/module.prop
echo -n "module_version=v1.6.2, core_version=v" >>$MODPATH/module.prop
echo ${latest_singbox_version} >>$MODPATH/module.prop
echo "versionCode=20220904" >>$MODPATH/module.prop
echo "author=Asterisk4Magisk, etnperlong" >>$MODPATH/module.prop
echo "description=sing-box core with service scripts for Android" >>$MODPATH/module.prop

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm /data/adb/service.d/singbox4magisk_service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm_recursive /data/adb/sing-box/scripts 0 0 0755
set_perm /data/adb/sing-box 0 0 0755
set_perm_recursive /data/adb/sing-box/bin 0 0 0755
#fix "set_perm_recursive  /data/adb/sing-box/scripts" not working on some phones. It didn't work on my Oneplus 7 pro and Remi K50.
chmod ugo+x /data/adb/sing-box/scripts/*
