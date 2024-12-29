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


// ### ????
replace tax_ghati = maliat_tashkhisi if missing(tax_ghati)

tab actyear

// ############################################## Calculate ETR  ###########################################

gen etr_ebrazi  = tax_ebrazi / profit_ebrazi
gen etr_ghati  = tax_ghati / profit_ebrazi 

gen etr_ebrazi2 = etr_ebrazi
replace etr_ebrazi2 = 0.26001 if etr_ebrazi > 0.25 & !missing(etr_ebrazi)

gen etr_ghati2 = etr_ghati
replace etr_ghati2 = 0.26001 if etr_ghati > 0.25 & !missing(etr_ghati)


gen lost_income_ebrazi = (profit_ebrazi * 0.25 - tax_ebrazi)  / 10 / 1000 / 1000 / 1000 // Billion Toman
gen lost_income_ghati  = (profit_ebrazi * 0.25 - tax_ghati)  / 10 / 1000 / 1000 / 1000 // Billion Toman


gen lost_income_ebrazi2 = 0
	replace lost_income_ebrazi2 = lost_income_ebrazi2 + T26_R04 * 0.25 if !missing(T26_R04)
	replace lost_income_ebrazi2 = lost_income_ebrazi2 + T26_R16 if !missing(T26_R16)
	replace lost_income_ebrazi2 = lost_income_ebrazi2 / 10 / 1000 / 1000 / 1000 // Billion Toman
	replace lost_income_ebrazi2 = . if missing(T26_R04) & missing(T26_R16)


// ####### Deciles

egen deciles_100 = xtile(profit_ebrazi) , by(actyear) nq(100)
// egen deciles_20  = xtile(profit_ebrazi) , by(actyear) nq(20)
// egen deciles_10  = xtile(profit_ebrazi) , by(actyear) nq(10)

egen avg_profit_percentile = mean(profit_ebrazi) if is_not_audited == 0, by(actyear deciles_100)
// line avg_profit_percentile deciles_100 if actyear == 1401 & deciles_100 > 90


// ######################################## ETR in specific year (CDF) #################################

local year 1401
graph drop _all

preserve
	keep if actyear == `year'
// 	drop if is_not_audited == 1
	
	tab actyear if !missing(etr_ebrazi)
	
	cumul etr_ebrazi, gen(etr_ebrazi_cumul)
	sort etr_ebrazi_cumul
	
	line etr_ebrazi_cumul etr_ebrazi if etr_ebrazi < 0.251, name(CE0_`year') ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
		title("توزیع تجمعی نرخ مالیات موثر ابرازی -‍ `year'‍‍") ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE0_`year'.png, as(png) replace

	hist etr_ebrazi2, percent name(CE1_`year') bin(26) ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) ///
		title(توزیع نرخ مالیات موثر ابرازی -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE1_`year'.png, as(png) replace
	
	cumul etr_ebrazi [w=profit_ebrazi] , gen(etr_ebrazi_cumul_w)
	sort etr_ebrazi_cumul_w
	line etr_ebrazi_cumul_w etr_ebrazi if etr_ebrazi < 0.251, name(CE2_`year') ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
		xtitle(نرخ موثر مالیات ابرازی) title(توزیع تجمعی وزن‌دار نرخ مالیات موثر ابرازی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE2_`year'.png, as(png) replace	
	
	hist etr_ebrazi2 [w=profit_ebrazi], percent name(CE3_`year') bin(26) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
		xtitle(نرخ موثر مالیات ابرازی) title(توزیع نرخ مالیات موثر ابرازی بر اساس سود شرکت -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE3_`year'.png, as(png) replace
		
		
	hist deciles_100 if etr_ebrazi > 0.24 & !missing(etr_ebrazi), percent name(CE4_`year') bin(20) ///
		title("سال `year'") ytitle(درصد) xtitle(صدک شرکت‌ها) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	
	hist etr_ebrazi2 if deciles_100 == 100, percent name(CE5_`year') bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی صدک شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE5_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if deciles_100 <= 20 & etr_ebrazi < 0.251, percent bin(26) name(CE6_`year') ///
		title("سال `year'") ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
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
			ytitle(سهم از تعداد شرکت‌ها , size(large)) xtitle(نرخ موثر مالیات قطعی) title(توزیع تجمعی نرخ مالیات موثر قطعی -‍ `year') ///
			yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG0_`year'.png, as(png) replace		
			
	hist etr_ghati2, percent name(CG1_`year') bin(26) ylab(, grid) ///
		xlab(, grid) ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع نرخ مالیات موثر قطعی -‍ `year'‍‍) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG1_`year'.png, as(png) replace

	cumul etr_ghati [w=profit_ebrazi] , gen(etr_ghati_cumul_w)
	sort etr_ghati_cumul_w
	line etr_ghati_cumul_w etr_ghati  if etr_ghati < 0.251, name(CG2_`year') ylab(, grid) xlab(, grid) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع تجمعی وزن‌دار نرخ مالیات موثر قطعی -‍ `year') yscale(r(0 1)) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG2_`year'.png, as(png) replace		
			
			
	hist etr_ghati2 [w=profit_ebrazi], percent name(CG3_`year') bin(26) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ `year') color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG3_`year'.png, as(png) replace
		
	hist deciles_100 if etr_ghati > 0.24, percent name(CG4_`year') bin(50) ///
		title("سال `year'") ytitle(درصد) xtitle(صدک شرکت‌ها) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	
			
	hist etr_ghati2 if deciles_100 == 100, percent name(CG5_`year') bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG5_`year'.png, as(png) replace
	
	hist etr_ghati2 if deciles_100 <= 20 & etr_ebrazi < 0.251, percent name(CG6_`year') ///
		bin(26) title("سال `year'") ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG6_`year'.png, as(png) replace

restore


// ############################### Lost Income ##############################

	
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

local topCorp 50
gsort -share_of_t_profit
graph drop _all

preserve
	drop if missing(profit_ebrazi)
	
	bysort actyear (share_of_t_profit): gen topCorp = (_N - _n < `topCorp')
	keep if topCorp == 1
	
	
	// ### Important choice!
	replace tax_ghati = maliat_tashkhisi if missing(tax_ghati)
	
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
	local year 1400
	hist etr_ebrazi2 if actyear == `year' [w=int(share_of_t_profit * 10000)] , bin(26) percent name(tc1)  ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_ebrazi_w.png, as(png) replace
	
	hist etr_ebrazi2 if actyear == `year', bin(26) percent name(tc1_)  ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_ebrazi.png, as(png) replace
	
	
	hist etr_ghati2 if actyear == `year' [w=int(share_of_t_profit * 10000)], bin(26) percent name(tc2) ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_ghati_w.png, as(png) replace
		
	hist etr_ghati2 if actyear == `year', bin(26) percent name(tc2_) ///
		title(توزیع مالیات پرداختی `topCorp' پرسود در سال `year') ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) color(gray) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export topCorp_`topCorp'_ghati.png, as(png) replace
	
	

	keep actyear ///
		sum_total_share ///
		etr_ebrazi_agr_yearly_topCorp ///
		sum_lost_income_ebrazi_topCorp ///
		etr_ghati_agr_yearly_topCorp ///
		sum_lost_income_ghati_topCorp

	duplicates drop
	export excel "Corp - ETR timeSeries - topCorp_`topCorp'.xlsx", firstrow(varl) replace

restore