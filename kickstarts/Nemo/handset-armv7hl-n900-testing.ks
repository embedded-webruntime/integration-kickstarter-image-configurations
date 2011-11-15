# -*-mic2-options-*- -f raw --save-kernel --arch=armv7hl --record-pkgs=name --pkgmgr=yum -*-mic2-options-*-

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

user --name meego  --groups audio,video --password meego 

repo --name=mer-core-armv7hl --baseurl=http://releases.merproject.org/releases/latest/builds/armv7hl/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-adaptation-n9xx-common --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/N9xx-common/Mer_Core_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-adaptation-n900 --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/N900/CE_Adaptation_N9xx-common_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-utils-armv7hl --baseurl=http://repo.pub.meego.com/CE:/Utils/Mer_Core_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-mw-shared-armv7hl --baseurl=http://repo.pub.meego.com/CE:/MW:/Shared/Mer_Core_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-mw-mtf-armv7hl --baseurl=http://repo.pub.meego.com/CE:/MW:/MTF/CE_MW_Shared_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-ux-mtf-armv7hl --baseurl=http://repo.pub.meego.com/CE:/UX:/MTF/CE_MW_MTF_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-apps-armv7hl --baseurl=http://repo.pub.meego.com/CE:/Apps/CE_MW_Shared_armv7hl/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego

%packages

@Mer Core
@Mer Graphics Common
@Mer Connectivity
@MTF Handset UX
@MTF Apps
@Nemo Middleware Shared
@Nemo Utils
@Nemo Apps
@Nokia N900 Support
@Nokia N900 Proprietary Support

kernel-adaptation-n900

openssh-clients
openssh-server
xterm
ce-backgrounds
plymouth-lite
vim-enhanced
usb-moded-config-n900
policy-settings-basic-n900
mce
meego-handset-camera
xorg-x11-xauth
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
# We can run the prelink only with qemu version 0.14 and newer.
qemu-arm-static -version | grep "0\.14"

if [ "x$?" == "x0" ]; then
    echo "QEMU version 0.14 running prelink."
    # Prelink can reduce boot time
    if [ -x /usr/sbin/prelink ]; then
        /usr/sbin/prelink -aRqm
    fi
else
    echo "QEMU version is not 0.14 so not running prelink."
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
# Without this line the rpm don't get the architecture right.
echo -n 'armv7hl-meego-linux' > /etc/rpm/platform
 
# Also libzypp has problems in autodetecting the architecture so we force tha as well.
# https://bugs.meego.com/show_bug.cgi?id=11484
echo 'arch = armv7hl' >> /etc/zypp/zypp.conf

# Use eMMC swap partition as MeeGo swap as well.
# Because of the 2nd partition is swap for the partition numbering
# we can just change the current fstab entry to match the eMMC partition.
sed -i 's/mmcblk0p2/mmcblk1p3/g' /etc/fstab

# Set up proper target for libmeegotouch
Config_Src=`gconftool-2 --get-default-source`
gconftool-2 --direct --config-source $Config_Src \
  -s -t string /meegotouch/target/name N900
# This causes problems with the bme in N900 images so removing for now.
rm -f /lib/modules/*/kernel/drivers/power/bq27x00_battery.ko
# Wait a bit more than the default 5s when starting application.
mkdir -p /etc/xdg/mcompositor/
echo "close-timeout-ms 15000;" > /etc/xdg/mcompositor/new-mcompositor.conf


%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
