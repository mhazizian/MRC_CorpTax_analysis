
graph set window fontface "B Nazanin"

graph drop _all
graph set svg fontface "B Nazanin"


// #####################################################

foreach state in 1 2 3 4 {
	
	frame copy Moafiat_frame Moafiat_frame_temp, replace
	frame change Moafiat_frame_temp
	
	keep if actyear == $year
	drop if Exempted_Profit < 0
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
	if `state' == 4 {
		local title "شرکت‌های تولیدی'"
		keep if is_tolidi_b == 1 | is_tolidi_m == 1
	}
	

	// ########### Collapse database
	gen count = 1
	collapse (sum) count ///
			Exempted_Profit ///
			, by(exemption_description exemption_id actyear)



	// ########### Add new row for 'others'
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
		over(exemption_description) ///
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
	frame drop Moafiat_frame_temp

}



	

