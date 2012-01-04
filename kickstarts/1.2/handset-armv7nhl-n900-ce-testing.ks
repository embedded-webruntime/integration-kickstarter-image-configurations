# -*-mic2-options-*- -f raw --save-kernel --arch=armv7nhl --record-pkgs=name --pkgmgr=yum --arch=armv7hl -*-mic2-options-*-
# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
part / --size=3600  --ondisk mmcblk0p --fstype=ext4

# This is not used currently. It is here because the /boot partition
# needs to be the partition number 3 for the u-boot usage.
part swap --size=8 --ondisk mmcblk0p --fstype=swap

# This partition is made so that u-boot can find the kernel
part /boot --size=32 --ondisk mmcblk0p --fstype=vfat

rootpw meego 
xconfig --startxonboot

desktop --autologinuser=meego  --defaultdesktop=DUI --session="/usr/bin/mcompositor"
user --name meego  --groups audio,video --password meego 

repo --name=oss-1.2-daily --baseurl=http://repo.meego.com/MeeGo/snapshots/stable/1.2.0.90/latest/repos/oss/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego --excludepkgs=pulseaudio-modules-n900,kernel-adaptation-n900,prelink
repo --name=non-oss-1.2-daily --baseurl=http://repo.meego.com/MeeGo/snapshots/stable/1.2.0.90/latest/repos/non-oss/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-testing --baseurl=http://repo.pub.meego.com/Project:/DE:/Trunk:/Testing/standard/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego

%packages

@MeeGo Compliance
@MeeGo Core
@MeeGo Base Development
@Minimal MeeGo X Window System
@X for Handsets
@MeeGo Handset Desktop
@MeeGo Handset Applications
@MeeGo Tablet Applications
@Nokia N900 Support
@Nokia N900 Proprietary Support

kernel-adaptation-n900

xorg-x11-utils-xev
meegotouch-theme-n900de
ce-backgrounds
plymouth-lite
meegotouch-demos
mce
mad-developer
libqtwebkit4
libqtwebkit-qmlwebkitplugin
libresource-client
python-qtmobility
shiboken
peregrine-plain-qml
info.vivainio.qatbowling
info.vivainio.qmlreddit
com.substanceofcode.kasvopus
mobilebrowser
mg-package-manager
meego-terminal
iotop
lynx
vcard-tracker-import
f-irc
qtflyingbus
qt-components
qt-components-base-icons
meego-pinquery
usb-moded
meego-handset-camera
meegotouchcp-usb
meegotouchcp-gprs
meegotouchcp-profiles
meegotouchcp-cellular
profiled
meego-ux-sharing-qml-ui
orientation-contextkit-sensor
meego-ux-appgrid
meego-ux-components
gst-nokia-camera
perf-adaptation-n900
usb-moded-config-n900
-corewatcher
-phonesim
-meegotouch-qt-style
-meegotouch-applifed
-sreadahead
-nokia-usb-networking
-meegocamera
-meegotouchcp-socialweb
-meego-handset-socialweb
-meego-handset-chat
-meegotouchcp-chat
-meegotouch-applauncherd
-meego-handset-icon-theme
%end

%post

# save a little bit of space at least...
rm -f /boot/initrd*

# make sure there aren't core files lying around
rm -f /core*

# Remove cursor from showing during startup BMC#14991
echo "xopts=-nocursor" >> /etc/sysconfig/uxlaunch

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --rebuilddb

# Normal bootchart is only 30 long so we use this to get longer bootchart during startup when needed.
cat > /sbin/bootchartd-long << EOF
#!/bin/sh
exec /sbin/bootchartd -n 4000
EOF
chmod +x /sbin/bootchartd-long

# Fix for https://bugs.meego.com/show_bug.cgi?id=15963
mkdir -p /usr/share/themes/base/meegotouch/
cp -rf /usr/share/themes/meego/meegotouch/dialer /usr/share/themes/base/meegotouch/

