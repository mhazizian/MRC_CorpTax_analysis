
frame change default
if $drop_frame == 1 {
	frame drop Moafiat_frame
	frame drop Bakhshodegi_frame
	frame drop Combined
	frame drop CPI
}

tempname one two combined

// **********************************************************
// ******************                     *******************
// ****************  CREATE Moafiat Frame. ******************
// ******************                     *******************
// **********************************************************


frame create Moafiat_frame
frame change Moafiat_frame


	use "$dir\Moafiat.dta", clear

	drop if missing(actyear)
	global maliat_maghtoo_code 35

	// @@@ Sharif Version.
	if $is_sharif_version == 1 {
		rename benefit Exempted_Profit
		rename new_code exemption_id
		global maliat_maghtoo_code 37
		egen trace_id = concat(actyear id), punct(_)
		rename activity exemption_description
		replace exemption_description = ""
	}


	// drop if exemption_id == $maliat_maghtoo_code

	frlink m:1 trace_id		, frame(default)
	frget percentile_g		, from(default)
	// frget percentile		, from(default)
	frget etr_ghati_s		, from(default)
	frget etr_ghati_s2		, from(default)
	frget etr_ebrazi		, from(default)
	frget profit_ebrazi		, from(default)
	frget profit_ghati_cal	, from(default)
	frget tax_ghati			, from(default)

	frget profit_ghati_maghtou_exc	, from(default)
	frget etr_ghati_maghtou_exc		, from(default)
	frget percentile_g_maghtou_exc	, from(default)

	frget top200			, from(default)
	frget top500			, from(default)
	frget top1000			, from(default)

	frget T00_ActivityType	, from(default)
	frget T00_ActivityTypeName			, from(default)

	frget is_in_free_trade_zones_exm	, from(default)
	frget is_tolidi_m		, from(default)
	frget is_tolidi_b		, from(default)
	frget otagh_membership	, from(default)


	sort percentile_g

	keep if !missing(percentile_g) | !missing(tax_ghati) | !missing(top200)
	// do "dup_drop_moafiat.do"
	do "./identify_corporates.do"

	// merge into 132:
	replace exemption_id = 2 if exemption_id == 13
	replace exemption_description = 27 if exemption_description == 15
	
	replace exemption_id = 2 if exemption_id == 5
	replace exemption_description = 27 if exemption_description == 2
	
	replace exemption_id = 2 if exemption_id == 6
	replace exemption_description = 27 if exemption_description == 4
	
	
	// fix for نامشخص‌ exemptions:
	replace exemption_description = 19 if exemption_description == 38
	replace exemption_id = 37 if exemption_id == 100
	
	
	gen exemption_description2 = exemption_description
	
	label copy temp exemption_desc_label
	label define exemption_desc_label 27 "فعالیت تولیدی معدنی (م۱۳۲)", modify
	label define exemption_desc_label 39 "هدایا و درآمد ها (م ۱۳۹)", modify
	label define exemption_desc_label 9  "صادرات کالا خدمات", modify
	label define exemption_desc_label 20 "سود سپرده بانکی", modify
	label define exemption_desc_label 24 "صندوق سرمایه‌گذاری", modify
	label define exemption_desc_label 26 "مناطق آزاد", modify
	label define exemption_desc_label 53 "افزایش سرمایه از محل سود انباشته", modify
	label values exemption_description2 exemption_desc_label
	

	gen lost_income = 0.25 * Exempted_Profit

	
	drop default
	save `one', replace
frame change default


// **********************************************************
// ******************                         ***************
// ****************  CREATE Bakhshoodegi Frame. *************
// ******************                         ***************
// **********************************************************


frame change default
frame create Bakhshodegi_frame
frame change Bakhshodegi_frame

	use "$dir\Bakhshhodegi.dta", clear
	duplicates drop

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
	frget etr_ghati_s2		, from(default)
	frget etr_ebrazi		, from(default)
	frget profit_ebrazi		, from(default)
	frget profit_ghati_cal	, from(default)
	frget tax_ghati			, from(default)

	frget profit_ghati_maghtou_exc	, from(default)
	frget etr_ghati_maghtou_exc		, from(default)
	frget percentile_g_maghtou_exc	, from(default)

	frget top200			, from(default)
	frget top500			, from(default)
	frget top1000			, from(default)

	frget T00_ActivityType	, from(default)
	frget T00_ActivityTypeName			, from(default)

	frget is_in_free_trade_zones_exm	, from(default)
	frget is_tolidi_m		, from(default)
	frget is_tolidi_b		, from(default)
	frget otagh_membership	, from(default)


	sort percentile_g


	keep if  !missing(percentile_g) | !missing(tax_ghati) | !missing(top200)
	// do "dup_drop_moafiat.do"
	do "./identify_corporates.do"
	
	
	replace bakhshoodegi_description = 3 if bakhshoodegi_description == 4
	replace bakhshoodegi_id = 213 if bakhshoodegi_id == 214
	
	replace bakhshoodegi_description = 13 if bakhshoodegi_description == 10
	replace bakhshoodegi_id = 10 if bakhshoodegi_id == 7
	
	gen bakhshoodegi_description2 = bakhshoodegi_description
	label copy temp bakhsh_desc_label
	
	label define bakhsh_desc_label 3 "کاهش نرخ تولیدی ‌ها در بودجه", modify
	label define bakhsh_desc_label 5 "تبصره ۷ ماده ۱۰۵", modify
	label define bakhsh_desc_label 13 "کاهش نرخ بورسی‌ها", modify
	label values bakhshoodegi_description2 bakhsh_desc_label

	gen lost_income = Rebate_Amount 
	drop default

	save `two', replace
frame change default

// **************************************************
// *****************                   **************
// ***************  Combine two frames. *************
// *****************                   **************
// **************************************************
frame create CPI
frame change CPI
	import excel ".\CPI.xlsx", ///
			sheet("Sheet1") firstrow clear
	rename CPI cpi_indx
	
frame change default


frame create Combined
	frame Combined: use `one'
	frame Combined: append using `two'
	frame change Combined
	duplicates drop
	
	frlink m:1 actyear	, frame(CPI)
	frget cpi_indx		, from(CPI)
	drop CPI 
	
	gen real_lost_income = lost_income / cpi_indx * 100
	
// 	gen count = 1
// 	gen count_m = !missing(exemption_id)
// 	gen count_b = !missing(bakhshoodegi_id)
// 	collapse (sum) lost_income count count_b count_m, ///
// 			by(exemption_description exemption_id bakhshoodegi_description bakhshoodegi_id actyear)
// 	order actyear lost_income count_b count_m description *
	
	
	decode exemption_description2 , generate(description_str)
	decode bakhshoodegi_description2  , generate(description2_str)
	replace description_str = description2_str if missing(description_str)
	encode description_str, gen(description)
	drop description_str description2_str exemption_description2 bakhshoodegi_description2
	
	gsort -real_lost_income
	order id actyear description lost_income real_lost_income percentile_g etr_ghati_s ///
			tax_ghati profit_ebrazi profit_ghati_cal T00_ActivityTypeName*


frame change default