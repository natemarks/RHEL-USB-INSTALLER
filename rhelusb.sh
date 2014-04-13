#!/bin/sh
ISOCD="/var/www/html/centos/custom/CentOS-6.5-x86_64-minimal.iso"
ISOCDMOUNT="/tmp/rhelboot"
ISOMODPATH="/tmp/rhelmodboot"
USBDEVICE="/dev/sdb"
USBMOUNT="/tmp/rhelusb"
ISOIMGMOUNT="/tmp/rheliso"

function createmoddir {
        mkdir $ISOCDMOUNT $ISOMODPATH
        mount -o loop $ISOCD $ISOCDMOUNT
        cp -pr $ISOCDMOUNT/* $ISOMODPATH
        umount $ISOCDMOUNT
    }
function createiso {
        cd $ISOMODPATH
        mkisofs -o /tmp/bootmod.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -V "RHEL-6-USB-INSTALLER" -T .
        isohybrid /tmp/bootmod.iso
    }
function writeisotousb {
        dd if=/tmp/bootmod.iso of=$USBDEVICE
    }
function copyimagestoext4 {
        mkdir -p $ISOIMGMOUNT $USBMOUNT
        mount $USBDEVICE2 $USBMOUNT
        mount -o loop $ISOCD $ISOIMGMOUNT
        mkdir -p $USBMOUNT/images
        cp $ISOIMGMOUNT/images/install.img $USBMOUNT/images
        if [ -f $ISOIMGMOUNT/images/product.img ];
        then
            cp $ISOIMGMOUNT/images/product.img $USBMOUNT/images
        fi
        mkdir $USBMOUNT/workstation

        if [ ! -f $USBMOUNT/workstation/ks.cfg ];
        then
            echo "#EMPTY KICKSTART" >> $USBMOUNT/workstation/ks.cfg
        fi
#        umount $USBMOUNT
}
case $1 in
    build )
        createmoddir ;;

    create )
        createiso ;;
    burn )
        writeisotousb ;;
    copy )
        copyimagestoext4 ;;
esac
