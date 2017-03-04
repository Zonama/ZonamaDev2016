#!/bin/bash
#
# rundir.sh - Run all scripts in a directory based on script's name (i.e. myname.d/*)
#
# Typical usage is a symlink to this script or a script that sets ME= and source's this script
#
# Author: Lord Kator <lordkator@swgemu.com>
#
# Created: Sat Dec 26 15:39:04 EST 2015
#

if [ -z "$ME" ]; then
    pushd $(dirname ${BASH_SOURCE[0]}) > /dev/null
    export ME=$(pwd -P)'/'$(basename ${BASH_SOURCE[0]})
    popd > /dev/null

    if [ ! -d $ME'.d' ]; then
	echo "Usage: $0 - Run files in directory ${0}.d/"
	exit 0
    fi
fi

# Hunt for global.config
dir=$(dirname $ME)
for i in "$HOME" "${dir}" "${dir}/.." "${dir}/../.." "${dir}/../../.."
do
    cfg="${i}/ZonamaDev/common/global.config"

    if [ -f "${cfg}" ]; then
	export ZDCFGPATH="${cfg}"
	break
    fi
done

if [ -z "${ZDCFGPATH}" -o ! -f "${ZDCFGPATH}" ]; then
    echo "** ERROR: Can not find global.config, GET HELP!"
    exit 252
fi

source "${ZDCFGPATH}"

TAG=$(basename $ME)
RUN_STEP="init"
HAVEX=false

if xset q > /dev/null 2>&1; then
    HAVEX=true
fi

# Run output through some stuff to make display more useful and capture errors
if [ "X$CHILD_STATUS" = "X" ]; then
    export CHILD_STATUS="/tmp/${TAG}-status-$$"
    echo 253 > $CHILD_STATUS
    ts=$(type -P ts)
    if [ -n "$ts" ]; then
	$ME -- $* 2>&1 | $ts -s | logger -i -t ${TAG} -s 2>&1
    else
	$ME -- $* 2>&1 | logger -i -t ${TAG} -s 2>&1
    fi
    st=$(<$CHILD_STATUS)
    if [ $st -eq 0 ]; then
	logger -i -t ${TAG} -s "** $ME SUCCESS **"
    else
	logger -i -t ${TAG} -s "** $ME FAILED! STATUS=$st ** ABORT **"
    fi
    rm -f $CHILD_STATUS
    exit $st
fi

## Assets Directory
ASSETS_DIR=$(dirname $ME)'/../assets'

# Trap various failures
TMPFILES=()

trap 'st=$?;echo $st > '${CHILD_STATUS}';rm -f ${TMPFILES[@]};msg "UNEXPECTED EXIT=$st"' 0
trap 'msg "UNEXPECTED SIGNAL SIGHUP!";echo 21 > $CHILD_STATUS' HUP
trap 'msg "UNEXPECTED SIGNAL SIGINT!";echo 22 > $CHILD_STATUS' INT
trap 'msg "UNEXPECTED SIGNAL SIGTERM!";echo 23 > $CHILD_STATUS' TERM

msg() {
    local hd="##"$(echo "$1"|sed 's/./#/g')"##"
    echo -e "$hd\n# $1 #\n$hd"
}

alert() {
    if $HAVEX; then
	notify-send --icon=${ASSETS_DIR}/swgemu_icon.png --expire-time=0 "$1" "$2"
	echo "USER ALERT: $1 - $2"
    else
	echo "**ALERT** $1: $2"
    fi
}

notice() {
    if $HAVEX; then
	notify-send --icon=${ASSETS_DIR}/swgemu_icon.png --expire-time=7000 "$1" "$2"
	echo "USER NOTICE: $1 - $2"
    else
	echo "**NOTICE** $1: $2"
    fi
}

delete_on_exit() {
    TMPFILES+=($1)
}

error() {
    err_msg=$1
    err_code=251
    if [ "X$2" != "X" ]; then
	err_code=$2
    fi

    msg "ERROR WHILE PROCESSING $RUN_STEP: $err_msg ($err_code)"

    if $HAVEX; then
	zenity --error --title="${TAG} FAILED" --text="The ${TAG} process failed at step ${RUN_STEP} with error:\n\n${err_msg} (${err_code})" < /dev/null > /dev/null 2>&1 &
    fi

    exit $err_code
}

command_window() {
    # TODO do we need to detect other terminals in case this one's not installed?
    xfce4-terminal --maximize --icon=${ASSETS_DIR}/swgemu_icon.png --hide-menubar --hide-toolbar --title="$1" --command="$2"
}

yorn() {
  if $HAVEX; then
       zenity --question --text="$@"
       return $?
  else
      if tty -s; then
	  echo -n -e "$@ Y\b" > /dev/tty
	  read yorn < /dev/tty
	  case $yorn in
	    [Nn]* ) return 1;;
	  esac
      fi
  fi

  return 0
}

