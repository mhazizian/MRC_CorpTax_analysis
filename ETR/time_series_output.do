
frame change default

frame copy default output_frame, replace
frame change output_frame

// replace tax_ghati  = . if missing(profit_ghati_cal)
// replace tax_ebrazi = . if missing(profit_ebrazi)

egen total_profit_ebrazi = sum(profit_ebrazi), by(actyear)
egen total_profit_ghati = sum(profit_ghati_cal), by(actyear)

egen sum_tax_ebrazi_yearly = sum(tax_ebrazi), by(actyear)
egen sum_tax_ghati_yearly  = sum(tax_ghati)	, by(actyear)

gen  share_of_t_profit_e   = profit_ebrazi / total_profit_ebrazi
gen  share_of_t_profit_g   = profit_ghati_cal / total_profit_ghati

gen  etr_ebrazi_agr_yearly = sum_tax_ebrazi_yearly / total_profit_ebrazi
gen  etr_ghati_agr_yearly  = sum_tax_ghati_yearly / total_profit_ghati

egen sum_lost_income_ebrazi = sum(lost_income_ebrazi2), by(actyear)
egen sum_tax_ghati 			= sum(tax_ghati)		  , by(actyear)

egen count_valid_etr_ebrazi = sum(!missing(etr_ebrazi)) , by(actyear)
egen count_valid_etr_ghati  = sum(!missing(etr_ghati_s)), by(actyear)

************************************

local percent 0.01 
display "###########  corporate with etr_ebrazi < `percent' ########"

egen lp_sum_lost_income_ebrazi	 = sum( lost_income_ebrazi2 * (etr_ebrazi <= `percent')), by(actyear)
egen lp_sum_lost_income_ebrazi_g = sum( lost_income_ebrazi2 * (etr_ghati_s <= `percent')), by(actyear)

egen count_of_lp_ebrazi   = mean(etr_ebrazi  <= `percent'), by(actyear)
egen count_of_lp_ghati    = sum(etr_ghati_s <= `percent'), by(actyear)
gen percent_of_lp_ghati = count_of_lp_ghati / count_valid_etr_ghati

egen lp_profit_share_ebrazi   = sum(profit_ebrazi * (etr_ebrazi  <= `percent')), by(actyear)
	replace lp_profit_share_ebrazi = lp_profit_share_ebrazi / total_profit_ebrazi
label variable lp_profit_share_ebrazi "سهم شرکت‌های با نرخ موثر ابرازی ۰ تا ۱ درصد از کل سود در سال"

	
egen lp_profit_share_ghati   = sum(profit_ghati_cal * (etr_ghati_s  <= `percent')), by(actyear)
	replace lp_profit_share_ghati = lp_profit_share_ghati / total_profit_ghati
label variable lp_profit_share_ghati "سهم شرکت‌های با نرخ موثر قطعی ۰ تا ۱ درصد از کل سود در سال"


rename zero_rate_percent_ebrazi 	etr0_share_ebrazi_in_p100
rename zero_rate_percent_ghati_s 	etr0_share_ghati_in_p100
rename avg_etr_ebrazi_percentile 	avg_etr_ebrazi_p100
rename avg_etr_ghati_percentile 	avg_etr_ghati_p100


preserve
	keep if percentile_g == 100
	keep actyear ///
		etr_ebrazi_agr_yearly ///
		etr_ghati_agr_yearly ///
		sum_lost_income_ebrazi ///
		sum_tax_ghati ///
		count_valid_etr_ebrazi ///
		count_valid_etr_ghati /*
		
		less than 1 percent rate:
		
		*/ lp_sum_lost_income_ebrazi ///
		lp_sum_lost_income_ebrazi_g ///
		count_of_lp_ebrazi ///
		count_of_lp_ghati ///
		percent_of_lp_ghati ///
		lp_profit_share_ebrazi /// 
		lp_profit_share_ghati /*
		
		percentile 100 stats:
		
		*/ etr0_share_ebrazi_in_p100 ///
		etr0_share_ghati_in_p100 ///
		avg_etr_ebrazi_p100 ///
		avg_etr_ghati_p100 
	duplicates drop
	export excel "ETR_timeSeries_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
restore




frame change default
frame drop output_frame

