#!/bin/sh
DRV_RELEASE="14.501.1003"

##############################################################
# COMMON HEADER: Initialize variables and declare subroutines

BackupInstPath()
{
    if [ ! -d /etc/ati ]
    then
        # /etc/ati is not a directory or doesn't exist so no backup is required
        return 0
    fi

    if [ -n "$1" ]
    then
        FILE_PREFIX=$1
    else
        # client did not pass in FILE_PREFIX parameter and /etc/ati exists
        return 64
    fi

    if [ ! -f /etc/ati/$FILE_PREFIX ]
    then
        return 0
    fi

    COUNTER=0

    ls /etc/ati/$FILE_PREFIX.backup-${COUNTER} > /dev/null 2>&1
    RETURN_CODE=$?
    while [ 0 -eq $RETURN_CODE ]
    do
        COUNTER=$((${COUNTER}+1))
        ls /etc/ati/$FILE_PREFIX.backup-${COUNTER} > /dev/null 2>&1
        RETURN_CODE=$?
    done

    cp -p /etc/ati/$FILE_PREFIX /etc/ati/$FILE_PREFIX.backup-${COUNTER}

    RETURN_CODE=$?

    if [ 0 -ne $RETURN_CODE ]
    then
        # copy failed
        return 65
    fi

    return 0
}



UpdateInitramfs()
{
    UPDATE_INITRAMFS=`which update-initramfs 2> /dev/null`
    DRACUT=`which dracut 2> /dev/null`
    MKINITRD=`which mkinitrd 2> /dev/null`

    kernel_release=`uname -r`
    kernel_version=`echo $kernel_release | cut -d"." -f 1`
    kernel_release_rest=`echo $kernel_release | cut -d"." -f 2`   
    kernel_major_rev=`echo $kernel_release_rest | cut -d"-" -f 1`
    kernel_major_rev=`echo $kernel_major_rev | cut -d"." -f 1` 

    if [ $kernel_version -gt 2 ]; then
        #not used
        kernel_minor_rev=0
    else
        kernel_minor_rev=`echo $kernel_release | cut -d"." -f 3 | cut -d"-" -f 1`
    fi

    if [ $kernel_version -gt 2 -o \( $kernel_version -eq 2 -a $kernel_major_rev -ge 6 -a $kernel_minor_rev -ge 32 \) ]; then

        if [ -n "${UPDATE_INITRAMFS}" -a -x "${UPDATE_INITRAMFS}" ]; then
            #update initramfs for current kernel by specifying kernel version
            ${UPDATE_INITRAMFS} -u -k `uname -r` > /dev/null 

            #update initramfs for latest kernel (default)
            ${UPDATE_INITRAMFS} -u > /dev/null
            
            echo "[Reboot] Kernel Module : update-initramfs" >> ${LOG_FILE} 
        elif [ -n "${DRACUT}" -a -x "${DRACUT}" ]; then
            #RedHat/Fedora
            ${DRACUT} -f > /dev/null            
            echo "[Reboot] Kernel Module : dracut" >> ${LOG_FILE}
             

        elif [ -n "${MKINITRD}" -a -x "${MKINITRD}" ]; then
            #Novell
            ${MKINITRD} > /dev/null
            
            echo "[Reboot] Kernel Module : mkinitrd" >> ${LOG_FILE}
            
        fi
    else
        echo "[Message] Kernel Module : update initramfs not required" >> ${LOG_FILE}
    fi

}



# i.e., lib for 32-bit and lib64 for 64-bit.
if [ `uname -m` = "x86_64" ];
then
  LIB=lib64
else
  LIB=lib
fi

# LIB32 always points to the 32-bit libraries (native in 32-bit,
# 32-on-64 in 64-bit) regardless of the system native bitwidth.
# Use lib32 and lib64; if lib32 doesn't exist assume lib is for lib32
if [ -d "/usr/lib32" ]; then
  LIB32=lib32
else
  LIB32=lib
fi

#process INSTALLPATH, if it's "/" then need to purge it
#SETUP_INSTALLPATH is a Loki Setup environment variable
INSTALLPATH=${SETUP_INSTALLPATH}
if [ "${INSTALLPATH}" = "/" ]
then
    INSTALLPATH=""
