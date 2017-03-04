#!/bin/bash
#
# tre.sh - Find TRE files on user's HOST system and scp to the guest
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Thu Dec 31 16:41:02 EST 2015
#

if [ -z "$BASH_VERSION" ]; then
    echo "** Please use BASH to run this script **"
    exit 1
fi

trepath=''

main() {
    local is_auto=false

    if [ "X$1" = "X--auto" ]; then
	is_auto=true
    fi

    msg "TRE File Copy"

    # Check for default location(s)
    trepath=$(hunt_emudir)

    if [ -z "${trepath}" ]; then
	echo -e "\n** In order to run the server you must copy required '.tre' files from the client"
	echo -e  "** If you've installed the client on this computer we can copy them for you.\n"
	ask_emudir
    fi

    if [ -z "${trepath}" ]; then
	echo -e "\nThe server won't start until you have the tre files copied into the guest.\n"
	echo -e "When you're ready try: cd "$(dirname $PWD)";./tre.sh"
	exit 2
    fi

    echo -e "\n** Ok we found your files in ${trepath}, we will now try and copy them to your guest...\n"

    local sshcfg=$(mktemp /tmp/tre-ssh.XXXXXX)
    local need=$(mktemp /tmp/tre-need.XXXXXX)
    trap 'rm -f "'${sshcfg}'" "'${need}'"' 0

    echo "** Checking to make sure your guest is up..."
    vagrant up > /dev/null 2>&1
    
    echo "** Getting ssh configuration..."
    vagrant ssh-config > $sshcfg || error "Failed to get ssh config, GET HELP!" 11

    if ssh -F $sshcfg default 'exec ZonamaDev/fasttrack/bin/tre_check --auto' > ${need}; then
	if $is_auto; then
	    echo "** All files are up to date **"
	    exit 0
	else
	    if yorn "\nYour tre files seem to be up to date on the server, do you want to copy them again? "; then
		:
	    else
		echo "** aborted by user **"
		exit 100
	    fi
	fi
    fi

    if $is_auto; then
	# Give guest a change to get setup done
	echo "** Please follow directions in guest to complete user setup."
	if ssh -F $sshcfg default 'exec ZonamaDev/fasttrack/bin/zdcfg wait-flag devsetup/__full_run.status 180 "user setup complete"'; then
	    echo "** setup complete in guest."
	else
	    echo "** setup timeout, continue anyway."
	fi
    fi

    echo "** Copying files..."
    ssh -F $sshcfg default mkdir -p Desktop/SWGEmu

    cd "${trepath}"

    if $is_auto; then
	scp -F $sshcfg -o Compression=no $(cat "${need}") default:Desktop/SWGEmu
    else
	scp -F $sshcfg -o Compression=no *.tre default:Desktop/SWGEmu
    fi

    local scp_ret=$?

    if [ "$scp_ret" -eq 0 ]; then
	msg "SUCCESS!"
    else
	msg "SCP SEEMS TO HAVE FAILED WITH ERR=${scp_ret}, GET HELP!?"
    fi

    exit 0
}

ask_emudir() {
    while :
    do
	echo
	read -rp "Where did you install the swgemu client? " n

	if [ -z "$n" ]; then
	    continue
	fi

	local path=$(cygpath "${n//\\/\/}" 2> /dev/null || echo $n)

	echo -e "\nSearching [$path]\n"

	if check_emudir "$path"; then
	    trepath=$path
	    return 0
	else
	    if yorn "\nDidn't find the tre files there, shall we search '${path}' for them?"; then
		local fn=$(find $path -name $last_tre 2> /dev/null)

		if [ -n "$fn" ]; then
		    path=$(dirname $fn)

		    if check_emudir "$path"; then
			trepath="$path"
			return 0
		    fi
		fi

		if yorn "\nStill didn't find them, would you like to try another directory?"; then
		    :
		else
		    return 0
		fi
	    else
		return 0
	    fi
	fi
    done
}

hunt_emudir() {
    for i in '/c/SWGEmu' '/d/SWGEmu' '/cygdrive/c/SWGEmu' '/cygdrive/d/SWGEmu' '/Volumes/BOOTCAMP/SWGEmu'
    do
	if [ -d $i ]; then
	    if check_emudir "$i"; then
		echo $i
		return 0
	    fi
	fi
    done

    return 1
}

check_emudir() {
    local dir="$1"
    local cnt=$(ls "${dir}"/*.tre 2> /dev/null|wc -l)

    if [ $cnt -eq 0 ]; then
	return 1
    fi

    if [ $cnt -ge ${#trefiles[@]} ]; then
	# TODO check trefiles array?
	return 0
    fi

    return 1
}

yorn() {
  if tty -s; then
      echo -n -e "$@ Y\b" > /dev/tty
      read yorn < /dev/tty
      case $yorn in
	[Nn]* ) return 1;;
      esac
  fi
  return 0
}

error() {
    err_msg=$1
    err_code=251
    if [ "X$2" != "X" ]; then
	err_code=$2
    fi

    msg "ERROR WHILE PROCESSING $RUN_STEP: $err_msg ($err_code)"

    exit $err_code
}

msg() {
    local hd="##"$(echo "$1"|sed 's/./#/g')"##"
    echo -e "$hd\n# $1 #\n$hd"
}

check_cmds() {
    for i in tty mktemp sed scp ssh find
    do
	if type -P $i > /dev/null; then
	    :
	else
	    echo "** You're missing the $i command, you need to upgrade git for windows"
	    echo "** Please download and install the latest from: https://git-for-windows.github.io/"
	    exit
	fi
    done

    return 1
}

declare -a trefiles
trefiles=('bottom.tre' 'data_animation_00.tre' 'data_music_00.tre' 'data_other_00.tre' 'data_sample_00.tre' 'data_sample_01.tre' 'data_sample_02.tre' 'data_sample_03.tre' 'data_sample_04.tre' 'data_skeletal_mesh_00.tre' 'data_skeletal_mesh_01.tre' 'data_sku1_00.tre' 'data_sku1_01.tre' 'data_sku1_02.tre' 'data_sku1_03.tre' 'data_sku1_04.tre' 'data_sku1_05.tre' 'data_sku1_06.tre' 'data_sku1_07.tre' 'data_static_mesh_00.tre' 'data_static_mesh_01.tre' 'data_texture_00.tre' 'data_texture_01.tre' 'data_texture_02.tre' 'data_texture_03.tre' 'data_texture_04.tre' 'data_texture_05.tre' 'data_texture_06.tre' 'data_texture_07.tre' 'default_patch.tre' 'patch_00.tre' 'patch_01.tre' 'patch_02.tre' 'patch_03.tre' 'patch_04.tre' 'patch_05.tre' 'patch_06.tre' 'patch_07.tre' 'patch_08.tre' 'patch_09.tre' 'patch_10.tre' 'patch_11_00.tre' 'patch_11_01.tre' 'patch_11_02.tre' 'patch_11_03.tre' 'patch_12_00.tre' 'patch_13_00.tre' 'patch_14_00.tre' 'patch_sku1_12_00.tre' 'patch_sku1_13_00.tre' 'patch_sku1_14_00.tre')

let "i=${#trefiles[@]} - 1"
last_tre=${trefiles[$i]}

check_cmds

cd $(dirname $0)

main "$@"

# :vi ft=sh sw=4 ai
