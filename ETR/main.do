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

// ####### Yearly Charts ########

global year 1400
do "ETR/graph_drawer.do"

// ######### Lost Income ############


egen sum_lost_income_percentile = sum(lost_income_ebrazi2), by(actyear percentile)

// gen tax_exp_to_profit_eb = avg_lost_income_percentile_eb / avg_profit_percentile
// egen tax_exp_to_profit_eb = mean(lost_income_ebrazi2 / profit_ebrazi), by(actyear percentile)

local year 1400
graph drop _all

preserve
	keep if actyear == `year'
	
	
	niceloglabels sum_lost_income_percentile if actyear == `year', local(yla) style(1) powers
	line sum_lost_income_percentile percentile if actyear == `year', ///
		sort ///
		yscale(log) yla(`yla', ang(h)) ///
		ytitle(درآمد از دست رفته دولت ابرازی) xtitle(صدک شرکت) ///
		title(درآمد از دست رفته دولت در صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export decile_lost_income_eb_`year'.png, as(png) replace
	
// 	line tax_exp_to_profit_eb percentile if actyear == `year' & percentile > 10, ///
// 		sort ///
// 		ytitle(نسبت مخارج مالیاتی به سود شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط نسبت مخارج مالیاتی به سود شرکت در هر صدک -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_lost_income_to_profit_eb_`year'.png, as(png) replace
	
	gsort -lost_income_ebrazi2
	gen idx = _n
	cumul idx [w=int(lost_income_ebrazi2)], gen(lost_income_cumul)
	gsort -lost_income_cumul
	line lost_income_cumul idx if idx < 500, name(LI0_`year') ///
		title("سال `year'") ytitle(سهم از درآمد از دست رفته دولت) xtitle(تعداد شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))

	graph export LI0_`year'.png, as(png) replace
restore

// ##########################################################################################
// ################################## ETR stats --- Time Series  ############################


egen total_profit_ebrazi = sum(profit_ebrazi), by(actyear)
gen  share_of_t_profit   = profit_ebrazi / total_profit_ebrazi
gsort -share_of_t_profit

egen sum_tax_ebrazi_yearly 	  = sum(tax_ebrazi)   , by(actyear)
egen sum_profit_ebrazi_yearly = sum(profit_ebrazi), by(actyear)
gen etr_ebrazi_agr_yearly = sum_tax_ebrazi_yearly / sum_profit_ebrazi_yearly

egen sum_lost_income_ebrazi = sum(lost_income_ebrazi2), by(actyear)



local percent 0.01 
display "##################  corporate with etr_ebrazi < `percent' ########"

egen lp_sum_lost_income_ebrazi = sum( lost_income_ebrazi2 * (etr_ebrazi < `percent')), by(actyear)

gen lp_is_etr_ebrazi = etr_ebrazi
replace lp_is_etr_ebrazi = . if missing(etr_ebrazi)
replace lp_is_etr_ebrazi = . if etr_ebrazi >= `percent'

egen lp_percent_etr_ebrazi = mean(lp_is_etr_ebrazi), by(actyear)
egen lp_percent_etr_ebrazi_w = wtmean(lp_is_etr_ebrazi), by(actyear) weight(profit_ebrazi)

preserve
	keep actyear ///
		etr_ebrazi_agr_yearly ///
		sum_lost_income_ebrazi ///
		lp_sum_lost_income_ebrazi ///
		lp_percent_etr_ebrazi ///
		lp_percent_etr_ebrazi_w
	duplicates drop
	export excel "Corp - ETR timeSeries - Ebrazi.xlsx", firstrow(varl) replace
restore


// ################# GHATI ##################
preserve 
	drop if missing(tax_ghati)
	drop if is_not_audited
	drop if tax_ghati < 0
	
	
	egen sum_tax_ghati_yearly 	  = sum(tax_ghati)   , by(actyear)
	gen etr_ghati_agr_yearly = sum_tax_ghati_yearly / sum_profit_ebrazi_yearly

	egen sum_lost_income_ghati = sum(lost_income_ghati), by(actyear)

	
	local percent 0.01
	display "##################  corporate with etr_ghati < `percent' ########"
	
	egen lp_sum_lost_income_ghati = sum( lost_income_ghati * (etr_ghati < `percent')), by(actyear)
	
	gen lp_is_etr_ghati = etr_ghati
	replace lp_is_etr_ghati = . if missing(etr_ghati)
	replace lp_is_etr_ghati = . if etr_ghati >= `percent'
	
	egen lp_percent_etr_ghati = mean(lp_is_etr_ghati), by(actyear)
	egen lp_percent_etr_ghati_w = wtmean(lp_is_etr_ghati), by(actyear) weight(profit_ebrazi)
	
	keep actyear ///
		etr_ghati_agr_yearly ///
		sum_lost_income_ghati ///
		lp_sum_lost_income_ghati ///
		lp_percent_etr_ghati ///
		lp_percent_etr_ghati_w
	duplicates drop
	export excel "Corp - ETR timeSeries - Ghati.xlsx", firstrow(varl) replace

restore	


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


// ################################# Sector Analisys ####################################

replace T00_ActivityTypeName = -1 if missing(T00_ActivityTypeName)

egen t_profit_ebrazi_by_activity = sum(profit_ebrazi)	, by(actyear T00_ActivityTypeName)
egen t_tax_ebrazi_by_activity = sum(tax_ebrazi)			, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_by_activity = sum(tax_ghati)			, by(actyear T00_ActivityTypeName)
egen count_by_activity = count(profit_ebrazi)			, by(actyear T00_ActivityTypeName)

gen etr_ebrazi_by_activity = t_tax_ebrazi_by_activity / t_profit_ebrazi_by_activity
gen etr_ghati_by_activity  = t_tax_ghati_by_activity  / t_profit_ebrazi_by_activity


egen sum_lost_income_ebrazi_by_act = sum(lost_income_ebrazi2), by(actyear T00_ActivityTypeName)
egen sum_lost_income_ghati_by_act  = sum(lost_income_ghati) , by(actyear T00_ActivityTypeName)

// tabdisp T00_ActivityTypeName if actyear == 1401, cellvar(t_profit_ebrazi_by_activity ///
// 	t_tax_ebrazi_by_activity ///
// 	t_tax_ghati_by_activity ///
// 	etr_ebrazi_by_activity ///
// 	etr_ghati_by_activity)
//	
// tabdisp T00_ActivityTypeName if actyear == 1401, cellvar(sum_lost_income_ebrazi_by_act ///
// 	sum_lost_income_ghati_by_act)
//	

preserve
	keep actyear T00_ActivityTypeName count_by_activity ///
		t_profit_ebrazi_by_activity ///
		t_tax_ebrazi_by_activity ///
		t_tax_ghati_by_activity ///
		etr_ebrazi_by_activity ///
		etr_ghati_by_activity ///
		sum_lost_income_ebrazi_by_act ///
		sum_lost_income_ghati_by_act

	duplicates drop
	export excel "Corp by ActivityType.xlsx", firstrow(varl) replace
restore
	 