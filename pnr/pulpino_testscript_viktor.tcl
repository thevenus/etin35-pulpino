
setMultiCpuUsage -local 6
setPlaceMode -place_global_uniform_density true
setPlaceMode -place_global_max_density 0.6
setPlaceMode -prerouteAsObs ""
setPlaceMode -fp false
placeDesign
checkFPlan -reportUtil
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS -drv
timeDesign -preCTS
timeDesign -preCTS -hold
set_ccopt_property inverter_cells { HS65_LL_CNIVX10 HS65_LL_CNIVX103 HS65_LL_CNIVX124
HS65_LL_CNIVX14 HS65_LL_CNIVX17 HS65_LL_CNIVX21 HS65_LL_CNIVX24
HS65_LL_CNIVX27 HS65_LL_CNIVX3 HS65_LL_CNIVX31 HS65_LL_CNIVX34 HS65_LL_CNIVX38
HS65_LL_CNIVX41 HS65_LL_CNIVX45 HS65_LL_CNIVX48 HS65_LL_CNIVX52 HS65_LL_CNIVX55
HS65_LL_CNIVX58 HS65_LL_CNIVX62 HS65_LL_CNIVX7 HS65_LL_CNIVX82}
set_ccopt_property buffer_cells {HS65_LL_CNBFX10 HS65_LL_CNBFX103 HS65_LL_CNBFX124
HS65_LL_CNBFX14 HS65_LL_CNBFX17 HS65_LL_CNBFX21 HS65_LL_CNBFX24
HS65_LL_CNBFX27 HS65_LL_CNBFX31 HS65_LL_CNBFX34 HS65_LL_CNBFX38
HS65_LL_CNBFX38_0 HS65_LL_CNBFX38_1 HS65_LL_CNBFX38_10 HS65_LL_CNBFX38_11
HS65_LL_CNBFX38_12 HS65_LL_CNBFX38_13 HS65_LL_CNBFX38_14 HS65_LL_CNBFX38_15
HS65_LL_CNBFX38_16 HS65_LL_CNBFX38_17 HS65_LL_CNBFX38_18
HS65_LL_CNBFX38_19 HS65_LL_CNBFX38_2 HS65_LL_CNBFX38_20 HS65_LL_CNBFX38_21
HS65_LL_CNBFX38_22 HS65_LL_CNBFX38_23 HS65_LL_CNBFX38_3 HS65_LL_CNBFX38_4
HS65_LL_CNBFX38_5 HS65_LL_CNBFX38_6 HS65_LL_CNBFX38_7 HS65_LL_CNBFX38_8
HS65_LL_CNBFX38_9 HS65_LL_CNBFX41 HS65_LL_CNBFX45 HS65_LL_CNBFX48
HS65_LL_CNBFX52 HS65_LL_CNBFX55 HS65_LL_CNBFX58 HS65_LL_CNBFX62 HS65_LL_CNBFX82 }
set hold_fixing_cells { HS65_LL_DLYIC2X7 HS65_LL_DLYIC2X9 HS65_LL_DLYIC4X4 HS65_LL_DLYIC4X7 HS65_LL_DLYIC4X9 HS65_LL_DLYIC6X4 HS65_LL_DLYIC6X7 HS65_LL_DLYIC6X9 }
create_ccopt_clock_tree_spec -file ./ccopt.spec
source ./ccopt.spec
ccopt_design
setOptMode -holdFixingCells { HS65_LL_DLYIC2X7 HS65_LL_DLYIC2X9 HS65_LL_DLYIC4X4 HS65_LL_DLYIC4X7 HS65_LL_DLYIC4X9 HS65_LL_DLYIC6X4 HS65_LL_DLYIC6X7 HS65_LL_DLYIC6X9 }

# Check if we need to optimize before doing anything else
setAnalysisMode -analysisType onChipVariation -cppr both
timeDesign -postCTS -hold
# We were at 		TNS	-6926		WNS	-0.473
optDesign -postCTS -hold -incr
# We got to 		TNS	-0.011		WNS	-0.011
# Our setup is fine, so lets not do anything there

report_ccopt_clock_trees -filename ./clktree_ccopt.rpt
report_ccopt_skew_groups -filename ./skewgrp_ccopt.rpt
report_ccopt_worst_chain -filename ./worstChain_ccopt.rpt

addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side n
fit
addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side s
fit
addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side w
fit
addIoFiller -cell PADSPACE_74x1u -prefix IO_FILLER -side e
fit


#	The result from the sroute looks a bit odd. You dont need to think about it at the moment, but if you have time later on you can fix it.
#	Some of the issues may resolve themselves regarding the special routing if you add the IO fillers before srouting
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { M1(1) AP(8) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { M1(1) AP(8) } -nets { GND VDD } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { M1(1) AP(8) }

setNanoRouteMode -quiet -routeWithTimingDriven true 
# Added this

setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
#setNanoRouteMode -quiet -routeWithTimingDriven false	# Removed this
#setNanoRouteMode -quiet -routeWithSiDriven false		# I believe this is false by default, so me commenting it out does nothing. But this is a reminder to myself that I may want to set it to true later one
routeDesign -globalDetail
# Check timing again
timeDesign -postRoute
# Setup is : 		TNS	0			WNS	0
timeDesign -postRoute -hold
# Hold is  : 		TNS	-7.652		WNS	-0.044
optDesign -incr -postRoute -hold
# Hold is  : 		TNS	-0.06		WNS	-0.048, max tran vio. Lets fix it
setOptMode -fixCap false -fixTran true -fixFanoutLoad false
# I mistakingly optimized setup :(
optDesign -postRoute -drv 

# So lets check hold timing again to see what the issue is..
timeDesign -postRoute -hold
# So the last opt for setup messed up a bit. Now we have..
# Hold is  : 		TNS	-1.718		WNS	-0.065
# Lets incr one more time to get us to baseline
optDesign -postRoute -incr -hold
# Hold is  : 		TNS	-0.000		WNS	-0.000		(Still 3 paths with vio's. I bet we can correct this with one more incr)
# hey.. lets add some positive slack just for the fun of it
setOptMode -holdTargetSlack 0.03
optDesign -postRoute -incr -hold
# noice!
# Setup is : 		TNS	0		WNS	4.218
# Hold is  : 		TNS	0		WNS	0.027

# At this point no timing issues. I did have max_length issue, but this is outside of the scope of this course.
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix pulpino_top_rtl_w_pads_postRoute -outDir timingReports
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix pulpino_top_rtl_w_pads_postRoute -outDir timingReports
timeDesign -postRoute
timeDesign -postRoute -hold
addFiller -cell HS65_LH_FILLERPFOP64 HS65_LH_FILLERPFOP32 HS65_LH_FILLERPFOP16 HS65_LH_FILLERPFOP12 HS65_LH_FILLERPFOP9 HS65_LH_FILLERPFOP8 HS65_LH_FILLERPFP4 HS65_LH_FILLERPFP3 HS65_LH_FILLERPFP2 HS65_LH_FILLERPFP1 -prefix FILLER -markFixed

# writing to output files
write_sdf outputs/pulpino_top_pnr.sdf
saveNetlist outputs/pulpino_top_pnr.v
rcOut -spf outputs/pulpino_top_pnr.spf -rc_corner SS
rcOut -spef outputs/pulpino_top_pnr.spef -rc_corner SS
saveDesign pulpino_top_rtl_w_pads_1



