frame change default

frame copy default output_frame, replace
frame change output_frame

*******************

replace T00_ActivityTypeName = -1 if missing(T00_ActivityTypeName)

egen t_profit_ebrazi_by_activity = sum(profit_ebrazi)	, by(actyear T00_ActivityTypeName)
egen t_profit_ghati_by_activity = sum(profit_ghati_cal)	, by(actyear T00_ActivityTypeName)
egen t_tax_ebrazi_by_activity = sum(tax_ebrazi)			, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_by_activity = sum(tax_ghati)			, by(actyear T00_ActivityTypeName)
egen count_by_activity = sum(!missing(etr_ghati_s))		, by(actyear T00_ActivityTypeName)

gen etr_ebrazi_by_activity = t_tax_ebrazi_by_activity / t_profit_ebrazi_by_activity
gen etr_ghati_by_activity  = t_tax_ghati_by_activity  / t_profit_ghati_by_activity

egen t_lost_income_by_act = sum(lost_income_ebrazi2)	, by(actyear T00_ActivityTypeName)

************ percentile 100
egen count_percentile100 = sum(percentile_g == 100)		, by(actyear T00_ActivityTypeName)
egen t_profit_ghati_p100_by_activity = sum(profit_ghati_cal * (percentile_g == 100)) ///
		, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_p100_by_activity = sum(tax_ghati * (percentile_g == 100)) ///
		, by(actyear T00_ActivityTypeName)
gen etr_ghati_p100_by_act = t_tax_ghati_p100_by_activity / t_profit_ghati_p100_by_activity
egen t_lost_income_by_act_p100 = sum(lost_income_ebrazi2 * (percentile_g == 100)), by(actyear T00_ActivityTypeName)



*********** zero ETR
egen count_ZeroETR = sum(etr_ghati_s <= 0.01)			, by(actyear T00_ActivityTypeName)
egen t_profit_ghati_ZETR_by_activity = sum(profit_ghati_cal * (etr_ghati_s <= 0.01)) ///
		, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_ZETR_by_activity = sum(tax_ghati * (etr_ghati_s <= 0.01)) ///
		, by(actyear T00_ActivityTypeName)
gen etr_ghati_ZETR_by_act = t_tax_ghati_ZETR_by_activity / t_profit_ghati_ZETR_by_activity
egen t_lost_income_by_act_ZETR = sum(lost_income_ebrazi2 * (etr_ghati_s <= 0.01)), by(actyear T00_ActivityTypeName)


*********** zero ETR & percentile 100
egen count_ZeroETRP100 = sum(etr_ghati_s <= 0.01 & percentile_g == 100)			, by(actyear T00_ActivityTypeName)
egen t_profit_ghati_ZETRP100_by_act = sum(profit_ghati_cal * (etr_ghati_s <= 0.01 & percentile_g == 100)) ///
		, by(actyear T00_ActivityTypeName)
		
egen t_tax_ghati_ZETRP100_by_act = sum(tax_ghati * (etr_ghati_s <= 0.01 & percentile_g == 100)) ///
		, by(actyear T00_ActivityTypeName)
		
gen etr_ghati_ZETRP100_by_act = t_tax_ghati_ZETRP100_by_act / t_profit_ghati_ZETRP100_by_act
egen t_lost_income_by_act_ZETRP100 = sum(lost_income_ebrazi2 * (etr_ghati_s <= 0.01 & percentile_g == 100)), by(actyear T00_ActivityTypeName)





// TODO: top corp Sector analyis
preserve
	keep if percentile_g == 100
	
	keep actyear ///
		T00_ActivityTypeName ///
		count_by_activity ///
		t_profit_ebrazi_by_activity ///
		t_profit_ghati_by_activity ///
		t_tax_ebrazi_by_activity ///
		t_tax_ghati_by_activity ///
		etr_ebrazi_by_activity ///
		etr_ghati_by_activity ///
		t_lost_income_by_act /*
		
		percentile 100:
		
		*/ count_percentile100 ///
		t_profit_ghati_p100_by_activity ///
		t_tax_ghati_p100_by_activity ///
		etr_ghati_p100_by_act ///
		t_lost_income_by_act_p100 /*
		
		Zero Rate ETR
		
		*/ count_ZeroETR ///
		t_profit_ghati_ZETR_by_activity ///
		t_tax_ghati_ZETR_by_activity ///
		etr_ghati_ZETR_by_act /// 
		t_lost_income_by_act_ZETR /*
		
		Zero Rate ETR & percentile 100
		
		*/ count_ZeroETRP100 ///
		t_profit_ghati_ZETRP100_by_act ///
		t_tax_ghati_ZETRP100_by_act ///
		etr_ghati_ZETRP100_by_act /// 
		t_lost_income_by_act_ZETRP100
		

	duplicates drop
	export excel "$out_dir/Corp by ActivityType.xlsx", firstrow(varl) replace
restore
	 
	 

frame change default
frame drop output_frame
	 