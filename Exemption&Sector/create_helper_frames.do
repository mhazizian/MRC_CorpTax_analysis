
frame change default
if $drop_frame == 1 {
	frame drop Moafiat_frame
	frame drop Bakhshodegi_frame
	frame drop Combined
}

tempname one two combined

// **********************************************************
// ********************                       ***************
// ****************  CREATE Moafiat Frame. ******************
// ********************                       ***************
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
	
	label copy temp exemption_desc_label
	label define exemption_desc_label 27 "فعالیت‌های تولیدی و معدنی (ماده ۱۳۲ ق‌م‌م)", modify
	label define exemption_desc_label 20 "سود سپرده و جوایز بانک‌ها و موسسات اعتباری غیربانکی مجاز (ماده ۱۴۵ ق‌م‌م‌)", modify
	label define exemption_desc_label 9 "درآمد حاصل از صادرات خدمات و کالاهای غیرنفتی (صدر ماده ۱۴۱ ق‌م‌م)", modify
	label values exemption_description exemption_desc_label

	replace exemption_description = 19 if exemption_description == 38
	replace exemption_id = 37 if exemption_id == 100

	gen lost_income = 0.25 * Exempted_Profit


	save `one', replace
frame change default


// ************************************************************
// ********************                         ***************
// ******************  CREATE Bakhshoodegi Frame. *************
// ********************                         ***************
// ************************************************************


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
	
	label copy temp bakhsh_desc_label
	label values bakhshoodegi_description bakhsh_desc_label

	gen lost_income = Rebate_Amount 

	save `two', replace
frame change default

// **************************************************
// *****************                   **************
// ***************  Combine two frames. *************
// *****************                   **************
// **************************************************


frame create Combined
	frame Combined: use `one'
	frame Combined: append using `two'
	frame change Combined
	duplicates drop

	gen count = 1
	gen count_m = !missing(exemption_id)
	gen count_b = !missing(bakhshoodegi_id)
	collapse (sum) lost_income count count_b count_m, ///
			by(exemption_description exemption_id bakhshoodegi_description bakhshoodegi_id actyear)
	order lost_income count_b count_m exemption_description bakhshoodegi_description *
	gsort -lost_income



frame change default