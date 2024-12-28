clear
graph set window fontface "B Nazanin"
// ssc install egenmore
// ssc inst _gwtmean, replace

graph drop _all

local dir "D:\Data_Output\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
use "`dir'\Mohasebe_Maliat.dta", clear

merge 1:1 trace_id actyear using "`dir'\Legal_Person_Information.dta"
drop if missing(actyear)
drop _merge


gsort -T26_R01 
egen flag = tag(id actyear)
duplicates drop id actyear flag, force
drop if flag == 0


rename maliat_ghatee tax_ghati

// ##### Gen <profit_ebrazi> & <tax_ebrazi>

gen tax_ebrazi = T26_R25
replace tax_ebrazi = tax_ebrazi + T26_R23 if !missing(T26_R23)

gen profit_ebrazi = 0
replace profit_ebrazi = profit_ebrazi + T26_R01 if !missing(T26_R01)
// replace profit_ebrazi = profit_ebrazi + T26_R02 if !missing(T26_R02)
// replace profit_ebrazi = profit_ebrazi + T26_R03 if !missing(T26_R03)
replace profit_ebrazi = . if missing(T26_R01) & missing(T26_R02) & missing(T26_R03) 


// ########################### Checking for corporattion with tax_ghati > maliyat_ebrazi ##################

gen odd_corp = (tax_ghati < tax_ebrazi & abs(tax_ghati - tax_ebrazi) > 0.01 * tax_ebrazi & !missing(tax_ghati) & !missing(tax_ebrazi))

gen odd_corp_ex 	= (tax_ghati > 0) & (odd_corp == 1) 
gen is_not_audited 	= (tax_ghati == 0) & (odd_corp == 1)

// tab actyear odd_corp_ex, row 
// tab actyear odd_corp_ex [w=profit_ebrazi] if profit_ebrazi >=0, row  

// corporate which has not gotten ghati yet...
tab actyear is_not_audited, row // 0.09% of all records.
tab actyear is_not_audited [w=profit_ebrazi] if profit_ebrazi >= 0, row // 0.07% of total profit of all records.

// ############################################# Cleaning ##################################################

drop if missing(actyear)

drop if missing(tax_ebrazi)
drop if missing(profit_ebrazi)
// drop if missing(tax_ghati)

// inactive corporates:
drop if profit_ebrazi == 0

// corporate with loss:
drop if profit_ebrazi < 0 

// tab actyear if tax_ebrazi < 0
replace tax_ebrazi = 0 if tax_ebrazi < 0
drop if tax_ghati < 0

// tab actyear is_not_audited, row 					 // 0.16% of all records.
// tab actyear is_not_audited [w=profit_ebrazi], row // 0.07% of total value of all records.

replace is_not_audited = 1 if missing(tax_ghati)
// drop if is_not_audited == 1

tab actyear

// ############################################## Calculate ETR  ###########################################

gen etr_ebrazi  = tax_ebrazi / profit_ebrazi
gen etr_ghati  = tax_ghati / profit_ebrazi 

gen etr_ebrazi2 = etr_ebrazi
replace etr_ebrazi2 = 0.26 if etr_ebrazi > 0.25 & !missing(etr_ebrazi)

gen etr_ghati2 = etr_ghati
replace etr_ghati2 = 0.26 if etr_ghati > 0.25 & !missing(etr_ghati)


gen lost_income_ebrazi = (profit_ebrazi * 0.25 - tax_ebrazi)  / 10 / 1000 / 1000 / 1000 // Billion Toman
gen lost_income_ghati  = (profit_ebrazi * 0.25 - tax_ghati)  / 10 / 1000 / 1000 / 1000 // Billion Toman


// ####### Deciles

egen deciles_100 = xtile(profit_ebrazi) , by(actyear) nq(100)
egen deciles_20  = xtile(profit_ebrazi) , by(actyear) nq(20)
egen deciles_10  = xtile(profit_ebrazi) , by(actyear) nq(10)

egen avg_profit_percentile = mean(profit_ebrazi) if is_not_audited == 0, by(actyear deciles_100)
// line avg_profit_percentile deciles_100 if actyear == 1401 & deciles_100 > 90


// ######################################## ETR in specific year (CDF) #################################

local year 1400
graph drop _all

