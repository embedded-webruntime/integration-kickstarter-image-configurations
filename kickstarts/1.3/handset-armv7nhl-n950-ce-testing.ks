# -*-mic2-options-*- -f fs --compress-disk-image=tar.bz2 --save-kernel --arch=armv7hl --record-pkgs=name --pkgmgr=yum --arch=armv7hl -*-mic2-options-*-
# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
part / --size 3500 --ondisk sda --fstype=ext3
rootpw meego 

user --name meego  --groups audio,video --password meego 

repo --name=oss-trunk-testing-daily --baseurl=http://download.meego.com/snapshots/latest-testing/repos/oss/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=mtf-trunk-testing --baseurl=http://repo.pub.meego.com/Project:/MTF/MeeGo_Trunk_Testing/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-1.3-testing --baseurl=http://repo.pub.meego.com/Project:/DE:/Trunk:/Testing:/1.3/standard/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=non-oss-trunk-testing-daily-n950 --baseurl=http://download.meego.com/snapshots/latest-testing/repos/non-oss/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego --excludepkgs=ti-omap3-sgx*,xorg-x11-drv-fbdev-sgx*,bme*,libbmeipc*
repo --name=devel-devices-n950-trunk-testing --baseurl=http://download.meego.com/live/devel:/devices:/n900:/n950/Trunk_Testing/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego

%packages

@Compliance
@Core
@Base Development
@Common User Interface
@MTF Handset UX
@Community Edition Base
@Community Edition Libraries
@Samples and Demos
@Nokia N950 Support
@Nokia N950 Proprietary Support

kernel-adaptation-n950

basesystem
usb-moded-config-n950-n9
omap-update-display
-syncevolution
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


# Create a session file for MTF.
cat > /usr/share/xsessions/X-MEEGO-HS.desktop << EOF
[Desktop Entry]
Version=1.0
Name=mtf compositor session
Exec=/usr/bin/mcompositor
Type=Application
EOF

# Set symlink pointing to .desktop file 
ln -sf X-MEEGO-HS.desktop /usr/share/xsessions/default.desktop
# Mask corewatcher.service to disable it on boot.
# Do "rm /etc/systemd/system/corewatcher.service" to re-enable it.
ln -s /dev/null /etc/systemd/system/corewatcher.service
# ohm outputs "No protocol specified" message couple of times a second, because of videoep module.
# See: https://bugs.meego.com/show_bug.cgi?id=22887
sed -i 's!ModulesBanned=!ModulesBanned=videoep!g' /etc/ohm/modules.ini
# Tune tracker a bit.
sed -i "s|Exec=|Exec=/usr/bin/ionice -c 3 -n 7 |g" /etc/xdg/autostart/tracker-miner-fs.desktop

# Without this line the rpm don't get the architecture right.
echo -n 'armv7hl-meego-linux' > /etc/rpm/platform
 
# Also libzypp has problems in autodetecting the architecture so we force tha as well.
# https://bugs.meego.com/show_bug.cgi?id=11484
echo 'arch = armv7hl' >> /etc/zypp/zypp.conf

# Set up proper target for libmeegotouch
Config_Src=`gconftool-2 --get-default-source`
gconftool-2 --direct --config-source $Config_Src \
  -s -t string /meegotouch/target/name N950
# N950: Get all log messages to serial console
sed -i 's!/sbin/redirect-console!#/sbin/redirect-console!' /etc/rc.d/rc

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
