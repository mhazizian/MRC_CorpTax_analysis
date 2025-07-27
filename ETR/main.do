// ssc install egenmore
// ssc inst _gwtmean, replace
// ssc install niceloglabels 
// ssc install astile
// ssc install dataex
// net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace
// findit grc1leg // then install vwiggins version.
// set scheme s2color, perm
set scheme cleanplots, perm


clear all
frame reset
graph set window fontface "B Nazanin"
graph drop _all

global geo_dir "~/Documents/Data/geo_data"


global include_aastan 1
global include_139 1
global include_maghtou 1
global is_sharif_version 0

global dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// global dir "~\Documents\Majlis RC\data\tax_return\sharif"
// global dir "D:\Data_Output\Hoghooghi"


global out_dir "./out__M${include_maghtou}_C${include_139}_A${include_aastan}"
// global out_dir "./out/maghtou_income_excluded"



do "ETR/data_preparations.do"
do "./identify_corporates.do"

save "$out_dir/dta/corp_cleaned_data_isSharif$is_sharif_version.dta", replace
use "$out_dir/dta/corp_cleaned_data_isSharif$is_sharif_version.dta", clear

//
// gen eq_total_exemption = agr_moafiat
// replace eq_total_exemption = eq_total_exemption - agr_maghtou if !missing(agr_maghtou)
// replace eq_total_exemption = eq_total_exemption + (agr_bakhshoudegi * 4) if !missing(agr_bakhshoudegi)
//
// gen is_high_exemption = (eq_total_exemption > 500 * 1000 * 1000 * 1000 & !missing(eq_total_exemption))



// ####### Yearly Charts ##############

global year 1401
do "ETR/graph_drawer.do"


// ####### Time Series  ###############

do "ETR/time_series_output.do"


// ############################################
// ######### Exemption and Sector #############
// ############################################

// @ MRC data
// Amend dataSet:


// do "Exemption&Sector/data_preparations-2.do"
// do "Exemption&Sector/add_province_id.do"


global drop_frame 0
do "Exemption&Sector/create_helper_frames.do"


global year 1400
do "Exemption&Sector/tax_exp_components_anlys.do"


do "Exemption&Sector/exemption_analysis_agr.do"
do "Exemption&Sector/exemption_analysis.do"
do "Exemption&Sector/bakhshoodegi_analysis.do"




do "Exemption&Sector/graph_drawer2.do"




// ####### Moafiat & Bakhshoodegi #####

do "ETR/moafiat-bakhshoodegi.do"

// ###### Sector Analisys #############

if $is_sharif_version == 0 {
	do "ETR/sector_analysis.do"
}

// ###### Geo Analisys #############

if $is_sharif_version == 0 {
	
	do "Exemption&Sector/add_province_id.do"
	
	do "Exemption&Sector/sp_map.do"
}





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

