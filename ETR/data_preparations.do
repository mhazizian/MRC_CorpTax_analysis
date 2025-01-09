clear
frame reset
graph set window fontface "B Nazanin"
graph drop _all


use "$dir\Mohasebe_Maliat.dta", clear
drop if missing(actyear)


// @@@ Sharif Version.
if $is_sharif_version == 1 {
	gsort -T26_R01 
	egen flag = tag(id actyear)
	duplicates drop id actyear flag, force
	drop if flag == 0
	drop flag
	merge 1:1 id actyear using "$dir\Sanim.dta"
	rename maliyat_ghati tax_ghati
	rename maliyat_tashkhis tax_tashkhisi
	egen trace_id = concat(actyear id), punct(_)    
}


// @@@ MRC Version
if $is_sharif_version == 0 {
	merge 1:1 trace_id actyear using "$dir\Legal_Person_Information.dta"
	rename maliat_ghatee tax_ghati
	rename maliat_tashkhisi tax_tashkhisi
}


drop _merge


// ##### Gen <profit_ebrazi> & <tax_ebrazi>
gen tax_ebrazi = T26_R25
replace tax_ebrazi = tax_ebrazi + T26_R23 if !missing(T26_R23)

gen profit_ebrazi = 0
replace profit_ebrazi = profit_ebrazi + T26_R01 if !missing(T26_R01)
// replace profit_ebrazi = profit_ebrazi + T26_R02 if !missing(T26_R02)
// replace profit_ebrazi = profit_ebrazi + T26_R03 if !missing(T26_R03)
replace profit_ebrazi = . if missing(T26_R01) //& missing(T26_R02) & missing(T26_R03) 

// ############################ Cleaning phase 1 ################################

replace tax_tashkhisi = 0 if tax_tashkhisi  < 10000 & tax_tashkhisi > 0
replace tax_ghati	  = 0 if tax_ghati 		< 10000 & tax_ghati > 0
replace profit_ebrazi = 0 if profit_ebrazi  < 10000 & profit_ebrazi > 0


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


// ############################## Merge with Moafiat #########################

frame create Moafiat_frame
frame change Moafiat_frame

// local dir "D:\Data_Output\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\sharif"


use "$dir\Moafiat.dta", clear

drop if missing(actyear)
local maliat_maghtoo_code 35

// @@@ Sharif Version.
if $is_sharif_version == 1 {
	rename benefit Exempted_Profit
	rename new_code exemption_id
	local maliat_maghtoo_code 37
	egen trace_id = concat(actyear id), punct(_)
}


// maliat maghtoo:

