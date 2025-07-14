frame change default
graph set window fontface "B Nazanin"

graph drop _all
graph set svg fontface "B Nazanin"


// #####################################################

foreach state in 1 2 3 4 5 6 7 {
	
	frame copy Combined Combined_temp, replace
	frame change Combined_temp
	

	drop if lost_income < 0
	drop if exemption_id == $maliat_maghtoo_code
	
	if `state' == 1 {
		local title "همه شرکت‌ها"
	}
	if `state' == 2 {
		local title "شرکت‌های صدک ۱۰۰ام"
		keep if percentile_g == 100
	}
	if `state' == 3 {
		local title "شرکت‌های صدک ۱۰۰ام بدون درنظر گرفتن سود سهام"
		keep if percentile_g_maghtou_exc == 100
	}
	if `state' == 4 {
		local title "۲۰۰ شرکت بزرگ"
		keep if top200 == 1
	}
	if `state' == 5 {
		local title "شرکت‌های تولیدی"
		keep if is_tolidi_b == 1 | is_tolidi_m == 1
	}
	if `state' == 6 {
		local title "شرکت‌های عضو اتاق بازرگانی"
		keep if otagh_membership == 1
	}
	if `state' == 7 {
		local title "مناطق آزاد تجاری - صنعتی"
		keep if is_in_free_trade_zones_exm == 1
	}
	

	// ########### Collapse database
	
	gen count = 1
	gen count_m = !missing(exemption_id)
	gen count_b = !missing(bakhshoodegi_id)
	collapse (sum) lost_income real_lost_income count count_b count_m, ///
			by(description exemption_description exemption_id bakhshoodegi_description bakhshoodegi_id actyear)
			
			
	egen total_exp = sum(lost_income), by(actyear)
	gen exp_share = lost_income / total_exp * 100
	gsort -real_lost_income
	order actyear lost_income real_lost_income exp_share count_b count_m description *

	
// 	graph twoway line exp_share actyear ///
// 		if description == 43 ///
// 		| description == 59 ///
// 		| description == 46 ///
// 		| description == 16 ///
// 		| description == 30 ///
// 		| description == 8 ///
// 		, sort by(description)
//	
	
	
// 	twoway ///
// 		(line  exp_share actyear if exemption_description == 27, sort) ///
// 		(line  exp_share actyear if exemption_description == 30, sort), ///
// 		legend(pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(متوسط نرخ مالیات موثر شرکت, size(medium)) ///
// 		xtitle(صدک شرکت, size(medium)) ///
// 		title(متوسط نرخ موثر مالیات در هر صدک -‍ سال $year, size(large)) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
//		
		
		
// 	graph twoway line  exp_share actyear if exemption_description == 27, sort
	
	
	
	keep if actyear == $year
	// ########### Add new row for 'others'
	gen is_other_row = 0
	insobs 1
	replace is_other_row = 1 if missing(is_other_row)
	replace description = -1 if is_other_row
	
	label define description -1 "سایر مشوق‌های مالیاتی", modify
	label values description description


	local exm_count 10
	gsort -lost_income
	gen order = _n
	egen lost_income_other = sum(lost_income * (order >= `exm_count'))
	replace lost_income = lost_income_other if is_other_row
	replace order = 1000 if is_other_row


	graph pie lost_income ///
			if (order < `exm_count' | order == 1000), ///
		over(description) ///
		sort(order) ///
		title(توزیع درآمد معاف از مالیات در انواع معافیت‌های مالیاتی - سال $year, size(large)) ///
		subtitle(`title') ///
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
		name(P2_E__AGR_S`state'_01_$year, replace)
	graph export "$out_dir/P2_E__AGR_S`state'_01_$year.png", as(png) replace


	egen count_others = sum(count * (order >= `exm_count'))
	replace count = count_others if is_other_row

	graph pie count ///
			if (order < `exm_count' | order == 1000), ///
		over(description) ///
		sort(order) ///
		title(تعداد شرکت‌های استفاده کننده از معافیت - سال $year, size(large)) ///
		subtitle(`title') ///
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
		name(P2_E__AGR_S`state'_02_$year, replace)
	graph export "$out_dir/P2_E__AGR_S`state'_02_$year.png", as(png) replace


	grc1leg  P2_E__AGR_S`state'_01_$year P2_E__AGR_S`state'_02_$year, ///
		name(P2_E__AGR_S`state'_03_$year, replace)
	graph export "$out_dir/P2_E__AGR_S`state'_03_$year.png", as(png) replace
	


	frame change default
	frame drop Combined_temp

}



	

