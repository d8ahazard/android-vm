#!/bin/sh

#Stop Logging Services

/sbin/service rsyslog stop
/sbin/service auditd stop

#Remove Old Kernels

/bin/package-cleanup --oldkernels --count=1

#Clean out yum

/usr/bin/yum clean all

#Rotate logs, clean out old

/usr/sbin/logrotate –f /etc/logrotate.conf
/bin/rm –f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda

#Truncate Audit Logs

/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

#Remove the udev persistent device rules.
/bin/rm -f /etc/udev/rules.d/70*

#Remove template MAC and UUIDs

/bin/sed -i ‘/^(HWADDR|UUID)=/d’ /etc/sysconfig/network-scripts/ifcfg-eth0

#Clean out /tmp

/bin/rm –rf /tmp/*
/bin/rm –rf /var/tmp/*

#Remove SSH host keys

/bin/rm –f /etc/ssh/*key*

#Remove root user's shell history, SSH history, etc.
/bin/rm -f ~root/.bash_history
unset HISTFILE
/bin/rm -rf ~root/.ssh/
/bin/rm -f ~root/anaconda-ks.cfg

Zero out all free space, re-thin VM
# Determine the version of RHEL
COND=`grep -i Taroon /etc/redhat-release`
if [ "$COND" = "" ]; then
        export PREFIX="/usr/sbin"
else
        export PREFIX="/sbin"
fi

FileSystem=`grep ext /etc/mtab| awk -F" " '{ print $2 }'`

for i in $FileSystem
do
        echo $i
        number=`df -B 512 $i | awk -F" " '{print $3}' | grep -v Used`
        echo $number
        percent=$(echo "scale=0; $number * 98 / 100" | bc )
        echo $percent
        dd count=`echo $percent` if=/dev/zero of=`echo $i`/zf
        /bin/sync
        sleep 15
        rm -f $i/zf
done

VolumeGroup=`$PREFIX/vgdisplay | grep Name | awk -F" " '{ print $3 }'`

for j in $VolumeGroup
do
        echo $j
        $PREFIX/lvcreate -l `$PREFIX/vgdisplay $j | grep Free | awk -F" " '{ print $5 }'` -n zero $j
        if [ -a /dev/$j/zero ]; then
                cat /dev/zero > /dev/$j/zero
                /bin/sync
                sleep 15
                $PREFIX/lvremove -f /dev/$j/zero
        fi
done