
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
}

// Maliat Maghtoo
drop if exemption_id == `maliat_maghtoo_code'

frlink m:1 trace_id		, frame(default)
frget percentile_g		, from(default)
frget percentile		, from(default)
frget etr_ghati_s		, from(default)
frget etr_ebrazi		, from(default)
frget profit_ebrazi		, from(default)
frget profit_ghati_cal	, from(default)


// foreach vp in percentile percentile_g {
foreach vp in percentile_g {
	preserve
		keep if `vp' == 100
		egen agr_li_moafiat = sum(Exempted_Profit * 0.25), by(exemption_id actyear)
		egen corp_count = count(id), by(exemption_id actyear)
		
		keep actyear ///
			exemption_id ///
			exemption_description ///
			agr_li_moafiat ///
			corp_count

		duplicates drop
		gsort -agr_li_moafiat	
		export excel "Moafiat_`vp'100_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
	restore
}


foreach v_etr in etr_ebrazi etr_ghati_s {
// 	foreach etr in 0.01 0.05 {
	foreach etr in 0.01 {
		preserve
			keep if `v_etr' <= `etr'
			egen agr_li_moafiat = sum(Exempted_Profit * 0.25), by(exemption_id actyear)
			egen corp_count = count(id), by(exemption_id actyear)
			
			keep actyear ///
				exemption_id ///
				exemption_description ///
				agr_li_moafiat ///
				corp_count

			duplicates drop
			gsort -agr_li_moafiat	
			export excel "Moafiat_`v_etr'_Le`etr'p_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
		restore
	}
}



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
}


drop if missing(actyear)
// local maliat_maghtoo_code 35
// Maliat Maghtoo
// drop if exemption_id == `maliat_maghtoo_code'

frlink m:1 trace_id		, frame(default)
frget percentile_g		, from(default)
frget percentile		, from(default)
frget etr_ghati_s		, from(default)
frget etr_ebrazi		, from(default)
frget profit_ebrazi		, from(default)
frget profit_ghati_cal	, from(default)


foreach vp in percentile_g {
	preserve
		keep if `vp' == 100
		egen agr_li_bakhshoodegi = sum(Rebate_Amount), by(bakhshoodegi_id actyear)
		egen corp_count = count(id), by(bakhshoodegi_id actyear)
		
		keep actyear ///
			bakhshoodegi_id ///
			bakhshoodegi_description ///
			agr_li_bakhshoodegi ///
			corp_count

		duplicates drop
		gsort -agr_li_bakhshoodegi	
		export excel "Bakhshoodegi_`vp'100_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
	restore
}

foreach v_etr in etr_ebrazi etr_ghati_s {
	foreach etr in 0.01 {
		preserve
			keep if `v_etr' <= `etr'
			egen agr_li_bakhshoodegi = sum(Rebate_Amount), by(bakhshoodegi_id actyear)
			egen corp_count = count(id), by(bakhshoodegi_id actyear)
			
			keep actyear ///
				bakhshoodegi_id ///
				bakhshoodegi_description ///
				agr_li_bakhshoodegi ///
				corp_count

			duplicates drop
			gsort -agr_li_bakhshoodegi	
			export excel "Bakhshoodegi_`v_etr'_Le`etr'p_isSharif-$is_sharif_version.xlsx", firstrow(varl) replace
		restore
	}
}

frame change default
frame drop Bakhshodegi_frame


