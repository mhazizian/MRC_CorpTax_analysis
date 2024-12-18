clear
graph set window fontface "B Nazanin"
graph drop _all

local dir "D:\Data_Output\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\sharif"
use "`dir'\Mohasebe_Maliat.dta", clear


gsort -T26_R01 
egen flag = tag(id actyear)
duplicates drop id actyear flag, force
drop if flag == 0

// merge 1:1 id actyear using "`dir'\Sanim.dta"

// ##### Gen <profit_ebrazi> & <tax_ebrazi>

gen tax_ebrazi = T26_R25
replace tax_ebrazi = tax_ebrazi + T26_R23 if !missing(T26_R23)

gen profit_ebrazi = 0
replace profit_ebrazi = profit_ebrazi + T26_R01 if !missing(T26_R01)
// replace profit_ebrazi = profit_ebrazi + T26_R02 if !missing(T26_R02)
// replace profit_ebrazi = profit_ebrazi + T26_R03 if !missing(T26_R03)
replace profit_ebrazi = . if missing(T26_R01) // & missing(T26_R02) & missing(T26_R03) 


// ##### Calculate ETR

gen etr_ebrazi  = tax_ebrazi / profit_ebrazi
gen etr_ebrazi2 = tax_ebrazi / T26_R14

gen etr_ghati  = maliat_ghatee / profit_ebrazi 
// gen etr_ghati2 = maliyat_ghati / daramad_ghati
// gen etr_ghati3 = maliyat_ghati / daramad_ebrazi


gen lost_income_ebrazi = (profit_ebrazi * 0.25 - tax_ebrazi)  / 10 / 1000 / 1000 / 1000 // Billion Toman
gen lost_income_ghati  = (profit_ebrazi * 0.25 - maliat_ghatee)  / 10 / 1000 / 1000 / 1000 // Billion Toman

// ##########################################################################################################
// ##################### Checking for Odd(!) corporate with maliyat_ghati > maliyat_ebrazi ##################


// tab actyear if daramad_ghati < T26_R14        & !missing(daramad_ghati) & !missing(T26_R14) & !missing(daramad_ebrazi)
// tab actyear if daramad_ghati < daramad_ebrazi & !missing(daramad_ghati) & !missing(T26_R14) & !missing(daramad_ebrazi)
// tab actyear if maliyat_ghati < tax_ebrazi     & !missing(daramad_ghati) & !missing(T26_R14) & !missing(daramad_ebrazi) & !missing(tax_ebrazi)
// tab actyear if maliyat_ghati < tax_ebrazi & abs(maliyat_ghati - maliyat_ebrazi) > 0.01     & !missing(daramad_ghati)  & !missing(tax_ebrazi)


gen odd_corp = (maliat_ghatee < tax_ebrazi & abs(maliat_ghatee - tax_ebrazi) > 0.01 * tax_ebrazi & !missing(maliat_ghatee) & !missing(tax_ebrazi))
gen odd_corp_ex = (odd_corp == 1) & (maliat_ghatee > 0)
gen is_not_audited = (maliat_ghatee == 0) & (odd_corp == 1)

tab actyear odd_corp_ex, row  // in total, 21000 obs. with more weight in 1393 - 1397
tab actyear odd_corp_ex [w=profit_ebrazi] if profit_ebrazi >=0, row // TODO: years 1397, 1396 must be checked. in total, 1 percent of total profit.
hist etr_ebrazi if odd_corp_ex == 1 & etr_ebrazi < 0.5 & etr_ebrazi >= 0, title("ETR dist for odd corporations")




// corporate which has not gotten ghati yet...
tab actyear is_not_audited, row // 0.09% of all records.
tab actyear is_not_audited [w=profit_ebrazi] if profit_ebrazi >= 0, row // 0.07% of total profit of all records.

// #########################################################################################################
// ############################################# Cleaning ##################################################

drop if missing(actyear)

// drop if actyear < 1396

drop if missing(tax_ebrazi) & missing(profit_ebrazi) // TODO: years 1391 to 1394 must be checked.

tab actyear

// inactive corporates:
drop if profit_ebrazi == 0

// corporate with loss:
drop if profit_ebrazi < 0 


// Odd corporations:
tab actyear is_not_audited, row // 0.16% of all records.
tab actyear is_not_audited [w=profit_ebrazi], row // 0.07% of total value of all records.

// drop if is_not_audited
tab actyear if is_not_audited

