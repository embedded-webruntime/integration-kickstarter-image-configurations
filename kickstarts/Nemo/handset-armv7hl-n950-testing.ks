# -*-mic2-options-*- -f fs --compress-disk-image=tar.bz2 --save-kernel --record-pkgs=name --pkgmgr=yum --arch=armv7hl -*-mic2-options-*-
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

repo --name=mer-core --baseurl=http://releases.merproject.org/releases/latest/builds/armv7hl/packages/ --save --debuginfo --source
repo --name=ce-utils --baseurl=http://repo.pub.meego.com/CE:/Utils/Mer_Core_armv7hl/ --save --debuginfo --source
repo --name=ce-mw-shared --baseurl=http://repo.pub.meego.com/CE:/MW:/Shared/Mer_Core_armv7hl/ --save --debuginfo --source
repo --name=ce-mw-mtf --baseurl=http://repo.pub.meego.com/CE:/MW:/MTF/CE_MW_Shared_armv7hl/ --save --debuginfo --source
repo --name=ce-apps --baseurl=http://repo.pub.meego.com/CE:/Apps/CE_MW_Shared_armv7hl/ --save --debuginfo --source
repo --name=ce-apps-mtf --baseurl=http://repo.pub.meego.com/CE:/Apps:/MTF/CE_MW_MTF_armv7hl/ --save --debuginfo --source
repo --name=ce-ux-mtf --baseurl=http://repo.pub.meego.com/CE:/UX:/MTF/CE_MW_MTF_armv7hl/ --save --debuginfo --source
repo --name=ce-mtf-tracker-related-apps --baseurl=http://repo.pub.meego.com/Project:/MTF:/Tracker/CE_UX_MTF_armv7hl/ --save --debuginfo --source
repo --name=ce-adaptation-n9xx-common --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/N9xx-common/Mer_Core_armv7hl/ --save --debuginfo --source
repo --name=ce-adaptation-n950-n9 --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/N950-N9/CE_Adaptation_N9xx-common_armv7hl/ --save --debuginfo --source

%packages

@Mer Core
@Mer Graphics Common
@Mer Connectivity
@Nemo Middleware Shared
@Nemo Utils
@Nemo Apps
@Nemo Apps MTF
@MTF Handset UX
@MTF Tracker Related Apps
@Nokia N950 Support
@Nokia N950 Proprietary Support

kernel-adaptation-n950

openssh-clients
openssh-server
xterm
ce-backgrounds
plymouth-lite
vim-enhanced
policy-settings-basic-n950
mce
meego-handset-camera
xorg-x11-xauth
usb-moded-config-n950-n9
contextkit-maemo-mce
%end

%post

# save a little bit of space at least...
rm -f /boot/initrd*

# make sure there aren't core files lying around
rm -f /core*

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --rebuilddb

# Prelink can reduce boot time
if [ -x /usr/sbin/prelink ]; then
    /usr/sbin/prelink -aRqm
fi


# Hack to fix the plymouth based splash screen on N900
mv /usr/bin/ply-image /usr/bin/ply-image-real
cat > /usr/bin/ply-image << EOF
#!/bin/sh
echo 32 > /sys/class/graphics/fb0/bits_per_pixel
exec /usr/bin/ply-image-real $@
EOF
chmod +x /usr/bin/ply-image
# Remove cursor from showing during startup BMC#14991
echo "xopts=-nocursor" >> /etc/sysconfig/uxlaunch

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

# Set up proper target for libmeegotouch
Config_Src=`gconftool-2 --get-default-source`
gconftool-2 --direct --config-source $Config_Src \
  -s -t string /meegotouch/target/name N950
# Wait a bit more than the default 5s when starting application.
mkdir -p /etc/xdg/mcompositor/
echo "close-timeout-ms 15000;" > /etc/xdg/mcompositor/new-mcompositor.conf


%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
