#!/bin/bash
#
# setup.sh - Build the fast track box from the basebox in atlas
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Fri Dec 25 18:50:00 EST 2015
#

if [ -z "$BASH_VERSION" ]; then
    echo "** Please use BASH to run this script **"
    exit 1
fi

main() {
    if [ ! -f Vagrantfile ]; then
	echo "** You must run this from the fasttrack directory, please cd there and type: ./setup.sh"
	exit 1
    fi

    if [ ! -f 'config.yml' ]; then
	local cores=$(calc_cores)
	if [ $cores -gt 0 ]; then
	    let "ram=(768 * $cores)"
	    echo -e "cores: ${cores}\nram: ${ram}" > config.yml
	    echo "** Setting config.yml to use ${cores} cores for guest and ${ram}m of ram. **"
	else
	    echo "** Using default cores/ram **"
	fi
    fi

    echo "vagrant up"

    time vagrant up

    local ret=$?

    if [ $ret -eq 101 ]; then
	echo "** Running vagrant up again after plugin install **"
	time vagrant up
	ret=$?
    fi

    if [ $ret -ne 0 ]; then
	echo "** Vagrant failed to bring the VM image up, look at errors above for clues **"
	echo "** If this continues get help here: https://github.com/lordkator/ZonamaDev/issues **"
	exit 1
    fi

    sleep 5

    ./tre.sh --auto

    echo "** Now switch to the linux console and follow the directions!"

    exit 0
}

size_ram_osx() {
    sysctl -n hw.memsize
}

size_cores_osx() {
    sysctl -n hw.physicalcpu
}

size_ram_win() {
    wmic memorychip get capacity|awk 'NR > 1 {x = x + $1 } END { print x }'
}

size_cores_win() {
    nproc 2> /dev/null || echo $NUMBER_OF_PROCESSORS
}

size_ram_linux() {
    free -t -b|awk 'NR == 2 { print $2 }'
}

size_cores_linux() {
    nproc
}

calc_cores() {
    local total_ram=$(size_ram_$OS)
    local total_cores=$(size_cores_$OS)
    local bycore=0
    local byram=0
    local est_ram=0

    let "byram=($total_ram / 1024 / 1024 / 4 * 3) / 768"
    let "bycore=$total_cores / 4 * 3"
    let "bycore=$bycore - $bycore % 2"

    local cores=$byram

    if [ "$cores" -gt "$bycore" ]; then
	cores=$bycore
    fi

    if [ "$cores" -le "2" ]; then
	cores=0
    fi

    echo $cores
}

check_win() {
    # Check for bad embedded curl in Vagrant
    # See https://github.com/mitchellh/vagrant/issues/6852
    /c/HashiCorp/Vagrant/embedded/bin/curl.exe > /dev/null 2>&1

    if [ $? -eq 127 ]; then
	if [ -f /mingw64/bin/curl.exe ]; then
	    echo "** WARNING: Patching your vagrant's embedded curl since it seems to be broken **"
	    cp /mingw64/bin/curl.exe /c/HashiCorp/Vagrant/embedded/bin/curl.exe
	else
	    echo "###################################################################"
	    echo "## YOU NEED TO INSTALL THE FOLLOWING PACKAGE FIRST, THEN RE-TRY: ##"
	    echo "## Microsoft Visual C++ 2010 SP1 Redistributable Package         ##"
	    echo "## https://www.microsoft.com/en-us/download/details.aspx?id=8328 ##"
	    echo "###################################################################"
	    explore "https://www.microsoft.com/en-us/download/details.aspx?id=8328"
	    exit 0
	fi
    fi
}

check_osx() {
    return 0
}

check_linux() {
    return 0
}

yorn() {
    echo -n -e "$@ Y\b"
    read yorn
    case $yorn in
	[Nn]* ) return 1;;
    esac
    return 0
}

export OS='unknown'

case $(uname -s) in
    Darwin ) OS='osx' ;;
    *Linux* ) OS='linux' ;;
    *_NT* ) OS='win';;
    * ) echo "Not sure what OS you are on, guessing Windows"; OS='win';;
esac

check_$OS

time main "$@"

exit 0

# vi: ft=sh sw=4 cursorline cursorcolumn