fi

# project name and derived defines
MODULE=fglrx
IP_LIB_PREFIX=lib${MODULE}_ip

# general purpose paths
XF_BIN=${INSTALLPATH}${ATI_X_BIN}
XF_LIB=${INSTALLPATH}${ATI_XLIB}
OS_MOD=${INSTALLPATH}`dirname ${ATI_KERN_MOD}`
USR_LIB=${INSTALLPATH}/usr/${LIB}
MODULE=`basename ${ATI_KERN_MOD}`

#FGLRX install log
LOG_PATH=${INSTALLPATH}${ATI_LOG}
LOG_FILE=${LOG_PATH}/fglrx-install.log
if [ ! -e ${LOG_PATH} ]
then
  mkdir -p ${LOG_PATH} 2>/dev/null 
fi
if [ ! -e ${LOG_FILE} ]
then
  touch ${LOG_FILE}
fi

#DKMS version
DKMS_VER=`dkms -V 2> /dev/null | cut -d " " -f2`

#DKMS expects kernel module sources to be placed under this directory
DKMS_KM_SOURCE=/usr/src/${MODULE}-${DRV_RELEASE}

# END OF COMMON HEADER
#######################

###Begin: pre_doc1 ###
#at this point, detect_previous has completed and one of the following are true
# -no previous installed driver
# -a previous installed driver but dryrun indicates safe to uninstall
# -a previous installed driver but the user has run install with force


echo "Uninstalling any previously installed drivers." >> ${LOG_FILE}
result=0

AMD_UNINSTALL_SCRIPT="/usr/share/ati/amd-uninstall.sh"
if [ -x "${AMD_UNINSTALL_SCRIPT}" ]; then
       
    if [ "`grep getUninstallVersion ${AMD_UNINSTALL_SCRIPT}`" != "" ]
    then 
        sh ${AMD_UNINSTALL_SCRIPT} --getUninstallVersion > /dev/null
        version=$?
    else
        version=1
    fi

    if [ $version -ge 2 ]; then
        #quick and preserve options added in version 2 of uninstaller
        sh ${AMD_UNINSTALL_SCRIPT} --force --preserve >> ${LOG_FILE}
        result=$?
        echo "${AMD_UNINSTALL_SCRIPT} completed with $result" >> ${LOG_FILE}

    else
        #need to save the log file or will be removed
        TMP_LOGFILE=`mktemp`
        cp -f "${LOG_FILE}" "${TMP_LOGFILE}"
        sh ${AMD_UNINSTALL_SCRIPT} --force >> ${TMP_LOGFILE}

        if [ ! -e ${LOG_PATH} ]
        then
            mkdir -p ${LOG_PATH} 2>/dev/null
        fi
        cp -f "${TMP_LOGFILE}" "${LOG_FILE}"
        rm -f "${TMP_LOGFILE}"
        
        result=$?
    fi
    
fi


###Begin: pre_install_1 - DO NOT REMOVE; used in b30specfile.sh ###
FGLRX_UNINSTALL_SCRIPT="/usr/share/ati/fglrx-uninstall.sh"

if [ -x "${FGLRX_UNINSTALL_SCRIPT}" ]; then
    
    #need to save the log file or will be removed
    TMP_LOGFILE=`mktemp`
    cp -f "${LOG_FILE}" "${TMP_LOGFILE}"
        
    FORCE_ATI_UNINSTALL=Y
    export FORCE_ATI_UNINSTALL
    sh "$FGLRX_UNINSTALL_SCRIPT" >> ${TMP_LOGFILE}
    
    if [ ! -e ${LOG_PATH} ]
    then
        mkdir -p ${LOG_PATH} 2>/dev/null
    fi
    cp -f "${TMP_LOGFILE}" "${LOG_FILE}"
    rm -f "${TMP_LOGFILE}"
        
    result=$?
fi
###End: pre_install_1 - DO NOT REMOVE; used in b30specfile.sh ###

###End: pre_doc1 ###
###Begin: pre_doc2 ###
# backup inst_path_* files in case user wants to go back to a previous profile

  BackupInstPath inst_path_default
  BackupInstPath inst_path_override

###End: pre_doc2 ###
exit 0
