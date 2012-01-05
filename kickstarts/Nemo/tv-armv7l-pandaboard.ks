# -*-mic2-options-*- -f raw --record-pkgs=name --pkgmgr=yum --arch=armv7l -*-mic2-options-*-
# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
part /boot --size=32 --ondisk mmcblk0p --fstype=vfat --active
part / --size=3600  --ondisk mmcblk0p --fstype=ext3

rootpw meego 

user --name meego  --groups audio,video --password meego 

repo --name=mer-core --baseurl=http://releases.merproject.org/releases/latest/builds/armv7l/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-adaptation-pandaboard --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/PandaBoard/Mer_Core_armv7l/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-utils --baseurl=http://repo.pub.meego.com/CE:/Utils/Mer_Core_armv7l/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-mw-shared --baseurl=http://repo.pub.meego.com/CE:/MW:/Shared/Mer_Core_armv7l/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-ux-xbmc --baseurl=http://repo.pub.meego.com/home:/sage:/xbmc/CE_UX_XBMC_armv7l/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-apps --baseurl=http://repo.pub.meego.com/CE:/Apps/CE_MW_Shared_armv7l/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego

%packages

@Mer Core
@Mer Graphics Common
@Mer Connectivity

kernel-adaptation-pandaboard

xorg-x11-server-Xorg-setuid
pulseaudio-module-x11
xorg-x11-xauth
pvr-omap4
pvr-omap4-kernel
pvr-omap4-libEGL
pvr-omap4-libGLESv1
pvr-omap4-libGLESv2
u-boot-omap4panda
x-loader-omap4panda
linux-firmware-ti-connectivity
xbmc
openssh-clients
openssh-server
ce-backgrounds
plymouth-lite
vim-enhanced
xterm
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


# Set symlink pointing to .desktop file 
ln -sf XBMC.desktop /usr/share/xsessions/default.desktop


%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
