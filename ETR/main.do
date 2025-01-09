clear
frame reset
graph set window fontface "B Nazanin"
graph drop _all

// ssc install egenmore
// ssc inst _gwtmean, replace
// ssc install niceloglabels 
// ssc install astile
// ssc install dataex
// net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace
// set scheme s2color, perm
set scheme cleanplots, perm


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

// ################################## Time Series  ############################


egen total_profit_ebrazi = sum(profit_ebrazi), by(actyear)
egen total_profit_ghati = sum(profit_ghati_cal), by(actyear)

egen sum_tax_ebrazi_yearly = sum(tax_ebrazi), by(actyear)
egen sum_tax_ghati_yearly  = sum(tax_ghati)	, by(actyear)

gen  share_of_t_profit_e   = profit_ebrazi / total_profit_ebrazi
gen  share_of_t_profit_g   = profit_ghati_cal / total_profit_ghati

gen etr_ebrazi_agr_yearly = sum_tax_ebrazi_yearly / total_profit_ebrazi
gen etr_ghati_agr_yearly  = sum_tax_ghati_yearly / total_profit_ghati

egen sum_lost_income_ebrazi = sum(lost_income_ebrazi2), by(actyear)


local percent 0.01 
display "###########  corporate with etr_ebrazi < `percent' ########"

egen lp_sum_lost_income_ebrazi	 = sum( lost_income_ebrazi2 * (etr_ebrazi < `percent')), by(actyear)
egen lp_sum_lost_income_ebrazi_g = sum( lost_income_ebrazi2 * (etr_ghati_s < `percent')), by(actyear)

egen percent_of_lp_ebrazi   = mean(etr_ebrazi  <= `percent'), by(actyear)
egen percent_of_lp_ghati    = mean(etr_ghati_s <= `percent'), by(actyear)


egen lp_profit_share_ebrazi   = sum(profit_ebrazi * (etr_ebrazi  <= `percent')), by(actyear)
	replace lp_profit_share_ebrazi = lp_profit_share_ebrazi / total_profit_ebrazi
label variable lp_profit_share_ebrazi "سهم شرکت‌های با نرخ موثر ابرازی ۰ تا ۱ درصد از کل سود در سال"

	
egen lp_profit_share_ghati   = sum(profit_ghati_cal * (etr_ghati_s  <= `percent')), by(actyear)
	replace lp_profit_share_ghati = lp_profit_share_ghati / total_profit_ghati
label variable lp_profit_share_ghati "سهم شرکت‌های با نرخ موثر قطعی ۰ تا ۱ درصد از کل سود در سال"

preserve
	keep if percentile_g == 100
	keep actyear ///
		etr_ebrazi_agr_yearly ///
		etr_ghati_agr_yearly ///
		sum_lost_income_ebrazi /*
		
		less than 1 percent rate:
		
		*/ lp_sum_lost_income_ebrazi ///
		lp_sum_lost_income_ebrazi_g ///
		percent_of_lp_ebrazi ///
		percent_of_lp_ghati ///
		lp_profit_share_ebrazi /// 
		lp_profit_share_ghati /*
		
		percentile 100 stats:
		
		*/ zero_rate_percent_ebrazi ///
		zero_rate_percent_ghati_s ///
		avg_etr_ebrazi_percentile ///
		avg_etr_ghati_percentile 
	duplicates drop
	export excel "ETR_timeSeries_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
restore



// ################################# Sector Analisys ####################################

replace T00_ActivityTypeName = -1 if missing(T00_ActivityTypeName)

egen t_profit_ebrazi_by_activity = sum(profit_ebrazi)	, by(actyear T00_ActivityTypeName)
egen t_profit_ghati_by_activity = sum(profit_ghati_cal)	, by(actyear T00_ActivityTypeName)
egen t_tax_ebrazi_by_activity = sum(tax_ebrazi)			, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_by_activity = sum(tax_ghati)			, by(actyear T00_ActivityTypeName)
egen count_by_activity = sum(!missing(trace_id))		, by(actyear T00_ActivityTypeName)

gen etr_ebrazi_by_activity = t_tax_ebrazi_by_activity / t_profit_ebrazi_by_activity
gen etr_ghati_by_activity  = t_tax_ghati_by_activity  / t_profit_ghati_by_activity

egen t_lost_income_by_act = sum(lost_income_ebrazi2), by(actyear T00_ActivityTypeName)


egen count_percentile100 = sum(percentile_g == 100)		, by(actyear T00_ActivityTypeName)
egen t_profit_ghati_p100_by_activity = sum(profit_ghati_cal * (percentile_g == 100)) ///
		, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_p100_by_activity = sum(tax_ghati * (percentile_g == 100)) ///
		, by(actyear T00_ActivityTypeName)
egen t_lost_income_by_act_p100 = sum(lost_income_ebrazi2 * (percentile_g == 100)), by(actyear T00_ActivityTypeName)




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
		t_lost_income_by_act_p100

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