tab actyear

	
// ################################# dramad ghati / daramad ebrazi  #########################################

// gen inta_work4 = daramad_ghati / daramad_ebrazi
//
// hist inta_work4 if inta_work4 < 5, percent name(h3) ///
// 	title("daramad_ghati / daramad_ebrazi (<5)")
//
// hist inta_work4 if inta_work4 < 50, percent name(h4) bin(20) ///
// 	title("daramad_ghati / daramad_ebrazi (<50)")


// ##########################################################################################################
// ############################# Checking ETR distibution ###################################################


//tab actyear if missing(daramad_ghati) & !missing(maliat_ghatee) & !missing(T26_R01)
tab actyear if missing(T26_R01)

tab actyear if T26_R01 < 0
tab actyear if T26_R14 < 0
tab actyear if daramad_ebrazi < 0
tab actyear if daramad_ghati < 0

tab actyear if profit_ebrazi == 0 & T26_R14 != 0 & !missing(T26_R14)
tab actyear if profit_ebrazi < 0  & T26_R14 > 0  & !missing(T26_R14) // how is it possible?!!?!?!!!??

tab actyear if !missing(etr_ebrazi)
tab actyear if !missing(etr_ghati)
tab actyear if !missing(etr_ghati2)

// graph drop _all

cumul etr_ebrazi, gen(etr_ebrazi_cumul1)
sort etr_ebrazi_cumul1
line etr_ebrazi_cumul1 etr_ebrazi if etr_ebrazi < 0.251 & etr_ebrazi >= 0, name(c1) ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
	title("tax_ebrazi / profit_ebrazi")

	
cumul etr_ebrazi2, gen(etr_ebrazi_cumul2)
sort etr_ebrazi_cumul2
line etr_ebrazi_cumul2 etr_ebrazi2 if etr_ebrazi2 < 0.251 & etr_ebrazi2 >= 0, name(c2) ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
	title("tax_ebrazi / T26_R14")


cumul etr_ghati, gen(etr_ghati_cumul1)
sort etr_ghati_cumul1
line etr_ghati_cumul1 etr_ghati if etr_ghati < 0.251 & etr_ghati >= 0, name(c3) ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
	title("maliyat_ghati / profit_ebrazi")

	
// #################################################################################################
// ######################################### ETR stats in specific year ############################


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


tabdisp actyear, cellvar(etr_ebrazi_agr_yearly sum_lost_income_ebrazi)
tabdisp actyear, cellvar(lp_sum_lost_income_ebrazi lp_percent_etr_ebrazi lp_percent_etr_ebrazi_w)


