clear
frame reset
graph set window fontface "B Nazanin"
graph drop _all

// ssc install egenmore
// ssc inst _gwtmean, replace
// ssc install niceloglabels 
// ssc install astile
// net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace

set scheme cleanplots, perm
// set scheme s2color, perm


// local dir "D:\Data_Output\Hoghooghi"
local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\sharif"


use "`dir'\Mohasebe_Maliat.dta", clear
drop if missing(actyear)


// @@@ Sharif Version.
// gsort -T26_R01 
// egen flag = tag(id actyear)
// duplicates drop id actyear flag, force
// drop if flag == 0
// drop flag
// merge 1:1 id actyear using "`dir'\Sanim.dta"
// rename maliyat_ghati tax_ghati
// rename maliyat_tashkhis tax_tashkhisi


// @@@ MRC Version
merge 1:1 trace_id actyear using "`dir'\Legal_Person_Information.dta"
rename maliat_ghatee tax_ghati
rename maliat_tashkhisi tax_tashkhisi


drop _merge


// ##### Gen <profit_ebrazi> & <tax_ebrazi>
gen tax_ebrazi = T26_R25
replace tax_ebrazi = tax_ebrazi + T26_R23 if !missing(T26_R23)

gen profit_ebrazi = 0
replace profit_ebrazi = profit_ebrazi + T26_R01 if !missing(T26_R01)
// replace profit_ebrazi = profit_ebrazi + T26_R02 if !missing(T26_R02)
// replace profit_ebrazi = profit_ebrazi + T26_R03 if !missing(T26_R03)
replace profit_ebrazi = . if missing(T26_R01) //& missing(T26_R02) & missing(T26_R03) 


// ############################ Not Audited cases ################################

gen is_not_audited = 0

replace is_not_audited = 1 if missing(tax_ghati)
replace is_not_audited = 1 if (tax_ghati == 0) & (tax_tashkhisi > 0) & (tax_ebrazi > 0) ///
	& !missing(tax_ghati) & !missing(tax_ebrazi) & !missing(tax_tashkhisi)
// replace is_not_audited = 1 if (tax_ghati == 0) & tax_ebrazi == 0 & missing(tax_tashkhisi)


// ###### Apply DadRessi Effect! #########

gen dadressi_effect = tax_ghati / tax_tashkhisi

// TODO: check this #outlier fix
replace dadressi_effect = 1 if dadressi_effect > 1 & !missing(dadressi_effect)

// egen avg_dadressi_effect = mean(dadressi_effect), by(actyear)
egen avg_dadressi_effect = mean(dadressi_effect)
tabdisp actyear , c(avg_dadressi_effect)


gen tax_ghati_is_est = 0
replace tax_ghati_is_est = 1 if (is_not_audited == 1) & !missing(tax_tashkhisi) ///
	& (tax_tashkhisi > 0)

replace tax_ghati = tax_tashkhisi * avg_dadressi_effect if tax_ghati_is_est == 1 ///
	& !missing(avg_dadressi_effect)
replace is_not_audited = 0 if tax_ghati_is_est == 1


tab actyear is_not_audited, row // 0.09% of all records.
tab actyear is_not_audited [w=profit_ebrazi] if profit_ebrazi >= 0, row // 0.07% of total profit of all records.
// tax_ghati in years before 1396 is not reliable.


// ############################# Cleaning ####################################

drop if missing(actyear)

drop if missing(profit_ebrazi)
drop if missing(tax_ebrazi) & missing(tax_ghati)


// inactive corporates:
drop if profit_ebrazi == 0
drop if profit_ebrazi < 5 // TODO: what to do ....


// corporate with loss:
drop if profit_ebrazi < 0 


// tab actyear if tax_ebrazi < 0
replace tax_ebrazi = 0 if tax_ebrazi < 0
drop if tax_ghati < 0

// tab actyear is_not_audited, row 					 // 0.16% of all records.
// tab actyear is_not_audited [w=profit_ebrazi], row // 0.07% of total value of all records.

// drop if is_not_audited == 1


tab actyear

// ############################## Merge with Moafiat #########################

frame create Moafiat_frame
frame change Moafiat_frame

// local dir "D:\Data_Output\Hoghooghi"
local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\sharif"


use "`dir'\Moafiat.dta", clear

drop if missing(actyear)

// maliat maghtoo:
egen agr_maghtou = sum(Exempted_Profit * (exemption_id == 35)), by(trace_id)
drop if exemption_id == 35

