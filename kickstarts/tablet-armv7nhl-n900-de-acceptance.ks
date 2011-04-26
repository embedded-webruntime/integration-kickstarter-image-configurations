# -*-mic2-options-*- -f raw --save-kernel --arch=armv7nhl --record-pkgs=name -*-mic2-options-*-

# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
part / --size=3600  --ondisk mmcblk0p --fstype=ext3

# This is not used currently. It is here because the /boot partition
# needs to be the partition number 3 for the u-boot usage.
part swap --size=8 --ondisk mmcblk0p --fstype=swap

# This partition is made so that u-boot can find the kernel
part /boot --size=32 --ondisk mmcblk0p --fstype=vfat

rootpw meego 
xconfig --startxonboot
desktop --autologinuser=meego  --defaultdesktop=DUI --session="/usr/bin/mcompositor"
user --name meego  --groups audio,video --password meego 

repo --name=oss-trunk-daily --baseurl=http://download.meego.com/trunk-daily/builds/trunk/latest/repos/oss/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego --excludepkgs=pulseaudio,pulseaudio-module-x11,pulseaudio-startup,pulseaudio-policy-enforcement,pulseaudio-modules-*,kernel-adaptation-n900
repo --name=non-oss-trunk-daily --baseurl=http://download.meego.com/trunk-daily/builds/trunk/latest/repos/non-oss/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=de-testing --baseurl=http://repo.pub.meego.com/Project:/DE:/Trunk:/Testing/standard/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=de-tablet-devel --baseurl=http://repo.pub.meego.com/Project:/DE:/Devel:/Tablet/standard/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego

%packages

@MeeGo Compliance
@MeeGo Core
@MeeGo Base Development
@Minimal MeeGo X Window System
@Nokia N900 Support
@Nokia N900 Proprietary Support
@MeeGo Tablet
@MeeGo Tablet Applications

kernel-adaptation-n900

xorg-x11-utils-xev
-phonesim
meegotouch-theme-n900de
peregrine-plain-qml
generic-backgrounds
plymouth-lite
meegotouch-demos
-corewatcher
mce
meego-ux-components
meego-handset-dialer
meego-handset-sms
gst-plugins-camera
-meego-app-browser
-meego-app-browser-ffmpeg-oss
fennec-qt
%end

%post

# save a little bit of space at least...
rm -f /boot/initrd*

# make sure there aren't core files lying around
rm -f /core*

# Remove cursor from showing during startup BMC#14991
echo "xopts=-nocursor" >> /etc/sysconfig/uxlaunch

# open serial line console for embedded system
echo "s0:235:respawn:/sbin/agetty -L 115200 ttyO2 vt100" >> /etc/inittab

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --rebuilddb

# Set up proper target for libmeegotouch
Config_Src=`gconftool-2 --get-default-source`
gconftool-2 --direct --config-source $Config_Src \
  -s -t string /meegotouch/target/name N900
# Normal bootchart is only 30 long so we use this to get longer bootchart during startup when needed.
cat > /sbin/bootchartd-long << EOF
#!/bin/sh
exec /sbin/bootchartd -n 4000
EOF
chmod +x /sbin/bootchartd-long

# Use eMMC swap partition as MeeGo swap as well.
# Because of the 2nd partition is swap for the partition numbering
# we can just change the current fstab entry to match the eMMC partition.
sed -i 's/mmcblk0p2/mmcblk1p3/g' /etc/fstab

# Without this line the rpm don't get the architecture right.
echo -n 'armv7hl-meego-linux' > /etc/rpm/platform
 
# Also libzypp has problems in autodetecting the architecture so we force tha as well.
# https://bugs.meego.com/show_bug.cgi?id=11484
echo 'arch = armv7hl' >> /etc/zypp/zypp.conf

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
# Remove some unwanted "engineering english" translations.
rm -f /usr/share/l10n/meegotouch/recovery*
gconftool-2 --direct \
  --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
  -s -t string /meego/ux/theme 1024-600-10

gconftool-2 --direct \
  --config-source xml:readwrite:/etc/gconf/gconf.xml.defaults \
  -s -t bool /meego/ux/ShowPanelsAsHome false
# Workaround for BMC#15039 / QTMOBILITY-1385, MeeGo/Maemo6 sensor plugin
# doesn't return sane values on startup
rm /usr/lib/qt4/plugins/sensors/libqtsensors_meego.so

# Set the homekey for N900 through the gconf.
gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory \
  -s -t string /meego/ux/HomeKey XF86WebCam

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
