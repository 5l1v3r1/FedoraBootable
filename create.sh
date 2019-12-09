#!/bin/bash

selectdesktop(){
    echo ""
    echo " Select Desktop Environtment :"
    echo ""
    echo " 01|KDE   02|XFCE   03|LXQT"
    echo " 04|MATE  05|LXDE   06|SOAS"
    echo "        07|CINNAMON"
    echo ""
    read -p " Choose One : " act;
    if [ $act == '1' ]
    then
        desktop='KDE'
    elif [ $act == '2' ]
    then
        desktop='Xfce'
    elif [ $act == '3' ]
    then
        desktop='LXQt'
    elif [ $act == '4' ]
    then
        desktop='MATE_Compiz'
    elif [ $act == '5' ]
    then
        desktop='LXDE'
    elif [ $act == '6' ]
    then
        desktop='SoaS'
    elif [ $act == '7' ]
    then
        desktop='Cinnamon'
    else
        selectdesktop
    fi
}

downloadiso(){
    if [ $desktop == '' ]
    then
        echo " No Desktop Selected"
        selectdesktop
    else
        echo " Downloading Fedora Live ISO with $desktop Desktop"
        wget -c --retry-connrefused --tries=0 --timeout=5 https://download.fedoraproject.org/pub/fedora/linux/releases/31/Spins/x86_64/iso/Fedora-$desktop-Live-x86_64-31-1.9.iso
    fi
}

listdisk(){
    if [[ $EUID -ne 0 ]]; then
        fdisk -l | grep /dev/
    else
        sudo fdisk -l | grep /dev/
    fi
    echo ""
    read -p " Select partition to create bootable (/dev/sdX) : " part;
    if [ $part == '' ]
    then
        listdisk
    fi
}

burn(){
    if [[ $EUID -ne 0 ]]; then
        umount $part
        dd bs=4M if=Fedora-$desktop-Live-x86_64-31-1.9.iso of=$part status=progress oflag=sync
    else
        sudo umount $part
        sudo dd bs=4M if=Fedora-$desktop-Live-x86_64-31-1.9.iso of=$part status=progress oflag=sync
    fi
}

selectdesktop
downloadiso
listdisk
burn