egen agr_moafiat = sum(Exempted_Profit), by(trace_id)
keep trace_id agr_moafiat agr_maghtou
duplicates drop

frame change default
frlink 1:1 trace_id, frame(Moafiat_frame)

frget agr_moafiat, from(Moafiat_frame)
frget agr_maghtou, from(Moafiat_frame)
frame drop Moafiat_frame
drop Moafiat_frame


// Bakhshoodegi:
frame create Bakhshodegi_frame
frame change Bakhshodegi_frame

// local dir "D:\Data_Output\Hoghooghi"
local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\sharif"


use "`dir'\Bakhshhodegi.dta", clear

egen agr_bakhshoudegi = sum(Rebate_Amount), by(trace_id)
keep trace_id agr_bakhshoudegi
duplicates drop

frame change default
frlink 1:1 trace_id, frame(Bakhshodegi_frame)
frget agr_bakhshoudegi, from(Bakhshodegi_frame)
frame drop Bakhshodegi_frame
drop Bakhshodegi_frame

// ############################## Calculation! #################################

gen profit_ghati_cal = .
replace profit_ghati_cal = tax_ghati if !missing(tax_ghati)
replace profit_ghati_cal = profit_ghati_cal + T26_R21 if !missing(T26_R21) // maliyat daramad etefaghi
replace profit_ghati_cal = profit_ghati_cal + agr_bakhshoudegi if !missing(agr_bakhshoudegi) // Bakhshodegi
// replace profit_ghati_cal = profit_ghati_cal + T26_R16 if !missing(T26_R16) // Bakhshodegi

replace profit_ghati_cal = profit_ghati_cal * 4

replace profit_ghati_cal = profit_ghati_cal + T26_R13 if !missing(T26_R13) 			// Otagh Bazargani
replace profit_ghati_cal = profit_ghati_cal + T26_R11 if !missing(T26_R11)			// Khesarat Made 165
replace profit_ghati_cal = profit_ghati_cal + T26_R10 if !missing(T26_R10) 			// Estehlak Anbashte
replace profit_ghati_cal = profit_ghati_cal + T26_R06 if !missing(T26_R06)			// Komak Mali Pardakhti
replace profit_ghati_cal = profit_ghati_cal + agr_moafiat if !missing(agr_moafiat) 	// Moafiat
replace profit_ghati_cal = profit_ghati_cal + agr_moafiat if !missing(agr_maghtou) 	// Maliat Maghtou
replace profit_ghati_cal = profit_ghati_cal + T26_004 if !missing(T26_004) 			// Maliat Maghtou
// replace profit_ghati_cal = profit_ghati_cal + T26_R04 if !missing(T26_R04) 		// Moafiat
replace profit_ghati_cal = profit_ghati_cal - T26_R02 if !missing(T26_R02) 			// going for Sood Vije
replace profit_ghati_cal = profit_ghati_cal - T26_R03 if !missing(T26_R03) 			// going for Sood Vije
replace profit_ghati_cal = profit_ghati_cal - T26_R08 if !missing(T26_R08) 			// Zian Gheir Moaf

replace profit_ghati_cal = . if missing(tax_ghati)
replace profit_ghati_cal = 0 if profit_ghati_cal < 0

// TODO: check this decision.
replace profit_ghati_cal = profit_ebrazi if profit_ghati_cal < profit_ebrazi ///
	& !missing(profit_ebrazi)



gen etr_ebrazi  = tax_ebrazi / profit_ebrazi
gen etr_ghati  = tax_ghati / profit_ebrazi 
gen etr_ghati_s = tax_ghati / profit_ghati_cal


gen etr_ebrazi2 = etr_ebrazi
	replace etr_ebrazi2 = 0.26001 if etr_ebrazi > 0.25 & !missing(etr_ebrazi)

gen etr_ghati2 = etr_ghati
	replace etr_ghati2 = 0.26001 if etr_ghati > 0.25 & !missing(etr_ghati)

gen etr_ghati_s2 = etr_ghati_s
	replace etr_ghati_s2 = 0.26001 if etr_ghati_s > 0.25 & !missing(etr_ghati_s)


// gen lost_income_ebrazi = (profit_ebrazi * 0.25 - tax_ebrazi)

gen lost_income_ghati  = (profit_ebrazi * 0.25 - tax_ghati) 
// 	replace lost_income_ghati = (profit_ebrazi * 0.25 - tax_tashkhisi)  if missing(tax_ghati)
	replace lost_income_ghati = 0 if lost_income_ghati < 0
	
