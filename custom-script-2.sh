#!/bin/bash
# Copyright (c) 2022-2023 Curious <https://www.curious.host>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
# 
# https://github.com/Curious-r/OpenWrtBuildWorkflows
# Description: Automatically check OpenWrt source code update and build it. No additional keys are required.
#-------------------------------------------------------------------------------------------------------
#
#
# Patching is generally recommended.
# # Here's a template for patching:
#touch example.patch
#cat>example.patch<<EOF
#patch content
#EOF
#git apply example.patch

function git_sparse_clone() {
  branch="$1" rurl="$2" localdir="$3" && shift 3
  #git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
  git clone -b $branch --single-branch --no-tags --depth 1 --filter=blob:none --no-checkout $rurl $localdir
  cd $localdir
  #git sparse-checkout init --cone
  #git sparse-checkout set $@
  git checkout $branch -- $@
  mv -n $@ ../
  cd ..
  rm -rf $localdir
  }
  
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#1. 修改默认IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

#2. web登陆密码从password修改为空
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

#3.固件版本号添加个人标识和日期
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "s/DISTRIB_DESCRIPTION='.*OpenWrt '/DISTRIB_DESCRIPTION='YaYa($(TZ=UTC-8 date +%Y.%m.%d))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "/DISTRIB_DESCRIPTION='*'/d" package/base-files/files/etc/openwrt_release
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && echo "DISTRIB_DESCRIPTION='YaYa($(TZ=UTC-8 date +%Y.%m.%d))@immortalwrt '" >> package/base-files/files/etc/openwrt_release

#4.编译的固件文件名添加日期
#sed -i 's/IMG_PREFIX:=$(VERSION_DIST_SANITIZED)/IMG_PREFIX:=$(shell TZ=UTC-8 date "+%Y%m%d")-$(VERSION_DIST_SANITIZED)/g' include/image.mk

#5.更换lede源码中自带argon主题&更换主题
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-argon && git clone -b master https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/themes/luci-theme-design && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-theme-design && mv -n luci-theme-design feeds/luci/themes/luci-theme-design
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/luci/applications/luci-app-design-config && git_sparse_clone main "https://github.com/fichenx/packages" "temp" luci-app-design-config && mv -n luci-theme-design feeds/luci/applications/luci-app-design-config
rm -rf package/feeds/luci/luci-theme-argon
rm -rf package/feeds/luci/luci-app-argon-config
rm -rf package/feeds/luci/luci-theme-infinityfreedom
rm -rf package/feeds/luci/luci/luci-theme-design
#rm -rf package/feeds/luci/luci-theme-opentopd
#rm -rf package/feeds/luci/luci-theme-neobird
git clone https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom.git package/feeds/luci/luci-theme-infinityfreedom
#git clone https://github.com/sirpdboy/luci-theme-opentopd.git package/feeds/luci/luci-theme-opentopd
#git clone https://github.com/thinktip/luci-theme-neobird.git package/feeds/luci/luci-theme-neobird
git clone https://github.com/SAENE/luci-theme-design.git package/feeds/luci/luci-theme-design
git clone -b master https://github.com/jerrykuku/luci-theme-argon.git package/feeds/luci/luci-theme-argon
git clone -b master https://github.com/jerrykuku/luci-app-argon-config.git package/feeds/luci/luci-app-argon-config
git clone -b js https://github.com/sirpdboy/luci-theme-kucat package/feeds/luci/luci-theme-kucat
git clone https://github.com/sirpdboy/luci-theme-kucat-config package/feeds/luci/luci-theme-kucat-config

#6.添加自动挂载磁盘脚本
#mkdir -p files/etc/hotplug.d/block && wget -O files/etc/hotplug.d/block/30-usbmount https://raw.githubusercontent.com/ficheny/P3TERX_Actions-OpenWrt/main/files/etc/hotplug.d/block/30-usbmount && chmod 755 files/etc/hotplug.d/block/30-usbmount

#7.修改主机名
#sed -i "s/hostname='OpenWrt'/hostname='Redmi-AX6'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='ImmortalWrt'/hostname='R2 Max for YaYa'/g" package/base-files/files/bin/config_generate

#8.修改插件位置
#sed -i '/sed -i "s\/services\/system\/g" \/usr\/lib\/lua\/luci\/controller\/cpufreq.lua/d'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/services/system/g" /usr/lib/lua/luci/controller/cpufreq.lua'  package/lean/default-settings/files/zzz-default-settings

