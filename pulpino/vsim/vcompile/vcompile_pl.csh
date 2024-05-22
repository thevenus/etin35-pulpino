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

# build ST and LU libraries
source ${PULP_PATH}/vsim/vcompile/vcompile_st_lu.csh  || exit 1
echo "${Cyan}--> ST and LU libraries compilation complete! ${NC}"

echo ""
echo "${Green}--> Compiling PnR Pulpino Top file... ${NC}"
echo ""

# build the synthesized top file
vlog -quiet -work ${LIB_PATH} ${PULP_PATH}/../pnr/outputs/pulpino_top_pnr.v     || exit 1
echo "${Cyan}--> Synthesized Pulpino Top compilation complete! ${NC}"

# build the testbench files
echo ""
echo "${Green}--> Compiling Pulpino Testbench... ${NC}"
echo ""

vlog -quiet -sv -work "work" +incdir+${TB_PATH}                                                ${TB_PATH}/pkg_spi.sv          || goto error
vlog -quiet -sv -work "work" +incdir+${TB_PATH}                                                ${TB_PATH}/if_spi_slave.sv     || goto error
vlog -quiet -sv -work "work" +incdir+${TB_PATH}                                                ${TB_PATH}/if_spi_master.sv    || goto error
vlog -quiet -sv -work "work" +incdir+${TB_PATH}                                                ${TB_PATH}/uart.sv             || goto error
vlog -quiet -sv -work "work" +incdir+${TB_PATH}                                                ${TB_PATH}/i2c_eeprom_model.sv || goto error
vlog -quiet -sv -work "work" +incdir+${TB_PATH} +incdir+${RTL_PATH}/includes/                  ${TB_PATH}/tb_ps.sv            || goto error

vlog -quiet -sv -work "work"     +incdir+${TB_PATH} -dpiheader ${TB_PATH}/jtag_dpi/dpiheader.h ${TB_PATH}/jtag_dpi.sv         || goto error
vlog -quiet -64 -work "work" -ccflags "-I${TB_PATH}/jtag_dpi/ -m64" -dpicpppath `which gcc`    ${TB_PATH}/jtag_dpi/jtag_dpi.c || goto error

vlog -quiet -sv -work "work" +incdir+${TB_PATH} +incdir+${RTL_PATH}/includes/ -dpiheader ${TB_PATH}/mem_dpi/dpiheader.h    ${TB_PATH}/tb_ps.sv || goto error
vlog -quiet -64 -work "work" -ccflags "-I${TB_PATH}/mem_dpi/  -m64" -dpicpppath `which gcc`    ${TB_PATH}/mem_dpi/mem_dpi.c                 || goto error
echo "${Cyan}--> Pulpino Testbench compilation complete! ${NC}"

echo ""
echo "${Green}--> Synthesized PULPino platform compilation complete! ${NC}"
echo ""