gen lost_income_ebrazi2 = 0
	replace lost_income_ebrazi2 = lost_income_ebrazi2 + agr_moafiat * 0.25 if !missing(agr_moafiat)
	replace lost_income_ebrazi2 = lost_income_ebrazi2 + agr_bakhshoudegi if !missing(agr_bakhshoudegi)
	replace lost_income_ebrazi2 = 0 if lost_income_ebrazi2 < 0
	replace lost_income_ebrazi2 = . if missing(agr_moafiat) & missing(agr_bakhshoudegi)

	
// TODO: check this #outlier fix.
drop if etr_ghati_s > 10 & !missing(etr_ghati_s)
drop if etr_ebrazi  > 10 & !missing(etr_ebrazi)

// replace etr_ghati_s = 10 if etr_ghati_s > 10 & !missing(etr_ghati_s)

// ################################ Duplicates Drop ####################

// gsort -profit_ebrazi
gsort -profit_ghati_cal
egen flag = tag(id actyear)
duplicates drop id actyear flag, force
drop if flag == 0
drop flag


// ############################### Deciles ##############################

// egen percentile = xtile(profit_ebrazi) 		, by(actyear) nq(100)
// egen percentile_g = xtile(profit_ghati_cal) , by(actyear) nq(100)
astile percentile 	= profit_ebrazi		, nq(100) by(actyear)
astile percentile_g = profit_ghati_cal	, nq(100) by(actyear)



replace profit_ghati_cal = -1 if missing(profit_ghati_cal)	
gsort -profit_ghati_cal
bysort actyear (profit_ghati_cal): gen top1000 = (_N - _n < 1000)
bysort actyear (profit_ghati_cal): gen top500 = (_N - _n < 500)
bysort actyear (profit_ghati_cal): gen top200 = (_N - _n < 200)
replace profit_ghati_cal = . if profit_ghati_cal == -1	

egen avg_profit_percentile   = mean(profit_ebrazi)		, by(actyear percentile)
egen avg_profit_g_percentile = mean(profit_ghati_cal)	, by(actyear percentile_g)


egen zero_rate_percent_ebrazi   = mean(etr_ebrazi <= 0.01)	, by(actyear percentile)
egen zero_rate_percent_ghati    = mean(etr_ghati <= 0.01)   , by(actyear percentile_g)
egen zero_rate_percent_ghati_s  = mean(etr_ghati_s <= 0.01) , by(actyear percentile_g)

egen low_rate_percent_ebrazi   = mean(etr_ebrazi <= 0.05)	, by(actyear percentile)
egen low_rate_percent_ghati    = mean(etr_ghati <= 0.05)    , by(actyear percentile_g)
egen low_rate_percent_ghati_s  = mean(etr_ghati_s <= 0.05)  , by(actyear percentile_g)


egen avg_etr_ghati_percentile  = mean(etr_ghati_s), by(actyear percentile_g)
egen avg_etr_ebrazi_percentile = mean(etr_ebrazi) if etr_ebrazi < 20, by(actyear percentile)


// ############################### Yearly Charts #########################
frame change default
local year 1400
graph drop _all

