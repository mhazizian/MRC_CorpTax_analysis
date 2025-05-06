



// ######################## Add labels based on used Exemptions and Credit.


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
}


// gen is_tolidi_temp = 0
// replace is_tolidi_temp = 1 if exemption_id == 2
// replace is_tolidi_temp = 1 if exemption_id == 13
// egen is_tolidi_m = max(is_tolidi_temp), by(trace_id)

keep trace_id is_tolidi_m
duplicates drop

frame change default
frlink 1:1 trace_id, frame(Moafiat_frame)

frget is_tolidi_m, from(Moafiat_frame)

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

// بخشودگی ۵ تا ۷ واحد درصدی شرکت‌های تولیدی
gen is_tolidi_temp = 0
replace is_tolidi_temp = 1 if bakhshoodegi_id == 213
replace is_tolidi_temp = 1 if bakhshoodegi_id == 214
egen is_tolidi_b = max(is_tolidi_temp), by(trace_id)


keep trace_id is_tolidi_b
duplicates drop

frame change default
frlink 1:1 trace_id, frame(Bakhshodegi_frame)
frget is_tolidi_b, from(Bakhshodegi_frame)

frame drop Bakhshodegi_frame
drop Bakhshodegi_frame



























