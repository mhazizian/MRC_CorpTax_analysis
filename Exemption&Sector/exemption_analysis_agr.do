frame change default
graph set window fontface "B Nazanin"

graph drop _all
graph set svg fontface "B Nazanin"


frame create Moafiat_agr_frame
frame change Moafiat_agr_frame


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

drop if exemption_id == `maliat_maghtoo_code'

frlink m:1 trace_id		, frame(default)
frget percentile_g		, from(default)
// frget percentile		, from(default)
frget etr_ghati_s		, from(default)
frget etr_ghati_s2		, from(default)
frget etr_ebrazi		, from(default)
frget profit_ebrazi		, from(default)
frget profit_ghati_cal	, from(default)
frget tax_ghati			, from(default)
frget T00_ActivityType	, from(default)
frget T00_ActivityTypeName	, from(default)


sort percentile_g

// #####################################################

frame copy Moafiat_agr_frame Moafiat_agr_frame_temp, replace
frame change Moafiat_agr_frame_temp

label define temp 27 "فعالیت‌های تولیدی و معدنی (ماده ۱۳۲ ق‌م‌م)", modify
label define temp 20 "سود سپرده و جوایز بانک‌ها و موسسات اعتباری غیربانکی مجاز (ماده ۱۴۵ ق‌م‌م‌)", modify
label define temp 9 "درآمد حاصل از صادرات خدمات و کالاهای غیرنفتی (صدر ماده ۱۴۱ ق‌م‌م)", modify
label values exemption_description temp

global year 1400
keep if actyear == $year		
drop if Exempted_Profit < 0

// ################################ Collapse database
gen count = 1
gen count_p100 = 0
replace count_p100 = 1 if percentile_g == 100

gen Exempted_Profit_p100 = Exempted_Profit * (percentile_g == 100)
collapse (sum) count count_p100 Exempted_Profit Exempted_Profit_p100, by(exemption_description exemption_id)



// Add new row for 'others':
gen is_other_row = 0
insobs 1
replace is_other_row = 1 if missing(is_other_row)
replace exemption_description = -1 if is_other_row
label define temp -1 "سایر معافیت‌ها", modify
label values exemption_description temp


local exm_count 10
gsort -Exempted_Profit
gen order = _n
egen Exempted_Profit_other = sum(Exempted_Profit * (order >= `exm_count'))
replace Exempted_Profit = Exempted_Profit_other if is_other_row
replace order = 1000 if is_other_row


graph pie Exempted_Profit ///
		if (order < `exm_count' | order == 1000), ///
	over(exemption_description) ///
	sort(order) ///
	title(عمده نوع فعالیت مشمولین معافیت - سال $year, size(large)) ///
	subtitle(`exm_des') ///
	legend(rows(4) symxsize(*1.5) size(*1.2) ring(1) pos(6)) ///
	plabel(1 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(2 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(3 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(4 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(5 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(1 name) ///
	plabel(2 name) ///
	plabel(3 name, gap(2)) ///
	plabel(`exm_count' "سایر", gap(2)) ///
	plabel(`exm_count' percent, format(%2.0f) color(black) gap(-12)) ///
	name(P2_E_AGR_01_$year, replace)
graph export "./out/P2_E_AGR_01_$year.png", as(png) replace


egen count_others = sum(count * (order >= `exm_count'))
replace count = count_others if is_other_row

graph pie count ///
		if (order < `exm_count' | order == 1000), ///
	over(exemption_description) ///
	sort(order) ///
	title(عمده نوع فعالیت مشمولین معافیت - سال $year, size(large)) ///
	subtitle(`exm_des') ///
	legend(rows(4) symxsize(*1.5) size(*1.2) ring(1) pos(6)) ///
	plabel(1 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(2 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(3 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(4 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(5 percent, format(%2.0f) color(black) gap(-12)) ///
	plabel(1 name) ///
	plabel(2 name) ///
	plabel(3 name, gap(2)) ///
	plabel(`exm_count' "سایر", gap(2)) ///
	plabel(`exm_count' percent, format(%2.0f) color(black) gap(-12)) ///
	name(P2_E_AGR_02_$year, replace)
graph export "./out/P2_E_AGR_02_$year.png", as(png) replace


grc1leg  P2_E_AGR_01_$year P2_E_AGR_02_$year

				
frame change Moafiat_frame
frame drop Moafiat_agr_frame_temp
		


frame change default
frame drop Moafiat_agr_frame