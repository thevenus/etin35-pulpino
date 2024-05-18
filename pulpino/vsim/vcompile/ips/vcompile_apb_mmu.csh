#!/bin/tcsh
source ${PULP_PATH}/./vsim/vcompile/setup.csh

##############################################################################
# Settings
##############################################################################

set IP=apb_mmu

##############################################################################
# Check settings
##############################################################################

# check if environment variables are defined
if (! $?MSIM_LIBS_PATH ) then
  echo "${Red} MSIM_LIBS_PATH is not defined ${NC}"
  exit 1
endif

if (! $?IPS_PATH ) then
  echo "${Red} IPS_PATH is not defined ${NC}"
  exit 1
endif

set LIB_NAME="${IP}_lib"
set LIB_PATH="${MSIM_LIBS_PATH}/${LIB_NAME}"
set IP_PATH="${IPS_PATH}/apb/apb_mmu"
set RTL_PATH="${RTL_PATH}"

##############################################################################
# Preparing library
##############################################################################

echo "${Green}--> Compiling ${IP}... ${NC}"

rm -rf $LIB_PATH

vlib $LIB_PATH
vmap $LIB_NAME $LIB_PATH

##############################################################################
# Compiling RTL
##############################################################################

echo "${Green}Compiling component: ${Brown} apb_mmu ${NC}"
echo "${Red}"
vcom -quiet -suppress 2583 -work ${LIB_PATH}        ${IP_PATH}/rom.vhd          || goto error
vlog -quiet -suppress 2583 -work ${LIB_PATH}        ${IP_PATH}/SPHD110420.v     || goto error
vcom -quiet -suppress 2583 -work ${LIB_PATH}        ${IP_PATH}/sram_wrapper.vhd || goto error
vcom -quiet -suppress 2583 -work ${LIB_PATH}        ${IP_PATH}/ram_ctrl.vhd     || goto error
vcom -quiet -suppress 2583 -work ${LIB_PATH}        ${IP_PATH}/controller.vhd   || goto error
vcom -quiet -suppress 2583 -work ${LIB_PATH}        ${IP_PATH}/jollof_top.vhd   || goto error
vlog -quiet -sv -suppress 2583 -work ${LIB_PATH}    ${IP_PATH}/apb_mmu.sv       || goto error

echo "${Cyan}--> ${IP} compilation complete! ${NC}"
exit 0

##############################################################################
# Error handler
##############################################################################

error:
echo "${NC}"
exit 1
