# -*-mic2-options-*- -f livecd --arch=i586 --record-pkgs=name --pkgmgr=yum -*-mic2-options-*-

# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
part / --size 3000 --ondisk sda --fstype=ext3
rootpw meego 
xconfig --startxonboot
bootloader  --timeout=0   --menu="autoinst:Installation:systemd.unit=installer-shell.service"

user --name meego  --groups audio,video --password meego 

repo --name=mer-core-i586 --baseurl=http://monster.tspre.org/~merreleases/releases/0.20111020.1/builds/i586/packages/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-adaptation-x86-generic --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/x86-generic/Mer_Core_i586 --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-utils-i586 --baseurl=http://repo.pub.meego.com/CE:/Utils/Mer_Core_i586/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-mw-shared-i586 --baseurl=http://repo.pub.meego.com/CE:/MW:/Shared/Mer_Core_i586/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-ux-mtf-i586 --baseurl=http://repo.pub.meego.com/CE:/UX:/MTF/CE_MW_Shared_i586/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego
repo --name=ce-apps-i586 --baseurl=http://repo.pub.meego.com/CE:/Apps/CE_MW_Shared_i586/ --save --debuginfo --source --gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-meego

%packages

@Mer Core
@Mer Graphics Common
@Mer Connectivity
@Mer Minimal Xorg
@MTF Handset UX
@Nemo Utils
@Nemo Apps
@Intel x86 Generic Support

kernel-adaptation-pc

openssh-clients
openssh-server
xterm
ce-backgrounds
plymouth-lite
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
# ohm outputs "No protocol specified" message couple of times a second, because of videoep module.
# See: https://bugs.meego.com/show_bug.cgi?id=22887
sed -i 's!ModulesBanned=!ModulesBanned=videoep!g' /etc/ohm/modules.ini

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
