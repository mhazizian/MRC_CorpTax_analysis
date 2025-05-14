
// ######################## CREATE Moafiat Frame.
frame change default

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


label define temp 27 "فعالیت‌های تولیدی و معدنی (ماده ۱۳۲ ق‌م‌م)", modify
label define temp 20 "سود سپرده و جوایز بانک‌ها و موسسات اعتباری غیربانکی مجاز (ماده ۱۴۵ ق‌م‌م‌)", modify
label define temp 9 "درآمد حاصل از صادرات خدمات و کالاهای غیرنفتی (صدر ماده ۱۴۱ ق‌م‌م)", modify
label values exemption_description temp


frame change default


// ######################## CREATE Bakhshoodegi Frame.

frame change default
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


frame change default