step_status() {
    local ret=255

    if [ -f "${RUN_FLAGS_DIR}/${RUN_STEP}.status" ]; then
	read tm st misc < "${RUN_FLAGS_DIR}/${RUN_STEP}.status"
	ret=$st
    fi

    return $ret
}

step_not_complete() {
    if step_status; then
	return 1
    else
	return 0
    fi
}

step_complete() {
    echo $(date '+%s')" $@" > "${RUN_FLAGS_DIR}/${RUN_STEP}.status"
    msg "Step ${RUN_STEP} complete: $@"
}

reset_step() {
    rm -f "${RUN_FLAGS_DIR}/${RUN_STEP}.status"
    msg "Reset step ${RUN_STEP}"
}

full_run_status() {
    local ret=255

    if [ -f "${RUN_FLAGS_DIR}/__full_run.status" ]; then
	read tm st misc < "${RUN_FLAGS_DIR}/__full_run.status"
	ret=$st
    fi

    return $ret
}

full_run_not_complete() {
    if full_run_status; then
	return 1
    else
	return 0
    fi
}

full_run_complete() {
    date "+%s 0 seconds=$SECONDS" > "${RUN_FLAGS_DIR}/__full_run.status"
}

# We at least made it this far!
echo 252 > $CHILD_STATUS

###################
## CHILD PROCESS ##
###################

if [ "X$1" = "X--" ]; then
    shift
fi

msg "START $ME $* git-tag: "$(cd $(dirname $ME);git describe --always)

# Check for FORCE flag
FORCE=false

if [ "X$1" = "X-f" -o "X$1" = "X--force" ]; then
    FORCE=true
    shift
    echo "**NOTICE** User requested we force the run."
fi

## Run LOCK
LOCKTMP=$(mktemp /tmp/${TAG}.lock-XXXXXX)
LOCKFILE=/tmp/${TAG}.lock

delete_on_exit $LOCKTMP

echo "$$ "$(date +%s) > ${LOCKTMP}

if ln ${LOCKTMP} ${LOCKFILE}; then
    :
else
    read pid tm_lock < ${LOCKFILE}

    if [ $pid -eq $$ ]; then
	msg "We already own this lock as PID $pid"
    else
	tm_now=$(date +%s)

	let "tm_delta=${tm_now} - ${tm_lock}"

	if kill -0 $pid; then
	    msg "PID $pid HAS HAD LOCK FOR ${tm_delta} SECOND(S), EXITING"
	    exit 0
	else
	    msg "Stealing lock from PID $pid which has gone away, locked ${tm_delta} second(s) ago"
	    if ln -f ${LOCKTMP} ${LOCKFILE}; then
		read pid tm_lock < ${LOCKFILE}
		if [ "$pid" -eq "$$" ]; then
		    msg "STOLE LOCK, PROCEEDING"
		else
		    msg "Can't steal lock, somone got in before us!? pid=${pid}"
		    exit 2
		fi
	    else
		msg "Failed to steal lock, **ABORT**"
		exit 1
	    fi
	fi
    fi
fi

delete_on_exit $LOCKFILE

run_dir=$(echo ${ME}'.d')

cd $run_dir

full_run=true
steps=$(echo ${run_dir}/*)

# Did the user call us with specific steps?
if [ -n "$1" ]; then
    msg "Custom steps: $@"
    full_run=false
    # 00* always run
    steps=$(echo ${run_dir}/00*)

    for i in $@
    do
	fn="${run_dir}/$i"
	if [ -f $fn ]; then
	    steps="${steps} ${fn}"
	else
	    msg "Invalid step: $i file: ${fn} not found"
	fi
    done

    # 99* always run
    steps="$steps $(echo ${run_dir}/99*)"
else
    echo "Steps: "$(echo "$steps" | sed "s!${run_dir}/!!g")
fi

RUN_FLAGS_DIR="${ZONAMADEV_CONFIG_HOME}/flags/$(basename $ME)"

[ ! -d "${RUN_FLAGS_DIR}" ] && mkdir -p "${RUN_FLAGS_DIR}"

for step in $steps
do
    if [ -f $step ]; then
	RUN_STEP=$(basename $step)
	msg "Run $step md5:"$(md5sum $step)
	if $full_run; then
	    :
	else
	    if $FORCE; then
		reset_step
	    fi
	fi
	source $step
    fi
done

if $full_run; then
    if full_run_not_complete; then
	full_run_complete
    else
	if $FOCE; then
	    full_run_complete
	fi
    fi
fi

msg "$ME COMPLETE AFTER $SECONDS SECOND(S)"

#############
## Success ##
#############
trap - 0
echo 0 > $CHILD_STATUS
rm -f ${TMPFILES[@]}
exit 0

# vi:sw=4 ft=sh