preserve
	keep if actyear == `year'
// 	drop if is_not_audited == 1
	
	tab actyear if !missing(etr_ebrazi)
	
	cumul etr_ebrazi, gen(etr_ebrazi_cumul)
	sort etr_ebrazi_cumul
	
	line etr_ebrazi_cumul etr_ebrazi if etr_ebrazi < 0.251, name(CE0_`year') ylab(, grid) xlab(, grid) ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) title("سال `year'")
	graph export CE0_`year'.png, as(png) replace

	hist etr_ebrazi if etr_ebrazi < 0.251, percent name(CE1_`year') bin(25) ylab(, grid) xlab(, grid) ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) title(سال `year')
	graph export CE1_`year'.png, as(png) replace
	
	cumul etr_ebrazi [w=profit_ebrazi] , gen(etr_ebrazi_cumul_w)
	sort etr_ebrazi_cumul_w
	line etr_ebrazi_cumul_w etr_ebrazi if etr_ebrazi < 0.251, name(CE2_`year') ylab(, grid) xlab(, grid) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) title("سال `year'")
	graph export CE2_`year'.png, as(png) replace	
	
	hist etr_ebrazi [w=profit_ebrazi] if etr_ebrazi < 0.251, percent name(CE3_`year') bin(25) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) title(سال `year')
	graph export CE3_`year'.png, as(png) replace
		
		
	hist deciles_100 if etr_ebrazi > 0.24 & !missing(etr_ebrazi), percent name(CE4_`year') bin(20) title("سال `year'") ytitle(درصد) xtitle(صدک شرکت‌ها)
	
	hist etr_ebrazi2 if deciles_100 == 100, percent name(CE5_`year') bin(26) title("سال `year'") ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی)
	graph export CE5_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if deciles_100 <= 20 & etr_ebrazi < 0.251, percent name(CE6_`year') bin(25) title("سال `year'") ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی)
	graph export CE6_`year'.png, as(png) replace
	
restore

preserve
	keep if actyear == `year'
	drop if is_not_audited == 1
	
	tab actyear if !missing(etr_ghati)
	
	
	cumul etr_ghati, gen(etr_ghati_cumul)
	sort etr_ghati_cumul
	// line etr_ghati_cumul_w etr_ebrazi, ylab(, grid) ytitle("") xlab(, grid)
	line etr_ghati_cumul etr_ghati if etr_ghati < 0.251, name(CG0_`year') ylab(, grid) xlab(, grid) ///
			ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title("سال `year'") yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1)
	graph export CG0_`year'.png, as(png) replace		
			
	hist etr_ghati if etr_ghati < 0.251, percent name(CG1_`year') bin(25) ylab(, grid) xlab(, grid) ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) title(سال `year')
	graph export CG1_`year'.png, as(png) replace

	cumul etr_ghati [w=profit_ebrazi] , gen(etr_ghati_cumul_w)
	sort etr_ghati_cumul_w
	line etr_ghati_cumul_w etr_ghati  if etr_ghati < 0.251, name(CG2_`year') ylab(, grid) xlab(, grid) ///
			ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title("سال `year'") yscale(r(0 1))
	graph export CG2_`year'.png, as(png) replace		
			
			
	hist etr_ghati [w=profit_ebrazi] if etr_ghati < 0.251, percent name(CG3_`year') bin(25) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(سال `year')
	graph export CG3_`year'.png, as(png) replace
		
	hist deciles_100 if etr_ghati > 0.24, percent name(CG4_`year') bin(50) title("سال `year'") ytitle(درصد) xtitle(صدک شرکت‌ها)
	
			
	hist etr_ghati2 if deciles_100 == 100, percent name(CG5_`year') bin(26) title("سال `year'") ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی)
	graph export CG5_`year'.png, as(png) replace
	
	hist etr_ghati2 if deciles_100 <= 20 & etr_ebrazi < 0.251, percent name(CG6_`year') bin(25) title("سال `year'") ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی)
	graph export CG6_`year'.png, as(png) replace

restore

	
// ################################# Sector Analisys ####################################

replace T00_ActivityTypeName = -1 if missing(T00_ActivityTypeName)

egen t_profit_ebrazi_by_activity = sum(profit_ebrazi)	, by(actyear T00_ActivityTypeName)
egen t_tax_ebrazi_by_activity = sum(tax_ebrazi)			, by(actyear T00_ActivityTypeName)
egen t_tax_ghati_by_activity = sum(tax_ghati)			, by(actyear T00_ActivityTypeName)

gen etr_ebrazi_by_activity = t_tax_ebrazi_by_activity / t_profit_ebrazi_by_activity
gen etr_ghati_by_activity  = t_tax_ghati_by_activity  / t_profit_ebrazi_by_activity


egen sum_lost_income_ebrazi_by_act = sum(lost_income_ebrazi), by(actyear T00_ActivityTypeName)
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
	keep actyear T00_ActivityTypeName T00_ActivityType ///
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
	 
// ##########################################################################################
// ################################## ETR stats --- Time Series  ############################


egen total_profit_ebrazi = sum(profit_ebrazi), by(actyear)
gen  share_of_t_profit   = profit_ebrazi / total_profit_ebrazi
gsort -share_of_t_profit

egen sum_tax_ebrazi_yearly 	  = sum(tax_ebrazi)   , by(actyear)
egen sum_profit_ebrazi_yearly = sum(profit_ebrazi), by(actyear)
gen etr_ebrazi_agr_yearly = sum_tax_ebrazi_yearly / sum_profit_ebrazi_yearly

egen sum_lost_income_ebrazi = sum(lost_income_ebrazi), by(actyear)


local percent 0.01 
display "##################  corporate with etr_ebrazi < `percent' ########"

egen lp_sum_lost_income_ebrazi = sum( lost_income_ebrazi * (etr_ebrazi < `percent')), by(actyear)
gen lp_is_etr_ebrazi = (etr_ebrazi < `percent')
replace lp_is_etr_ebrazi = . if missing(etr_ebrazi)
egen lp_percent_etr_ebrazi = mean(lp_is_etr_ebrazi), by(actyear)
egen lp_percent_etr_ebrazi_w = wtmean(lp_is_etr_ebrazi), by(actyear) weight(profit_ebrazi)

//
// tabdisp actyear, cellvar(etr_ebrazi_agr_yearly sum_lost_income_ebrazi)
// tabdisp actyear, cellvar(lp_sum_lost_income_ebrazi lp_percent_etr_ebrazi lp_percent_etr_ebrazi_w)

preserve

	keep actyear ///
		etr_ebrazi_agr_yearly ///
		sum_lost_income_ebrazi ///
		lp_sum_lost_income_ebrazi ///
		lp_percent_etr_ebrazi ///
		lp_percent_etr_ebrazi_w
	duplicates drop
	export excel "Corp - ETR timeSeries - topCorp - Ebrazi.xlsx", firstrow(varl) replace

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
	gen lp_is_etr_ghati = (etr_ghati < `percent')
	replace lp_is_etr_ghati = . if missing(etr_ghati)
	egen lp_percent_etr_ghati = mean(lp_is_etr_ghati), by(actyear)
	egen lp_percent_etr_ghati_w = wtmean(lp_is_etr_ghati), by(actyear) weight(profit_ebrazi)
	
	
	
// 	tabdisp actyear, cellvar(etr_ghati_agr_yearly sum_lost_income_ghati)
// 	tabdisp actyear, cellvar(lp_sum_lost_income_ghati lp_percent_etr_ghati lp_percent_etr_ghati_w)
	
	
	keep actyear ///
		etr_ghati_agr_yearly ///
		sum_lost_income_ghati ///
		lp_sum_lost_income_ghati ///
		lp_percent_etr_ghati ///
		lp_percent_etr_ghati_w
	duplicates drop
	export excel "Corp - ETR timeSeries - topCorp - Ghati.xlsx", firstrow(varl) replace

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
	
	egen sum_total_share = sum(share_of_t_profit), by(actyear)
	
	egen sum_tax_ebrazi_yearly_topCorp 	  = sum(tax_ebrazi), by(actyear)
	egen sum_profit_ebrazi_yearly_topCorp = sum(profit_ebrazi), by(actyear)
	gen etr_ebrazi_agr_yearly_topCorp     = sum_tax_ebrazi_yearly_topCorp / sum_profit_ebrazi_yearly_topCorp
	
	egen sum_lost_income_ebrazi_topCorp = sum(lost_income_ebrazi), by(actyear)
	
	//hist etr_ebrazi [w=int(share_of_t_profit * 10000)], bin(10) percent name(tc1)
	// Result: ebrazi
	tabdisp actyear, cellvar(sum_total_share etr_ebrazi_agr_yearly_topCorp sum_lost_income_ebrazi_topCorp)
	
	
	
	egen sum_tax_ghati_yearly_topCorp = sum(tax_ghati)   , by(actyear)
	// egen sum_profit_ebrazi_yearly_topC = sum(profit_ebrazi), by(actyear)
	gen etr_ghati_agr_yearly_topCorp  = sum_tax_ghati_yearly_topCorp / sum_profit_ebrazi_yearly_topCorp

	egen sum_lost_income_ghati_topCorp = sum(lost_income_ghati), by(actyear)
	
	tabdisp actyear, cellvar(sum_total_share etr_ghati_agr_yearly_topCorp sum_lost_income_ghati_topCorp)
	//hist etr_ghati [w=int(share_of_t_profit * 10000)], bin(10) percent name(tc2)
	
restore
	
	
// #########################################################################################################
// ############################## Checking what is daramad_ebrazi ##########################################

gen inta_work1 = daramad_ebrazi / T26_R01
gen inta_work2 = daramad_ebrazi / T26_R12
gen inta_work3 = daramad_ebrazi / T26_R14

gen is_inta_work3_1 = .
replace is_inta_work3_1 = 0 if !missing(inta_work3)
replace is_inta_work3_1 = 1 if inta_work3 == 1
replace is_inta_work3_1 = 1 if inta_work3 <= 1.01 & inta_work3 >= .99

tab actyear is_inta_work3_1, row

hist inta_work1 if daramad_ebrazi > 0 & T26_R01 > 0 & inta_work1 < 20 & !missing(inta_work3) & !missing(inta_work1), percent name(h1) ///
	title("daramad_ebrazi / T26_R01")
hist inta_work3 if daramad_ebrazi > 0 & T26_R14 > 0 & inta_work3 < 20 & !missing(inta_work3) & !missing(inta_work1), percent name(h2) ///
	title("daramad_ebrazi / T26_R14")
// ############ Result: daramad_ebrazi =~ T26_R14
	

// #####################################################################################
// ################################# BIG taxPayers #####################################

// clear
// use "`dir'\Sanim.dta"
// // drop _merge
// merge 1:1 id actyear using "`dir'\Legal_Person_Information.dta"
