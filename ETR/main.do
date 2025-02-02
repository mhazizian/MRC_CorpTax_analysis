// ssc install egenmore
// ssc inst _gwtmean, replace
// ssc install niceloglabels 
// ssc install astile
// ssc install dataex
// net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace
// set scheme s2color, perm
set scheme cleanplots, perm


clear
frame reset
graph set window fontface "B Nazanin"
graph drop _all


global is_sharif_version 0
global dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// global dir "~\Documents\Majlis RC\data\tax_return\sharif"
// global dir "D:\Data_Output\Hoghooghi"




do "ETR/data_preparations.do"

save "corp_cleaned_data_isSharif$is_sharif_version.dta", replace
use "corp_cleaned_data_isSharif$is_sharif_version.dta", clear

// replace agr_moafiat = 0 if missing(agr_moafiat)
// replace agr_bakhshoudegi = 0 if missing(agr_bakhshoudegi)
// gen agr_m = agr_moafiat + agr_maghtou 
// tabstat agr_moafiat agr_m T26_R04 agr_bakhshoudegi T26_R16, s(sum) by(actyear)


// ####### Yearly Charts ########

global year 1400
do "ETR/graph_drawer.do"

// ####### Moafiat & Bakhshoodegi ########

do "ETR/moafiat-bakhshoodegi.do"

// ####### Time Series  ##########

do "ETR/time_series_output.do"

// ################################# Sector Analisys ####################################

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
	export excel "Corp by ActivityType.xlsx", firstrow(varl) replace
restore
	 
	 
//
//
//
//
//
//
//
//
//
//
//
//
// 
// ################# TopCorp ##################

local topCorp 20
gsort -share_of_t_profit
graph drop _all

preserve
	drop if missing(profit_ebrazi)
	
	bysort actyear (share_of_t_profit): gen topCorp = (_N - _n < `topCorp')
	keep if topCorp == 1
		
	drop if tax_ghati < 0
	drop if missing(share_of_t_profit)
	drop if missing(tax_ghati)
	drop if is_not_audited
	tab actyear
		
	egen sum_total_share = sum(share_of_t_profit), by(actyear)
	
	egen sum_tax_ebrazi_yearly_topCorp 	  = sum(tax_ebrazi), by(actyear)
	egen sum_profit_ebrazi_yearly_topCorp = sum(profit_ebrazi), by(actyear)
	gen etr_ebrazi_agr_yearly_topCorp     = sum_tax_ebrazi_yearly_topCorp / sum_profit_ebrazi_yearly_topCorp
	
	egen sum_lost_income_ebrazi_topCorp = sum(lost_income_ebrazi2), by(actyear)

	// ### Ghati
	egen sum_tax_ghati_yearly_topCorp = sum(tax_ghati)   , by(actyear)
	gen etr_ghati_agr_yearly_topCorp  = sum_tax_ghati_yearly_topCorp / sum_profit_ebrazi_yearly_topCorp

	egen sum_lost_income_ghati_topCorp = sum(lost_income_ghati), by(actyear)
	
	
	// ### Charts
	local year 1401
	hist etr_ebrazi2 if actyear == `year' [w=int(share_of_t_profit * 10000)] , bin(26) percent name(tc1)  ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_`year'_ebrazi_w.png, as(png) replace
	
	hist etr_ebrazi2 if actyear == `year', bin(26) percent name(tc1_)  ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_`year'_ebrazi.png, as(png) replace
	
	
	hist etr_ghati2 if actyear == `year' [w=int(share_of_t_profit * 10000)], bin(26) percent name(tc2) ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_`year'_ghati_w.png, as(png) replace
		
	hist etr_ghati2 if actyear == `year', bin(26) percent name(tc2_) ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_`year'_ghati.png, as(png) replace
	
	

	keep actyear ///
		sum_total_share ///
		etr_ebrazi_agr_yearly_topCorp ///
		sum_lost_income_ebrazi_topCorp ///
		etr_ghati_agr_yearly_topCorp ///
		sum_lost_income_ghati_topCorp

	duplicates drop
	export excel "Corp - ETR timeSeries - topCorp_`topCorp'.xlsx", firstrow(varl) replace

restore

