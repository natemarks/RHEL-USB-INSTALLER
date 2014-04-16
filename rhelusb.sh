#!/bin/sh
# requires the packages  mkisofs and syslinux
# change the ISOCD to the location of a valid iso file
ISOCD="/var/www/html/centos/custom/CentOS-6.5-x86_64-minimal.iso"
ISOCDMOUNT="/tmp/rhelboot"
ISOMODPATH="/tmp/rhelmodboot"
# replace /dev/XXXXXXXXXX with the correct device for the usb stick.  if you're not sure what it is, 
# run tail -f /var/log/dmesg then connect the usb device. you'll see the system assign a device
# name to it.  On my system its sdb
# USBDEVICE="/dev/sdb"
USBDEVICE="/dev/XXXXXXXXXX"
USBMOUNT="/tmp/rhelusb"
ISOIMGMOUNT="/tmp/rheliso"

function usage {
        echo "$0 : Prints out the usage of the script"
        echo "$0 build : creates some directories containing (among other things)  the isolinux.cfg file"
        echo "    that must be modified to customize the boot menu for the USB. these directories are used"
        echo "    by the create process to create the /tmp/bootmod.iso"
        echo "$0 create : uses modified isolinux stuff to create the /tmp/bootmod.iso and runs isohybrid"
        echo "$0 burn : burns the bootmod.iso to the USB creating partition 1.  MAKE SURE TO DELETE ALL "
        echo "    PARTITIONS BEFORE running $0 burn.  After you run it, create a second partiton on the USB"
        echo "    formatted ext4.  that will contain the repo data and the kickstart files"
        echo "$0 copy : this step copies the image files and creates an empty kickstart file"
        }

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
        isohybrid /tmp/bootmod.iso
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
        cp $ISOCD $USBMOUNT
}
if [ $# != 1 ];
then
    usage
    exit
fi

if [ $1 != "build" ] &&  [ $1 != "create" ] && [ $1 != "burn" ] && [ $1 != "copy" ];
then
    usage
    exit
fi

case $1 in
    build )
        createmoddir ;;

    create )
        createiso ;;
    burn )
        writeisotousb ;;
    copy )
        copyimagestoext4 ;;
    usage )
        usage ;;
esac
