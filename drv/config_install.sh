#!/bin/sh
#Purpose: Post-install configure the driver with aticonfig --initial if not currently configured
#	  This script is enclosed in <script> element before the verify_install.sh is called.   
#Input  : none


# Process security context
sh ./packages/RedHat/selinux.sh 2>/dev/null


###Begin: config_install_sh - DO NOT REMOVE; used in post.sh ###

ATICONFIG_BIN=`which aticonfig` 2> /dev/null
if [ -n "${ATICONFIG_BIN}" -a -x "${ATICONFIG_BIN}" ]; then

   ${ATICONFIG_BIN} --initial=check > /dev/null
   if [ $? -eq 1 ]; then
      # Suppress output identifying backup creation as this will affect the installer text output
      ${ATICONFIG_BIN} --initial > /dev/null
   fi

fi

###End: config_install_sh - DO NOT REMOVE; used in post.sh ###
