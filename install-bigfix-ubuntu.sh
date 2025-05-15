#! /bin/bash
# Author: Reuben Castelino
# Modified by: Jody Simpson <jksimpson@ucdavis.edu>
# Purpose: To install bigfix on Linux systems at UC Davis
# Usage 1: sudo ./install_bigfix.sh install ######
# Use the coeadmintools to get the 6 digit department code for a user
# Usage 2: sudo ./install_bigfix.sh uninstall

step=$1
dep_code=$2


if [[ $step == "install" ]]
then
    if ! [[ "$2" =~ ^[0-9]+$ ]]
    then
        echo "Department code needs to be a 6 digit code: non-numerical input"
        exit 1
    fi
    
    if [[ ${#2} -ne 6 ]]
    then
        echo "Department code needs to be a 6 digit code: incorrect length"
        exit 1
    fi

    # Install BigFix
    wget https://software.bigfix.com/download/bes/110/BESAgent-11.0.4.60-ubuntu18.amd64.deb
    wget https://support.bigfix.com/bes/release/11.0/patch4/SHA256SUMS -O - | grep BESAgent-11.0.4.60-ubuntu18.amd64.deb > SHA256
    wget https://support.bigfix.com/bes/release/11.0/patch4/SHA1SUMS -O - | grep BESAgent-11.0.4.60-ubuntu18.amd64.deb > SHA1
    shasum -c SHA256 && shasum -c SHA1 && {
    mkdir -p /etc/opt/BESClient/ || exit
    wget --no-check-certificate "https://getbigfix.ucdavis.edu/generate_installer.php?reqtype=O&dept=$2" -O bigfix.zip
    unzip bigfix.zip -d /etc/opt/BESClient/ || exit
    dpkg -i BESAgent-11.0.4.60-ubuntu18.amd64.deb
    mv /etc/opt/BESClient/besclient.config /var/opt/BESClient
    /etc/init.d/besclient start
    } || echo "Install FAILED"

elif [[ $step == "uninstall" ]]
then
    rm -rf /etc/opt/BESClient
    rm -rf /var/opt/BESClient
    dpkg --purge BESAgent

else
    echo "Command not understood, please use install or uninstall"
fi