frame copy default graph_frame, replace
frame change graph_frame
	keep if actyear == `year'

frame copy graph_frame graph_frame_e, replace
frame copy graph_frame graph_frame_g, replace

frame change graph_frame_e
	drop if missing(tax_ebrazi)

frame change graph_frame_g
	drop if is_not_audited == 1
// 	drop if profit_ghati_cal == 0



frame change graph_frame

// 	niceloglabels avg_profit_percentile , local(yla) style(1) powers
// 	line avg_profit_percentile percentile , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_`year'.png, as(png) replace
//		
//		
// 	niceloglabels avg_profit_g_percentile , local(yla) style(1) powers
// 	line avg_profit_g_percentile percentile_g , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_g_`year'.png, as(png) replace
	
	niceloglabels avg_profit_percentile , local(yla) style(1) powers
	twoway ///		
		( line avg_profit_g_percentile percentile_g	, sort ) ///
		( line avg_profit_percentile percentile		, sort ), ///
		legend(order(1 "سود محاسبه شده" 2 "سود ابرازی") pos(6) rows(1)) ///
		yscale(log) yla(`yla', ang(h)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
		title(متوسط سود ویژه ابرازی صدک‌ها -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export C00_`year'.png, as(png) replace	

	
	twoway ///		
		( line avg_etr_ghati_percentile  percentile_g	, sort ) ///
		( line avg_etr_ebrazi_percentile percentile	, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط نرخ مالیات موثر شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export C01_`year'.png, as(png) replace
	
	
	twoway ///		
		( line low_rate_percent_ghati_s percentile_g	, sort ) ///
		( line low_rate_percent_ebrazi percentile		, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۵ درصد در صدک‌ها -‍ `year'‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۵ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
	graph export C03_`year'.png, as(png) replace
	

	twoway ///		
		( line zero_rate_percent_ghati_s percentile_	, sort ) ///
		( line zero_rate_percent_ebrazi  percentile		, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
	graph export C04_`year'.png, as(png) replace
	
	
// ##############	
frame change graph_frame_e
// graph drop _all
	
	tab actyear
	
	line avg_etr_ebrazi_percentile percentile, sort name(CG12_`year') ///
		ytitle(متوسط نرخ مالیات ابرازی شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی ابرازی در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
	graph export CE12_`year'.png, as(png) replace
	
	
	
	cumul etr_ebrazi, gen(etr_ebrazi_cumul)
	line etr_ebrazi_cumul etr_ebrazi if etr_ebrazi < 0.251, sort name(CE0_`year') ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
		title(توزیع تجمعی نرخ مالیات موثر ابرازی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
	graph export CE00_`year'.png, as(png) replace
	
	hist etr_ebrazi2, percent name(CE1_`year') bin(26) ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) ///
		title(توزیع نرخ مالیات موثر ابرازی -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE01_`year'.png, as(png) replace
	
	
	cumul etr_ebrazi [w=int(profit_ebrazi)] , gen(etr_ebrazi_cumul_w)
	line etr_ebrazi_cumul_w etr_ebrazi if etr_ebrazi < 0.251, sort name(CE2_`year') ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
		xtitle(نرخ موثر مالیات ابرازی) title(توزیع تجمعی وزن‌دار نرخ مالیات موثر ابرازی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
	graph export CE02_`year'.png, as(png) replace	
	
	
	hist etr_ebrazi2 [w=int(profit_ebrazi)], percent name(CE3_`year') bin(26) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
		xtitle(نرخ موثر مالیات ابرازی) title(توزیع نرخ مالیات موثر ابرازی بر اساس سود شرکت -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE03_`year'.png, as(png) replace
		
	hist etr_ebrazi2 if percentile == 100, percent name(CE5_`year') bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی صدک شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE05_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if percentile <= 20 & etr_ebrazi < 0.251, percent bin(26) name(CE6_`year') ///
		title(صدک ۱ تا ۲۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE06_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if percentile < 20 & percentile < 90 & etr_ebrazi < 0.251, percent name(CE7_`year') ///
		bin(26) title(صدک ۲۰ تا ۹۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE07_`year'.png, as(png) replace
	
	line zero_rate_percent_ebrazi percentile if actyear == `year', sort name(CE8_`year') ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		title(توزیع شرکت‌های با نرخ موثر ابرازی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
	graph export CE08_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if top1000 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی ۱۰۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE09_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if top500 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی ۵۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE10_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if top200 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی ۲۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE11_`year'.png, as(png) replace
	

	
// ##############
frame change graph_frame_g
graph drop _all

	
	tab actyear
	
	
	line avg_etr_ghati_percentile percentile_g, sort name(CG09_`year') ///
		ytitle(متوسط نرخ مالیات قطعی شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
	graph export CG09_`year'.png, as(png) replace
	
	twoway ///		
		( line zero_rate_percent_ghati percentile_g		, sort ) ///
		( line zero_rate_percent_ghati_s percentile_g	, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG08_`year') 
	graph export CG08_`year'.png, as(png) replace

	
// 	line zero_rate_percent_ghati percentile, sort name(CG8_`year') ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
// 		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
// 	graph export CG08_`year'.png, as(png) replace
	
	twoway ///
		( hist etr_ghati2 	if percentile_g >= 20 & percentile_g <= 90, ///
			percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g >= 20 & percentile_g <= 90, ///
			percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(صدک ۲۰ تا ۹۰ - `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG07_`year'.png, as(png) replace	
	
// 	hist etr_ghati2 if percentile < 20 & percentile < 90 & etr_ebrazi < 0.251, percent name(CG7_`year') ///
// 		bin(26) title(صدک ۲۰ تا ۹۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG07_`year'.png, as(png) replace


	
	twoway ///
		( hist etr_ghati2   if percentile_g <= 99	, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g <= 99	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی صدک ۱ تا ۹۹ - `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG06_`year') 
	graph export CG06_`year'.png, as(png) replace
	
// 	hist etr_ghati2 if percentile <= 20 & etr_ebrazi < 0.251, percent name(CG6_`year') ///
// 		bin(26) title(صدک ۱ تا ۲۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG06_`year'.png, as(png) replace
	
	
	twoway ///
		( hist etr_ghati2   if percentile_g == 100	, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g == 100	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG05_`year'.png, as(png) replace
	
// 	hist etr_ghati2 if percentile == 100, percent name(CG5_`year') bin(26) ///
// 		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ `year') ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG05_`year'.png, as(png) replace
	
	
	
	twoway ///
		( hist etr_ghati2   [fw=int(profit_ebrazi)]		, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 [fw=int(profit_ghati_cal)]	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ `year') ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG03_`year') 
	graph export CG03_`year'.png, as(png) replace
	
	// 	hist etr_ghati2 [w=int(profit_ebrazi)], percent name(CG3_`year') bin(26) ///
	// 		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
	// 		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ `year') color(cranberry) ///
	// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	// 	graph export CG03_`year'.png, as(png) replace	
	
	
	cumul etr_ghati   [w=int(profit_ebrazi)] 	, gen(etr_ghati_cumul_w)
	cumul etr_ghati_s [w=int(profit_ghati_cal)] , gen(etr_ghati_cumul_w_s)
	twoway ///		
		( line etr_ghati_cumul_w etr_ghati if etr_ghati <= 0.25, sort ) ///
		( line etr_ghati_cumul_w_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع تجمعی وزن‌دار نرخ مالیات موثر قطعی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) r(0 1)) name(CG2_`year') 
	graph export CG02_`year'.png, as(png) replace		
	
	twoway ///
		( hist etr_ghati2  , percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع نرخ مالیات موثر قطعی -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG01_`year'.png, as(png) replace
	
	
	cumul etr_ghati, gen(etr_ghati_cumul)
	cumul etr_ghati_s, gen(etr_ghati_cumul_s)
	twoway ///		
		( line etr_ghati_cumul etr_ghati if etr_ghati <= 0.25, sort ) ///
		( line etr_ghati_cumul_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(توزیع تجمعی نرخ مالیات موثر قطعی -‍ `year') ///
		yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG0_`year')
	graph export CG00_`year'.png, as(png) replace		
	
	hist etr_ghati2 if top1000 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۱۰۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG09_`year'.png, as(png) replace
	
	hist etr_ghati2 if top500 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۵۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG10_`year'.png, as(png) replace
	
	hist etr_ghati_s2 if top200 == 1, percent bin(25) ///
		title(توزیع نرخ مالیات موثر قطعی ۲۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG11_`year'.png, as(png) replace


	
frame change default

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
//
// 
//
//
//
// ################################## ########### ####################################
// ################################## Lost Income ####################################


egen sum_lost_income_percentile = sum(lost_income_ebrazi2), by(actyear percentile)
// sort percentile
// line sum_lost_income_percentile percentile if actyear == 1400


// gen tax_exp_to_profit_eb = avg_lost_income_percentile_eb / avg_profit_percentile
egen tax_exp_to_profit_eb = mean(lost_income_ebrazi2 / profit_ebrazi), by(actyear percentile)



local year 1401
graph drop _all

preserve
	keep if actyear == `year'
	
		
	niceloglabels sum_lost_income_percentile if actyear == `year', local(yla) style(1) powers
	line sum_lost_income_percentile percentile if actyear == `year', ///
		yscale(log) yla(`yla', ang(h)) ///
		ytitle(درآمد از دست رفته دولت ابرازی) xtitle(صدک شرکت) ///
		title(درآمد از دست رفته دولت در صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export decile_lost_income_eb_`year'.png, as(png) replace
	
	
	line tax_exp_to_profit_eb percentile if actyear == `year' & percentile > 10, ///
		ytitle(نسبت مخارج مالیاتی به سود شرکت) xtitle(صدک شرکت) ///
		title(متوسط نسبت مخارج مالیاتی به سود شرکت در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export decile_lost_income_to_profit_eb_`year'.png, as(png) replace
	
	
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
	 