#!/bin/bash
#
# bmc-tools - simple bash script to perform multiple bmc operations
#
# Author: Jason Hargis
#
version=3.3
#
# Requires: ipmitool and/or ipmiutil and/or freeipmi
#
# apt-get install ipmitool or-src->
# apt-get install ipmiutil or-src->
# apt-get install freeipmi or-src->
#
# Revisions:
#  2.2 - sol and bootmode cleanup; auto detect mfg if single arg
#
# TO-DO: (add functionality from freeipmi)
#
# ipmi-config --hostname=172.31.250.[1-200] --username=ADMIN --password=ADMIN --checkout --section=Lan_Conf
# bmc-config --hostname=172.31.241.194 -W noauthcodecheck --username=admin --password=admin --checkout
# ipmi-dcmi --hostname=172.31.241.194 -W noauthcodecheck --username=admin --password=admin --get-dcmi-capability-info
#
#
####################################################################
#
# define defaults command and options
cmd="ipmitool"                  # ipmiutil
cmdprotoflag="-I"               # freeipmi uses -F      | ipmiutil works without
cmdproto="lanplus"              # freeipmi uses lan2    | ipmiutil works without
cmdhostflag="-H"        # ipmiutil uses -N

# ensure we have tools/bin in PATH:
export PATH=/tools/bin:${PATH}

COMMON_FUNCTIONS=/tools/bin/common.source

if [[ -e ${COMMON_FUNCTIONS} ]]; then
        source ${COMMON_FUNCTIONS}
else
        printf "Unable to locate common functions!\n**ABORT**\n\n"
        exit 1
fi

# ensure our version of BASH supports arrays
foo[0]='test' || (echo 'Failure: arrays not supported in this version of bash.' && exit 2)

# array of dependencies
declare -a CMDS=("ipmitool" "chmod")

# ensure we have all required cmds
for i in "${!CMDS[@]}"; do
    if ! [[ -x "$(command -v ${CMDS[$i]})" ]]; then
        printf "\nRequired cmd ${CMDS[$i]} NOT found!\n"
        printf "\n**ABORT**\n\n"
        exit 1
    fi
done

# me = name of calling script
me=$(basename "$0")

# enable color support?
if [[ "${TERM}" =~ "color" || "${TERM}" =~ "linux" || $(tput colors) -ge 8 ]]; then
        # enable color output
        COLOR=Y
fi

# based on sym-linked name, determine mode
case $me in
        bmc-chassis-status ) options="chassis status"
                                ;;
        bmc-console ) options="sol activate"
                                ;;
        # bmc-console ) cmd="ipmiutil sol"; cmdprotoflag="-a"; cmdproto="-c^"; cmdhostflag="-N"; options="sol activate";
            # isol -N 172.31.241.157 -U ADMIN -P ADMIN -a -c'^' sol activate
        bmc-console-info ) options="sol info"
                                ;;
        bmc-power-status ) options="power status"
                                ;;
        bmc-power-off ) options="power off"
                                ;;
        bmc-power-on ) options="power on"
                                ;;
        bmc-power-reset ) options="power reset"
                                ;;
        bmc-soft-power-off ) options="power soft"
                                ;;
        bmc-user-list ) options="user list"
                                ;;
        bmc-mc-info ) options="mc info"
                                ;;
        bmc-dcmi-info ) cmd="ipmiutil dcmi"; cmdhostflag="-N"; cmdprotoflag="";  cmdproto="";  options=""
                                ;;
        bmc-channel-info ) options="channel info"
                                ;;
        bmc-mc-reset-warm ) options="mc reset warm"
                                ;;
        bmc-mc-reset-cold ) options="mc reset cold"
                                ;;
        bmc-shell ) options="-e \& shell"
                                ;;
        bmc-sys-firmware ) options="mc getsysinfo system_fw_version"
                                ;;
        bmc-sdr-elist-all ) options="sdr elist all"
                                ;;
        bmc-boot2bios ) options="chassis bootparam set bootflag force_bios"
                                ;;
        bmc-identify ) options="chassis identify 120"
                                ;;
        bmc-get-lanconf ) options="--checkout --section=Lan_Conf"
                                ;;
        bmc-tools ) echo "run the symlinked utility name";
                                exit 1
                                ;;
esac

Usage()
{
    echo "usage: $me [-h|--help] hostname|IP_Address tyan|supermicro"
}

## No arguments (run local if root and we have device)
if [ $# -eq 0 ]; then

        # Only runs as root...
        if [ "`id -u`" -ne 0 ]; then
                echo "ERROR: Local mode only runs as root"
                exit 1
        fi

        # Local mode: only run if there is an IPMI interface
        if [ ! -e /dev/ipmi0 ]; then
                echo "No IPMI device driver"
                 #echo "**ABORTING**"
                exit 1
        fi

        # run the command locally
        $cmd $options
fi

## One arg - auto attempt MFG seletion
if [ "$#" -eq 1 ]; then
        # assume the only arg is hostname or IP - use nmap to auto-determine mfg (WIP)
    macinfo=$(nmap -sU -p 161 -T4 -d -v -n -Pn --script snmp-interfaces $1|awk -F": " '/^MAC Address:/ {print $2}')

        # assign $mfg out of () returned by nmap
        if [[ ${macinfo} =~ $brackets_regex ]]; then
            mfg=${BASH_REMATCH[1]};
                    mfg="$(echo $mfg|tr '[:upper:]' '[:lower:]'|tr -d '[:space:]')"
        fi
        printf "macinfo for $1 is: $macinfo => $mfg\n"
        if [[ "$mfg" == "" ]]; then
                printf "Wasn't able to auto determine mfg\n"
                printf "You'll need to include it!\n\n"
                printf "see --usage\n"
                exit 1
        fi
        printf "attempting auto connect...\n"
        set -- "${@:1}" "$mfg" "${@:3}"
fi
echo $@
# run IPMI remotely
node=$1
while [ "$1" != "" ]; do
        case $1 in
                asrock | asr ) login="-U admin -P admin";
                                ;;
                tyan | Tyan | TYAN | Intel | intel ) login="-U root -P superuser";
                                ;;
                supermicro | Supermicro | SUPERMICRO | smc ) login="-U ADMIN -P ADMIN";
                                ;;
                Quanta | quanta | qct ) login="-U admin -P admin";
                                ;;
                Dell | dell ) login="-U root -P N0eyes!!";
                                ;;
                -h | --help )   Usage; exit;
                                ;;
        -v | --version ) printf "$version\n"; exit;;
        esac
        shift
done

## main command:
printf "$cmd $cmdprotoflag $cmdproto $cmdhostflag $node $login $options\n"
$cmd $cmdprotoflag $cmdproto $cmdhostflag $node $login $options 2>&1 | grep -v "Get HPM.x Capabilities request failed, compcode = d4"

## special exit handlers
case $me in
        bmc-console ) printf "cleaning up SOL session\n"; sleep 1;
                $cmd $cmdprotoflag $cmdproto $cmdhostflag $node $login sol deactivate;
                exit 0;
                ;;
        bmc-boot2bios ) printf "performing power reset\n"; sleep 1;
                $cmd $cmdprotoflag $cmdproto $cmdhostflag $node $login power reset;
                exit 0;
                ;;
esac
