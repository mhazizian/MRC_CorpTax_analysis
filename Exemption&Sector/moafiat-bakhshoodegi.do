
frame change default

frame create Moafiat_frame
frame change Moafiat_frame


use "$dir\Moafiat.dta", clear

drop if missing(actyear)
local maliat_maghtoo_code 35

// @@@ Sharif Version.
if $is_sharif_version == 1 {
	rename benefit Exempted_Profit
	rename new_code exemption_id
	local maliat_maghtoo_code 37
	egen trace_id = concat(actyear id), punct(_)
	rename activity exemption_description
	replace exemption_description = ""
}

// Maliat Maghtoo
// drop if exemption_id == `maliat_maghtoo_code'

frlink m:1 trace_id		, frame(default)
frget percentile_g		, from(default)
// frget percentile		, from(default)
frget etr_ghati_s		, from(default)
frget etr_ebrazi		, from(default)
frget profit_ebrazi		, from(default)
frget profit_ghati_cal	, from(default)


preserve
	// TODO: check this decision.
	drop if Exempted_Profit < 0
	
	egen agr_li_moafiat_all = sum(Exempted_Profit * 0.25), by(exemption_id actyear)
	egen corp_count_all = count(id), by(exemption_id actyear)
	
	egen agr_li_moafiat_lp = sum(Exempted_Profit * 0.25 * (etr_ghati_s <= 0.01)), by(exemption_id actyear)
	egen corp_count_lp = sum(int(etr_ghati_s <= 0.01 & Exempted_Profit > 0 & !missing(Exempted_Profit))), by(exemption_id actyear)
		
	egen agr_li_moafiat_p100 = sum(Exempted_Profit * 0.25 * (percentile_g == 100)), by(exemption_id actyear)
	egen corp_count_p100 = sum(int(Exempted_Profit > 0 & !missing(Exempted_Profit) & (percentile_g == 100))), by(exemption_id actyear)
	
	keep actyear ///
		exemption_id ///
		exemption_description ///
		agr_li_moafiat_p100 ///
		corp_count_p100 ///
		agr_li_moafiat_all ///
		corp_count_all ///
		agr_li_moafiat_lp ///
		corp_count_lp 

		
	duplicates drop
	gsort -agr_li_moafiat_all	
	export excel "$out_dir/Moafiat_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
restore



frame change default
frame drop Moafiat_frame

// ############################  ####################################
// #####################                #############################
// ####################   Bakhshoodegi   ############################

frame create Bakhshodegi_frame
frame change Bakhshodegi_frame

use "$dir\Bakhshhodegi.dta", clear

// @@@ Sharif Version.
if $is_sharif_version == 1 {
	rename bakhshoodegiqty Rebate_Amount
	egen trace_id = concat(actyear id), punct(_)
	rename bakhshoodegi_code bakhshoodegi_id
	rename activity bakhshoodegi_description
	replace bakhshoodegi_description = ""
}


drop if missing(actyear)


frlink m:1 trace_id		, frame(default)
frget percentile_g		, from(default)
// frget percentile		, from(default)
frget etr_ghati_s		, from(default)
frget etr_ebrazi		, from(default)
frget profit_ebrazi		, from(default)
frget profit_ghati_cal	, from(default)


preserve
	drop if Rebate_Amount < 0
	egen agr_li_bakhshoodegi_all = sum(Rebate_Amount), by(bakhshoodegi_id actyear)
	egen corp_count_all = sum(int(Rebate_Amount > 0 & !missing(Rebate_Amount))), by(bakhshoodegi_id actyear)
	
	egen agr_li_bakhshoodegi_lp = sum(Rebate_Amount * (etr_ghati_s <= 0.01)), by(bakhshoodegi_id actyear)
	egen corp_count_lp = sum(int(etr_ghati_s <= 0.01 & Rebate_Amount > 0 & !missing(Rebate_Amount))), by(bakhshoodegi_id actyear)

	egen agr_li_bakhshoodegi_p100 = sum(Rebate_Amount  * (percentile_g == 100)), by(bakhshoodegi_id actyear)
	egen corp_count_p100 = sum(int(Rebate_Amount > 0 & !missing(Rebate_Amount) & (percentile_g == 100))), by(bakhshoodegi_id actyear)
	
	keep actyear ///
		bakhshoodegi_id ///
		bakhshoodegi_description ///
		agr_li_bakhshoodegi_p100 ///
		corp_count_p100 ///
		agr_li_bakhshoodegi_all ///
		corp_count_all ///
		agr_li_bakhshoodegi_lp ///
		corp_count_lp

		
	duplicates drop
	gsort -agr_li_bakhshoodegi_all
	export excel "$out_dir/Bakhshoodegi_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
restore

frame change default
frame drop Bakhshodegi_frame


