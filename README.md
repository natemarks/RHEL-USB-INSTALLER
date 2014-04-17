RHEL-USB-INSTALLER
==================

(WARNING:  this will delete a drive!!) 

This script that helps me set up  a USB stick to install RHEL 


This script is not based on my own work, but entirely take from.  I strongly encourage  you to read through it for further explanation of the procedure.
http://slashsarc.com/2013/12/make-a-rhel-6-bootable-usb-installer/

Thanks to slashsarc for this work.  I just copied  his stuff into a shell script because I'll probably be messing with my usb installer sticks pretty often.

Also note that at one point the CentOS 6.4 host I was using got fussy about rereading the partition talbes on my usb.  a restart cleared up the problem, but not before I wasted an hour trying to figure out what I had done wrong:)


the genereal steps the script support are:

build: This is the first part.  It uses an RHEL compatibile minimal or normal ISO to create the iso directory tree on disk so the isolinux.cfg can be modified.

create:  once the iso data is customized, we create the ISO file that will be written to the first partition on the USB

###between create and burn, we need to remove any existing partitions on the USB drive

burn:  this runs isohybrid to make the USB bootable and then burns the iso image to the USB

## after the first partition is burned, we create a second partition that's ext4 using fdisk -cu <device> and mkfs.ext4

copy:  this copies the image  files and iso file to the  ext4 partition.  It also creates a location for kickstart files.
