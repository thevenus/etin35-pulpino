####----------------------------------------------------------####
# Title        : primeTime Sample Script
# Project      : IC Project 1
####----------------------------------------------------------####
# File         : ptime.tcl
# Module Name  : 
# Project Root : 
# Author       : Masoud Nouripayam (ma1570no@eit.lth.se)
# Company      : Digital ASIC Group, EIT, LTH, Lund University
# Created      : 2020-03-02
# Last Edit    : 
# version      : 1
####----------------------------------------------------------####
# Description  : 
####----------------------------------------------------------####

##################  remove any previous designs 
remove_design -all


################### set up power analysis mode #####################
# step 0: Define Top Module name 
set TOP pulpino_top_rtl_w_pads

################### set up power analysis mode #####################
# step 1: enalbe analysis mode 
set power_enable_analysis  true
set power_analysis_mode time_based

####################### set up libaries ############################
# step 2: link to your design libary 

### Make sure you choose the same files and paths as you have used in
### synthesis and pnr stage

set search_path "\
/usr/local-eit/cad2/cmpstm/stm065v536/CORE65LPLVT_5.1/libs/ \
/usr/local-eit/cad2/cmpstm/stm065v536/CLOCK65LPLVT_3.1/libs/ \
/usr/local-eit/cad2/cmpstm/oldmems/mem2010/SPHDL100909-40446@1.0/libs/  \
/usr/local-eit/cad2/cmpstm/dicp18/lu_pads_65nm/ "

set link_path   "* \
CLOCK65LPLVT_nom_1.20V_25C.db \
CORE65LPLVT_nom_1.20V_25C.db \
SPHDL100909_nom_1.20V_25C.db  \
Pads_Oct2012.db "

####################### design input    ############################
# step 3: read your design (netlist) & link design
read_verilog /h/dc/o/si3116uw-s/etin35-pulpino/pnr/outputs/pulpino_top_pnr.v
current_design $TOP
link_design -force

####################### timing constraint ##########################
# step 4: setup timing constraint (or read sdc file)
read_sdc /h/dc/o/si3116uw-s/etin35-pulpino/pnr/pulpino_top_rtl_w_pads_1.sdc -v 1.7

####################### Back annotate     ##########################
# step 5: back annotate delay information (read sdf file)
read_parasitics /h/dc/o/si3116uw-s/etin35-pulpino/pnr/outputs/pulpino_top_pnr.spef
read_sdf -type sdf_max /h/dc/o/si3116uw-s/etin35-pulpino/pnr/outputs/pulpino_top_pnr.sdf

################# read switching activity file #####################
# step 6: read vcd file obtained from post-layout (syn) simulation
read_vcd -strip_path /tb_ps/top_i /export/space/nobackup/si3116uw-s/refined_power_analysis.vcd

####################### analysis and report #################
# step 7: Analysis the power
check_power
update_power

####################### report  #################
# step 8: output report
report_power -verbose -hierarchy > /h/dc/o/si3116uw-s/etin35-pulpino/pnr/power_1.rpt
report_timing -delay_type min -max_paths 10 > /h/dc/o/si3116uw-s/etin35-pulpino/pnr/timing_hold_1.rpt
report_timing -delay_type max -max_paths 10 > /h/dc/o/si3116uw-s/etin35-pulpino/pnr/timing_setup_1.rpt