// ################# GHATI ##################
preserve 
	drop if missing(maliyat_ghati)
	drop if is_not_audited
	drop if maliyat_ghati < 0
	
	
	egen sum_tax_ghati_yearly 	  = sum(maliyat_ghati)   , by(actyear)
	gen etr_ghati_agr_yearly = sum_tax_ghati_yearly / sum_profit_ebrazi_yearly

	egen sum_lost_income_ghati = sum(lost_income_ghati), by(actyear)

	
	local percent 0.01
	display "##################  corporate with etr_ghati < `percent' ########"
	
	egen lp_sum_lost_income_ghati = sum( lost_income_ghati * (etr_ghati < `percent')), by(actyear)
	gen lp_is_etr_ghati = (etr_ghati < `percent')
	replace lp_is_etr_ghati = . if missing(etr_ghati)
	egen lp_percent_etr_ghati = mean(lp_is_etr_ghati), by(actyear)
	egen lp_percent_etr_ghati_w = wtmean(lp_is_etr_ghati), by(actyear) weight(profit_ebrazi)
	
	
	
	tabdisp actyear, cellvar(etr_ghati_agr_yearly sum_lost_income_ghati)
	tabdisp actyear, cellvar(lp_sum_lost_income_ghati lp_percent_etr_ghati lp_percent_etr_ghati_w)
restore	


// ################# TopCorp ##################

local topCorp 20
gsort -share_of_t_profit
graph drop _all
preserve
	drop if missing(profit_ebrazi)
	
	bysort actyear (share_of_t_profit): gen topCorp = (_N - _n < `topCorp')
	keep if topCorp == 1
	
	drop if maliyat_ghati < 0
	drop if missing(share_of_t_profit)
	drop if missing(maliyat_ghati)
	drop if is_not_audited
	
	egen sum_total_share = sum(share_of_t_profit), by(actyear)
	
	egen sum_tax_ebrazi_yearly_topCorp 	  = sum(tax_ebrazi), by(actyear)
	egen sum_profit_ebrazi_yearly_topCorp = sum(profit_ebrazi), by(actyear)
	gen etr_ebrazi_agr_yearly_topCorp     = sum_tax_ebrazi_yearly_topCorp / sum_profit_ebrazi_yearly_topCorp
	
	egen sum_lost_income_ebrazi_topCorp = sum(lost_income_ebrazi), by(actyear)
	
	//hist etr_ebrazi [w=int(share_of_t_profit * 10000)], bin(10) percent name(tc1)
	// Result: ebrazi
	tabdisp actyear, cellvar(sum_total_share etr_ebrazi_agr_yearly_topCorp sum_lost_income_ebrazi_topCorp)
	
	
	
	egen sum_tax_ghati_yearly_topCorp = sum(maliyat_ghati)   , by(actyear)
	// egen sum_profit_ebrazi_yearly_topC = sum(profit_ebrazi), by(actyear)
	gen etr_ghati_agr_yearly_topCorp  = sum_tax_ghati_yearly_topCorp / sum_profit_ebrazi_yearly_topCorp

	egen sum_lost_income_ghati_topCorp = sum(lost_income_ghati), by(actyear)
	
	tabdisp actyear, cellvar(sum_total_share etr_ghati_agr_yearly_topCorp sum_lost_income_ghati_topCorp)
	//hist etr_ghati [w=int(share_of_t_profit * 10000)], bin(10) percent name(tc2)
	
restore
	
	
	
// #################################################################################################
// ######################################## ETR in specific year (CDF) #############################

local year 1398
graph drop _all

preserve
	keep if actyear == `year'
	
	// for cases where profit_ebrazi != t26_R01
	// drop if profit_ebrazi <= 0
	// drop if tax_ebrazi < 0
	
	// drop corporate with negetive tax!
	//drop if tax_ebrazi < 0 
	
	// drop outlier!!!
	// drop if etr_ebrazi > 10 & !missing(etr_ebrazi) 
	
	tab actyear if !missing(etr_ebrazi)
	
	cumul etr_ebrazi, gen(etr_ebrazi_cumul)
	sort etr_ebrazi_cumul
	line etr_ebrazi_cumul etr_ebrazi if etr_ebrazi < 0.251, name(g1) ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) title("سال `year'")

	hist etr_ebrazi if etr_ebrazi < 0.251, percent name(g1_1) bin(20) ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) title(سال `year')

	
	cumul etr_ebrazi [w=profit_ebrazi] , gen(etr_ebrazi_cumul_w)
	sort etr_ebrazi_cumul_w
	line etr_ebrazi_cumul_w etr_ebrazi if etr_ebrazi < 0.251, name(g2) ylab(, grid) xlab(, grid) ///
		ytitle(سهم از سود خالص شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) title("سال `year'")
		
	hist etr_ebrazi [w=profit_ebrazi] if etr_ebrazi < 0.251, percent name(g2_1) bin(20) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) title(سال `year')

restore

preserve

	keep if actyear == `year'
	
	
	drop if is_not_audited == 1
	drop if missing(maliat_ghatee)
	
	tab actyear if !missing(etr_ghati)
	
	
	cumul etr_ghati, gen(etr_ghati_cumul)
	sort etr_ghati_cumul
	// line etr_ghati_cumul_w etr_ebrazi, ylab(, grid) ytitle("") xlab(, grid)
	line etr_ghati_cumul etr_ghati if etr_ghati < 0.251, name(g3) ylab(, grid) xlab(, grid) ///
			ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title("سال `year'") yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1)
			
	hist etr_ghati if etr_ghati < 0.251, percent name(g3_1) ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(سال `year')
	

	cumul etr_ghati [w=profit_ebrazi] , gen(etr_ghati_cumul_w)
	sort etr_ghati_cumul_w
	line etr_ghati_cumul_w etr_ghati  if etr_ghati < 0.251, name(g4) ylab(, grid) xlab(, grid) ///
			ytitle(سهم از سود خالص شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title("سال `year'") yscale(r(0 1))
			
	hist etr_ghati [w=profit_ebrazi] if etr_ghati < 0.251, percent name(g4_1) bin(20) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(سال `year')
		
	
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