# Also some other apps need fixes for other themes than meego
cp -rf /usr/share/themes/meego/meegotouch/meegophotos /usr/share/themes/base/meegotouch/
cp -rf /usr/share/themes/meego/meegotouch/meegomusic /usr/share/themes/base/meegotouch/
cp -rf /usr/share/themes/meego/meegotouch/meegovideo /usr/share/themes/base/meegotouch/
# Hack to fix the plymouth based splash screen on N900
mv /usr/bin/ply-image /usr/bin/ply-image-real
cat > /usr/bin/ply-image << EOF
#!/bin/sh
echo 32 > /sys/class/graphics/fb0/bits_per_pixel
exec /usr/bin/ply-image-real $@
EOF
chmod +x /usr/bin/ply-image
# Prelink can reduce boot time
if [ -x /usr/sbin/prelink ]; then
    /usr/sbin/prelink -aRqm
fi


# We have some daemons that we do not need so lets disable them for now.
mv /usr/lib/applauncherd/libqtbooster.so /root/
mv /etc/xdg/autostart/msyncd.desktop /root/
# Set the default theme.
gconftool-2 --direct \
  --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
  -s -t string /meego/ux/theme 1024-600-10

# Show application view as default view.
gconftool-2 --direct \
  --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
  -s -t bool /meego/ux/ShowPanelsAsHome false

# Use dynamic rendering to reduce memory consumption on apps when in background.
gconftool-2 --direct \
  --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
  -s -t boolean /meego/ux/EnableDynamicRendering true
# Bug https://bugs.meego.com/show_bug.cgi?id=16394 was fixed but we don't have 
# icons in our theme for some of the apps so we need following cp for that...
cp -f /usr/share/themes/1024-600-10/icons/launchers/meego-app-* /usr/share/pixmaps/
XDG_ORIG=/etc/xdg/autostart/
DELAY_DEST=/etc/xdg/autostart-dui/

mkdir ${DELAY_DEST}
mv ${XDG_ORIG}/meego-im-uiserver.desktop ${DELAY_DEST}/002_meego-im-uiserver.desktop
mv ${XDG_ORIG}/dialer-prestart.desktop ${DELAY_DEST}/005_dialer-prestart.desktop
mv ${XDG_ORIG}/smsinit.desktop ${DELAY_DEST}/007_smsinit.desktop
mv ${XDG_ORIG}/messageserver.desktop ${DELAY_DEST}/011_messageserver.desktop
mv ${XDG_ORIG}/sample-media-install.desktop ${DELAY_DEST}/020_sample-media-install.desktop
mv ${XDG_ORIG}/peregrine-n900-force-ring-account.desktop ${DELAY_DEST}/025_peregrine-n900-force-ring-account.desktop
mv ${XDG_ORIG}/syncevo-dbus-server.desktop ${DELAY_DEST}/030_syncevo-dbus-server.desktop
mv ${XDG_ORIG}/tracker-miner-fs.desktop ${DELAY_DEST}/040_tracker-miner-fs.desktop
mv ${XDG_ORIG}/tracker-store.desktop ${DELAY_DEST}/040_tracker-store.desktop
mv ${XDG_ORIG}/mdecorator.desktop ${DELAY_DEST}/040_mdecorator.desktop
mv ${XDG_ORIG}/applauncherd.desktop ${DELAY_DEST}/050_applauncherd.desktop
mv ${XDG_ORIG}/vcard-tracker-import.desktop ${DELAY_DEST}/055_vcard-tracker-import.desktop
# Without this line the rpm don't get the architecture right.
echo -n 'armv7hl-meego-linux' > /etc/rpm/platform
 
# Also libzypp has problems in autodetecting the architecture so we force tha as well.
# https://bugs.meego.com/show_bug.cgi?id=11484
echo 'arch = armv7hl' >> /etc/zypp/zypp.conf

# Use eMMC swap partition as MeeGo swap as well.
# Because of the 2nd partition is swap for the partition numbering
# we can just change the current fstab entry to match the eMMC partition.
sed -i 's/mmcblk0p2/mmcblk1p3/g' /etc/fstab

# open serial line console for embedded system
echo "s0:235:respawn:/sbin/agetty -L 115200 ttyO2 vt100" >> /etc/inittab

# Set up proper target for libmeegotouch
Config_Src=`gconftool-2 --get-default-source`
gconftool-2 --direct --config-source $Config_Src \
  -s -t string /meegotouch/target/name N900
cat > /etc/powervr.ini << EOF
[default]
WSEGL_UseHWSync=1
ExternalZBufferMode=4
ParamBufferSize=1048576
[conform]
ExternalZBufferMode=2

[conform-cl]
ExternalZBufferMode=2

[GTF]
ExternalZBufferMode=2
EOF

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
