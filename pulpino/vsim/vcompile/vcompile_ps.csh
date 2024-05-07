#!/bin/tcsh

# Post-Synthesis Build script

if (! $?VSIM_PATH ) then
  setenv VSIM_PATH      `pwd`
endif

if (! $?PULP_PATH ) then
  setenv PULP_PATH      `pwd`/../
endif

setenv MSIM_LIBS_PATH ${VSIM_PATH}/modelsim_libs

setenv IPS_PATH       ${PULP_PATH}/ips
setenv RTL_PATH       ${PULP_PATH}/rtl
setenv TB_PATH        ${PULP_PATH}/tb

set LIB_NAME="pulpino_lib"
set LIB_PATH="${MSIM_LIBS_PATH}/${LIB_NAME}"



clear
source ${PULP_PATH}/vsim/vcompile/colors.csh

rm -rf modelsim_libs
vlib modelsim_libs

rm -rf work
vlib work

rm -rf $LIB_PATH
vlib $LIB_PATH
vmap $LIB_NAME $LIB_PATH

echo ""
echo "${Green}--> Compiling ST and LU libraries... ${NC}"
echo ""

# Build ST and LU libraries
source ${PULP_PATH}/vsim/vcompile/vcompile_st_lu.csh  || exit 1
echo "${Cyan}--> ST and LU libraries compilation complete! ${NC}"

echo ""
echo "${Green}--> Compiling Synthesized Pulpino Top file... ${NC}"
echo ""

# build the synthesized top file
vlog -quiet -sv -work ${LIB_PATH} ${PULP_PATH}/../synthesis/outputs/pulpino_top.sv     || exit 1
echo "${Cyan}--> Synthesized Pulpino Top compilation complete! ${NC}"

# source ${PULP_PATH}/vsim/vcompile/rtl/vcompile_pulpino.sh  || exit 1
source ${PULP_PATH}/vsim/vcompile/rtl/vcompile_tb.sh       || exit 1

echo ""
echo "${Green}--> Synthesized PULPino platform compilation complete! ${NC}"
echo ""