egen agr_maghtou = sum(Exempted_Profit * (exemption_id == `maliat_maghtoo_code')), by(trace_id)
drop if exemption_id == `maliat_maghtoo_code'

egen agr_moafiat = sum(Exempted_Profit), by(trace_id)
keep trace_id agr_moafiat agr_maghtou
duplicates drop

frame change default
frlink 1:1 trace_id, frame(Moafiat_frame)

frget agr_moafiat, from(Moafiat_frame)
frget agr_maghtou, from(Moafiat_frame)
frame drop Moafiat_frame
drop Moafiat_frame


// ################ Bakhshoodegi ###########
frame create Bakhshodegi_frame
frame change Bakhshodegi_frame

use "$dir\Bakhshhodegi.dta", clear

// @@@ Sharif Version.
if $is_sharif_version == 1 {
	rename bakhshoodegiqty Rebate_Amount
	egen trace_id = concat(actyear id), punct(_)
}


egen agr_bakhshoudegi = sum(Rebate_Amount), by(trace_id)
keep trace_id agr_bakhshoudegi
duplicates drop

frame change default
frlink 1:1 trace_id, frame(Bakhshodegi_frame)
frget agr_bakhshoudegi, from(Bakhshodegi_frame)
frame drop Bakhshodegi_frame
drop Bakhshodegi_frame


// Bug fix on 1399:
// replace agr_maghtou = 0		  if actyear == 1399 & missing(agr_maghtou) 
// replace agr_moafiat = T26_R04 if actyear == 1399 & T26_R04 > agr_moafiat + agr_maghtou ///
// 	& !missing(T26_R04)
//	
// replace agr_maghtou = 0 	  if actyear == 1399 & T26_R04 > agr_moafiat + agr_maghtou ///
// 	& !missing(T26_R04)


// ############################## profit Ghati ! #################################

gen profit_ghati_cal = .
replace profit_ghati_cal = tax_ghati if !missing(tax_ghati)

// replace profit_ghati_cal = profit_ghati_cal + T26_R24 if !missing(T26_R24) // Jayeze M.190 -- NO DATA
// replace profit_ghati_cal = profit_ghati_cal + T26_R22 if !missing(T26_R22) // Jayeze Khosh hesabi -- NO DATA

replace profit_ghati_cal = profit_ghati_cal - T26_R21 if !missing(T26_R21) // maliyat daramad etefaghi
// replace profit_ghati_cal = profit_ghati_cal + T26_R18 if !missing(T26_R18) // Tabsare 2 M.169 -- NO DATA
// replace profit_ghati_cal = profit_ghati_cal + T26_R17 if !missing(T26_R17) // Foreign Tax -- NO DATA

********  Bakhshoodegi *******
// replace profit_ghati_cal = profit_ghati_cal + agr_bakhshoudegi if !missing(agr_bakhshoudegi) // Bakhshodegi
replace profit_ghati_cal = profit_ghati_cal + T26_R16 if !missing(T26_R16) // Bakhshodegi

replace profit_ghati_cal = profit_ghati_cal * 4

replace profit_ghati_cal = profit_ghati_cal + T26_R13 if !missing(T26_R13) 			// Otagh Bazargani
replace profit_ghati_cal = profit_ghati_cal + T26_R11 if !missing(T26_R11)			// Khesarat Made 165
replace profit_ghati_cal = profit_ghati_cal + T26_R10 if !missing(T26_R10) 			// Estehlak Anbashte
replace profit_ghati_cal = profit_ghati_cal + T26_R06 if !missing(T26_R06)			// Komak Mali Pardakhti


********  Moafiat *******
replace profit_ghati_cal = profit_ghati_cal + T26_R04 if !missing(T26_R04) 		// Moafiat
// replace profit_ghati_cal = profit_ghati_cal + agr_moafiat if !missing(agr_moafiat) 	// Moafiat
// replace profit_ghati_cal = profit_ghati_cal + agr_moafiat if !missing(agr_maghtou) 	// Maliat Maghtou


replace profit_ghati_cal = profit_ghati_cal + T26_004 if !missing(T26_004) 			// Maliat Maghtou
replace profit_ghati_cal = profit_ghati_cal - T26_R02 if !missing(T26_R02) 			// going for Sood Vije
replace profit_ghati_cal = profit_ghati_cal - T26_R03 if !missing(T26_R03) 			// going for Sood Vije
replace profit_ghati_cal = profit_ghati_cal - T26_R08 if !missing(T26_R08) 			// Zian Gheir Moaf

replace profit_ghati_cal = . if missing(tax_ghati)
replace profit_ghati_cal = 0 if profit_ghati_cal < 0

// TODO: check this decision.
replace profit_ghati_cal = profit_ebrazi if profit_ghati_cal < profit_ebrazi ///
	& !missing(profit_ebrazi)



// ############################# Cleaning ####################################

drop if missing(actyear)
drop if missing(tax_ebrazi) & missing(tax_ghati)

drop if missing(profit_ebrazi) & missing(profit_ghati_cal)

// corporate with loss:
drop if profit_ebrazi < 0 & profit_ghati_cal < 0


// inactive corporates:
replace profit_ebrazi 	 = 0 if profit_ebrazi 	 < 10000 & profit_ebrazi > 0 
replace profit_ghati_cal = 0 if profit_ghati_cal < 10000 & profit_ghati_cal > 0 


// tab actyear if tax_ebrazi < 0
replace tax_ebrazi = 0 if tax_ebrazi < 0
drop if tax_ghati < 0

replace profit_ebrazi = .    if profit_ebrazi <= 0
replace profit_ghati_cal = . if profit_ghati_cal <= 0
// drop if profit_ebrazi == 0 & profit_ghati_cal == 0


// tab actyear is_not_audited, row 					 // 0.16% of all records.
// tab actyear is_not_audited [w=profit_ebrazi], row // 0.07% of total value of all records.

// drop if is_not_audited == 1


tab actyear


// ############################## Calculation #################################

gen etr_ebrazi  = tax_ebrazi / profit_ebrazi
gen etr_ghati  = tax_ghati / profit_ebrazi 
gen etr_ghati_s = tax_ghati / profit_ghati_cal

replace etr_ebrazi = .	 if etr_ebrazi < 0
replace etr_ghati = . 	 if etr_ghati < 0
replace etr_ghati_s = .	 if etr_ghati_s < 0


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
	replace lost_income_ebrazi2 = lost_income_ebrazi2 + T26_R04		 * 0.25 if !missing(T26_R04)
	replace lost_income_ebrazi2 = lost_income_ebrazi2 - agr_maghtou	 * 0.25 if !missing(agr_maghtou)
// 	replace lost_income_ebrazi2 = lost_income_ebrazi2 + agr_moafiat * 0.25 if !missing(agr_moafiat)

	replace lost_income_ebrazi2 = lost_income_ebrazi2 + T26_R16 if !missing(T26_R16)
// 	replace lost_income_ebrazi2 = lost_income_ebrazi2 + agr_bakhshoudegi if !missing(agr_bakhshoudegi)

	replace lost_income_ebrazi2 = 0 if lost_income_ebrazi2 < 0
	replace lost_income_ebrazi2 = . if missing(T26_R04) & missing(T26_R16)
	replace lost_income_ebrazi2 = 0 if profit_ghati_cal < 1000
// 	replace lost_income_ebrazi2 = . if missing(agr_moafiat) & missing(agr_bakhshoudegi)

	
// TODO: check this #outlier fix.
replace etr_ghati_s = . if etr_ghati_s > 10 & !missing(etr_ghati_s)
replace etr_ebrazi  = . if etr_ebrazi  > 10 & !missing(etr_ebrazi)

// replace etr_ghati_s = 10 if etr_ghati_s > 10 & !missing(etr_ghati_s)

// ################################ Duplicates Drop ####################

// gsort -profit_ebrazi
gsort -profit_ghati_cal
egen flag = tag(id actyear)
duplicates drop id actyear flag, force
drop if flag == 0
drop flag


// ############################### Percentile ##############################

// egen percentile = xtile(profit_ebrazi) 		, by(actyear) nq(100)
// egen percentile_g = xtile(profit_ghati_cal) , by(actyear) nq(100)
// astile percentile 	= profit_ebrazi		if profit_ebrazi > 0	, nq(100) by(actyear)
astile percentile_g = profit_ghati_cal	if profit_ghati_cal > 0 , nq(100) by(actyear)
astile p100_decile = profit_ghati_cal	if percentile_g == 100  , nq(10) by(actyear)


replace profit_ghati_cal = -1 if missing(profit_ghati_cal)	
gsort -profit_ghati_cal
bysort actyear (profit_ghati_cal): gen top1000 = (_N - _n < 1000)
bysort actyear (profit_ghati_cal): gen top500 = (_N - _n < 500)
bysort actyear (profit_ghati_cal): gen top200 = (_N - _n < 200)
replace profit_ghati_cal = . if profit_ghati_cal == -1	



egen avg_profit_percentile   = mean(profit_ebrazi)		, by(actyear percentile_g)
egen avg_profit_g_percentile = mean(profit_ghati_cal)	, by(actyear percentile_g)

egen sum_profit_percentile   = sum(profit_ebrazi), by(actyear percentile_g)
egen sum_profit_g_percentile = sum(profit_ghati_cal), by(actyear percentile_g)

egen sum_profit_g_prct_zero_rate 		= sum(profit_ghati_cal * (etr_ghati_s <= 0.01)) , by(actyear percentile_g)
egen sum_profit_g_prct_low_rate 		= sum(profit_ghati_cal * (etr_ghati_s <= 0.05)) , by(actyear percentile_g)
egen sum_profit_g_prct_middle_rate 		= sum(profit_ghati_cal * (etr_ghati_s <= 0.2)) , by(actyear percentile_g)
egen sum_profit_g_prct_high_rate 		= sum(profit_ghati_cal * (etr_ghati_s <= 0.25)) , by(actyear percentile_g)


egen zero_rate_percent_ebrazi   = mean(etr_ebrazi <= 0.01)	, by(actyear percentile_g)
egen zero_rate_percent_ghati    = mean(etr_ghati <= 0.01)   , by(actyear percentile_g)
egen zero_rate_percent_ghati_s  = mean(etr_ghati_s <= 0.01) , by(actyear percentile_g)
egen zero_rate_percent_ghati_sw = sum(profit_ghati_cal * (etr_ghati_s <= 0.01) / sum_profit_g_percentile) ///
	, by(actyear percentile_g)
egen zero_rate_percent_ghati_s_p100  = mean(etr_ghati_s <= 0.01) , by(actyear p100_decile)
	
label variable zero_rate_percent_ghati_s "سهم شرکت‌های با نرخ موثر قطعی ۰ تا ۱ درصد از کل سود در سال و صدک"
label variable zero_rate_percent_ebrazi "سهم شرکت‌های با نرخ موثر ابرازی ۰ تا ۱ درصد از کل سود در سال و صدک"


	
egen low_rate_percent_ebrazi   = mean(etr_ebrazi <= 0.05)	, by(actyear percentile_g)
egen low_rate_percent_ghati    = mean(etr_ghati <= 0.05)    , by(actyear percentile_g)
egen low_rate_percent_ghati_s  = mean(etr_ghati_s <= 0.05)  , by(actyear percentile_g)
egen low_rate_percent_ghati_sw  = sum(profit_ghati_cal * (etr_ghati_s <= 0.05) / sum_profit_g_percentile) ///
	, by(actyear percentile_g)
egen low_rate_percent_ghati_s_p100  = mean(etr_ghati_s <= 0.05)  , by(actyear p100_decile)

egen middle_rate_percent_ebrazi   = mean(etr_ebrazi <= 0.2)	, by(actyear percentile_g)
egen middle_rate_percent_ghati    = mean(etr_ghati <= 0.2)    , by(actyear percentile_g)
egen middle_rate_percent_ghati_s  = mean(etr_ghati_s <= 0.2)  , by(actyear percentile_g)
egen middle_rate_percent_ghati_sw  = sum(profit_ghati_cal * (etr_ghati_s <= 0.2) / sum_profit_g_percentile) ///
	, by(actyear percentile_g)
egen middle_rate_percent_ghati_s_p100  = mean(etr_ghati_s <= 0.2)  , by(actyear p100_decile)

egen high_rate_percent_ebrazi   = mean(etr_ebrazi <= 0.25)	, by(actyear percentile_g)
egen high_rate_percent_ghati    = mean(etr_ghati <= 0.25)    , by(actyear percentile_g)
egen high_rate_percent_ghati_s  = mean(etr_ghati_s <= 0.25)  , by(actyear percentile_g)
egen high_rate_percent_ghati_sw  = sum(profit_ghati_cal * (etr_ghati_s <= 0.25) / sum_profit_g_percentile) ///
	, by(actyear percentile_g)
egen high_rate_percent_ghati_s_p100  = mean(etr_ghati_s <= 0.25)  , by(actyear p100_decile)


egen avg_etr_ghati_percentile  = mean(etr_ghati_s), by(actyear percentile_g)
egen avg_etr_ebrazi_percentile = mean(etr_ebrazi) if etr_ebrazi < 20, by(actyear percentile_g)


gen etr_tag = .
replace etr_tag = 4 if etr_ghati_s <= 0.25
replace etr_tag = 3 if etr_ghati_s <= 0.2
replace etr_tag = 2 if etr_ghati_s <= 0.05
replace etr_tag = 1 if etr_ghati_s <= 0.01

label define etr_tag_label ///
	1 "از ۰ تا ۱ درصد" ///
	2 "از ۱ تا ۵ درصد" ///
	3 "از ۵ تا ۲۰ درصد" ///
	4 "از ۲۰ تا ۲۵ درصد"
label values etr_tag etr_tag_label

// Lost Income:
egen sum_lost_income_percentile = sum(lost_income_ebrazi2), by(actyear percentile_g)
// gen tax_exp_to_profit_eb = avg_lost_income_percentile_eb / avg_profit_percentile
// egen tax_exp_to_profit_eb = mean(lost_income_ebrazi2 / profit_ebrazi), by(actyear percentile)