#9.禁止Turbo ACC 网络加速修改net.bridge.bridge-nf-call-iptables的值为1(修改为1后旁路由需开启ip动态伪装，影响下行带宽)。
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 0/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& return 1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i sed -i "s/\\[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/\\#[ -d \\/sys\\/kernel\\/debug\\/ecm\\/ecm_nss_ipv4 \\] \\&\\& sysctl -w dev.nss.general.redirect=1/g" /etc/init.d/qca-nss-ecm'  package/lean/default-settings/files/zzz-default-settings
#sed -i '/exit 0/i /etc/init.d/qca-nss-ecm disable' package/lean/default-settings/files/zzz-default-settings

#10.为bypass添加redsocks2依赖。
#svn co https://github.com/fw876/helloworld/trunk/redsocks2 package/redsocks2

#修复 shadowsocksr-libev libopenssl-legacy 依赖问题
#sed -i 's/ +libopenssl-legacy//g' feeds/fichenx/shadowsocksr-libev/Makefile

#####design主题导航栏设置######
#sed -i 's/shadowsocksr/bypass/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|services/openclash|services/bypass|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's/system\/admin/docker\/containers/g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm
#sed -i 's|openclash.png|ssr.png|g' feeds/fichenx/luci-theme-design/luasrc/view/themes/design/header.htm


#修改默认主题
#修改默认主题
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon/root/etc/uci-defaults/30_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-argon-mod/root/etc/uci-defaults/90_luci-theme-argon
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-material/root/etc/uci-defaults/30_luci-theme-material
sed -i 's|set luci.main.mediaurlbase|#set luci.main.mediaurlbase|g' feeds/luci/themes/luci-theme-netgear/root/etc/uci-defaults/30_luci-theme-netgear
sed -i 's|luci-theme-bootstrap|luci-theme-design|g' feeds/luci/collections/luci/Makefile

#为lede源恢复mac80211v5.15.33驱动依赖kmod-qcom-qmi-helpers
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'define KernelPackage/qcom-qmi-helpers' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  SUBMENU:=$(OTHER_MENU)' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  TITLE:=Qualcomm QMI Helpers' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  KCONFIG:=CONFIG_QCOM_QMI_HELPERS' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  FILES:=$(LINUX_DIR)/drivers/soc/qcom/qmi_helpers.ko' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  AUTOLOAD:=$(call AutoProbe,qmi_helpers)' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'endef' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'define KernelPackage/qcom-qmi-helpers/description' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '  Qualcomm QMI Helpers' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo 'endef' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '' >> package/kernel/linux/modules/other.mk
# [ -e package/lean/default-settings/files/zzz-default-settings ] && echo '$(eval $(call KernelPackage,qcom-qmi-helpers))' >> package/kernel/linux/modules/other.mk


#更换msd_lite为最新版（immortalwrt源）
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/msd_lite
#[ -e package/lean/default-settings/files/zzz-default-settings ] && git_sparse_clone master https://github.com/immortalwrt/packages immortalwrt net/msd_lite && mv -n msd_lite feeds/packages/net/msd_lite

#golang
#rm -rf feeds/packages/lang/golang
#cp -rf $GITHUB_WORKSPACE/general/golang feeds/packages/lang/golang

#为immortalwrt添加turboacc
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

#为immortalwrt添加luci-app-mwan3helper-chinaroute（MWAN3 分流助手）
#[ ! -e package/lean/default-settings/files/zzz-default-settings ] && git clone -b main https://github.com/padavanonly/luci-app-mwan3helper-chinaroute package/luci-app-mwan3helper-chinaroute

#为immortalwrt添加luci-theme-design
#[ ! -e package/lean/default-settings/files/zzz-default-settings ] && git clone -b js https://github.com/papagaye744/luci-theme-design package/luci-theme-design

#更换旧版lede代码中的ath11k-firmware源（旧源已失效）
#[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf package/firmware/ath11k-firmware/Makefile
#[ -e package/lean/default-settings/files/zzz-default-settings ] && cp -rf $GITHUB_WORKSPACE/backup/AX6/package/firmware/ath11k-firmware/Makefile package/firmware/ath11k-firmware/Makefile

#更换miniupnpd为最新版（immortalwrt源）
[ -e package/lean/default-settings/files/zzz-default-settings ] && rm -rf feeds/packages/net/miniupnpd
[ -e package/lean/default-settings/files/zzz-default-settings ] && git_sparse_clone master https://github.com/immortalwrt/packages immortalwrt net/miniupnpd && mv -n miniupnpd feeds/packages/net/miniupnpd

#替换luci-app-socat为https://github.com/chenmozhijin/luci-app-socat
#rm -rf feeds/luci/applications/luci-app-socat
#git_sparse_clone main "https://github.com/chenmozhijin/luci-app-socat" "temp" luci-app-socat && mv -n luci-app-socat package/luci-app-socat

./scripts/feeds update -a
./scripts/feeds install -a
