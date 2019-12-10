#!/bin/bash

selectflavour(){
    echo ""
    echo " Select Fedora Flavour :"
    echo ""
    echo " 01|Server  02|Silverblue"
    echo " 03|Spins   04|Everything"
    echo " 05|Workstation"
    echo ""
    read -p " Choose One : " act;
    if [ $act == '1' ]
    then
        flavour='Server'
        iso='dvd'
    elif [ $act == '2' ]
    then
        flavour='Silverblue'
        iso='ostree'
    elif [ $act == '3' ]
    then
        flavour='Spins'
        iso='Live'
        spinsdesktop
    elif [ $act == '4' ]
    then
        flavour='Everything'
        iso='netinst'
    elif [ $act == '5' ]
    then
        flavour='Workstation'
        iso='Live'
    else
        selectflavour
    fi
    downloadiso
}

spinsdesktop(){
    echo ""
    echo " Select Desktop Environtment :"
    echo ""
    echo " 01|KDE   02|XFCE   03|LXQT"
    echo " 04|MATE  05|LXDE   06|SOAS"
    echo " 07|CINNAMON"
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
        spinsdesktop
    fi
    downloadiso
}

downloadiso(){
    if [ $flavour == '' ]
    then
        selectflavour
    elif [ $flavour == 'Spins' ]
    then
        if [ $desktop == '' ]
        then
            echo " No Desktop Selected"
            spinsdesktop
        else
            download="Fedora-$desktop-$iso-x86_64-31-1.9.iso"
        fi
    else
        download="Fedora-$flavour-$iso-x86_64-31-1.9.iso"
    fi
    echo " Downloading Fedora $flavour $iso ISO"
    wget -c --retry-connrefused --tries=0 --timeout=5 https://download.fedoraproject.org/pub/fedora/linux/releases/31/$flavour/x86_64/iso/$download
    wget -c --retry-connrefused --tries=0 --timeout=5 https://download.fedoraproject.org/pub/fedora/linux/releases/31/$flavour/x86_64/iso/Fedora-$flavour-31-1.9-x86_64-CHECKSUM
    checksum
}

checksum(){
    sumfile=`cat Fedora-$flavour-31-1.9-x86_64-CHECKSUM | grep "SHA256 ($download)" | awk '{print $4}'`
    sumiso=`sha256sum $download | awk '{print $1}'`
    if [ $sumfile == $sumiso ]
    then
        echo " Checksum verified"
        listdisk
    else
        echo " Checksum not verified"
        wget -c --retry-connrefused --tries=0 --timeout=5 https://download.fedoraproject.org/pub/fedora/linux/releases/31/$flavour/x86_64/iso/Fedora-$flavour-31-1.9-x86_64-CHECKSUM
        checksum
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
    burn
}

burn(){
    if [[ $EUID -ne 0 ]]; then
        umount $part
        dd bs=4M if=$download of=$part status=progress oflag=sync
    else
        sudo umount $part
        sudo dd bs=4M if=$download of=$part status=progress oflag=sync
    fi
}

selectflavour
