// frame change default
// graph set window fontface "B Nazanin"
//
// graph drop _all
// graph set svg fontface "B Nazanin"
//
//
// frame create Moafiat_frame
// frame change Moafiat_frame
//
//
// use "$dir\Moafiat.dta", clear
//
// drop if missing(actyear)
// local maliat_maghtoo_code 35
//
// // @@@ Sharif Version.
// if $is_sharif_version == 1 {
// 	rename benefit Exempted_Profit
// 	rename new_code exemption_id
// 	local maliat_maghtoo_code 37
// 	egen trace_id = concat(actyear id), punct(_)
// 	rename activity exemption_description
// 	replace exemption_description = ""
// }
//
//
// frlink m:1 trace_id		, frame(default)
// frget percentile_g		, from(default)
// // frget percentile		, from(default)
// frget etr_ghati_s		, from(default)
// frget etr_ghati_s2		, from(default)
// frget etr_ebrazi		, from(default)
// frget profit_ebrazi		, from(default)
// frget profit_ghati_cal	, from(default)
// frget tax_ghati			, from(default)
// frget T00_ActivityType	, from(default)
// frget T00_ActivityTypeName	, from(default)
//
//
// sort percentile_g
//
// label define temp 27 "فعالیت‌های تولیدی و معدنی (ماده ۱۳۲ ق‌م‌م)", modify
// label define temp 20 "سود سپرده و جوایز بانک‌ها و موسسات اعتباری غیربانکی مجاز (ماده ۱۴۵ ق‌م‌م‌)", modify
// label define temp 9 "درآمد حاصل از صادرات خدمات و کالاهای غیرنفتی (صدر ماده ۱۴۱ ق‌م‌م)", modify
// label values exemption_description temp

frame change Moafiat_frame


// top20
foreach exm_desc_id in 27 39 9 20 24 53 21 26 {


// top20
// foreach exm_desc_id in 27 19 39 9 20 22 24 26 21 31 {

// all
// foreach exm_desc_id in 27 19 39 9 20 22 24 26 21 31 2 15 16 23 34 10 23 35 4 10 11 29 40 14 36 5 17 13 3 42 8 1 7 {

// 132 - tax holiday
// foreach exm_desc_id in 27 2 15 4 5 17 3 {

// knowledge base corporates
// foreach exm_desc_id in 22 40 {


	frame copy Moafiat_frame Moafiat_frame_temp, replace
	frame change Moafiat_frame_temp

// 		local exm_desc_id 27
		keep if actyear == $year		
		keep if exemption_description == `exm_desc_id'
		drop if Exempted_Profit < 0
		local exm_des : label (exemption_description) `exm_desc_id'
		
		
		hist percentile_g, ///
			percent ///
			title(توزیع شرکت‌ها در صدک‌های سودآوری - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از شرکت‌های بهره‌مند از معافیت, size(medium)) ///
			xtitle(صدک شرکت‌ها, size(medium)) ///
			color(red%60)	 ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_E_`exm_desc_id'_01_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_01_$year.png", as(png) replace
		

		hist etr_ghati_s2, ///
			percent bin(26) ///
			title(توزیع نرخ موثر مالیاتی - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از شرکت‌های بهره‌مند از معافیت, size(medium)) ///
			xtitle(نرخ موثر مالیاتی, size(medium)) ///
			color(green%60)	 ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_E_`exm_desc_id'_02_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_02_$year.png", as(png) replace

		
		hist etr_ghati_s2 if percentile_g == 100, ///
			percent bin(26) ///
			title(توزیع نرخ موثر مالیاتی در شرکت‌های صدک ۱۰۰‌ام - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از شرکت‌های بهره‌مند از معافیت صدم ۱۰۰ام, size(medium)) ///
			xtitle(نرخ موثر مالیاتی, size(medium)) ///
			color(green%60)	 ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_E_`exm_desc_id'_03_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_03_$year.png", as(png) replace

		
		gsort -Exempted_Profit
		gen idx = _n
		cumul idx [w=int(Exempted_Profit)], gen(Exempted_Profit_cumul)
		replace Exempted_Profit_cumul = Exempted_Profit_cumul * 100
		gsort -Exempted_Profit_cumul
		line Exempted_Profit_cumul idx if idx < min(500, _N),  ///
			title(سهم تجمعی شرکت‌ها از درآمد مشمول این معافیت - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از درآمد مشمول معافیت, size(medium)) ///
			xtitle(تعداد شرکت, size(medium)) ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_E_`exm_desc_id'_04_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_04_$year.png", as(png) replace
		
		
		preserve
			local corp_count 10 
			local other_indx 11
			local other_count = _N - `corp_count'
			
			gsort -Exempted_Profit
			insobs 1
			egen sum_other = sum(Exempted_Profit * (idx > `corp_count'))

			replace Exempted_Profit = sum_other if _n == _N
			drop if idx > `corp_count' & !missing(idx)
			replace idx = `corp_count' + 1 if _n == _N
			
			graph pie Exempted_Profit, over(idx) ///
				title(توزیع درآمد مشمول مالیات در میان ‍‍`corp_count' شرکت بزرگ, size(large)) ///
				subtitle(`exm_des') ///
				legend(off) ///
				plabel(1  "شرکت اول")  ///
				plabel(2  "‌شرکت دوم")  ///
				plabel(3  "شرکت سوم")  ///
				plabel(`other_indx'  "سایر ( `other_count' شرکت)") ///
				pie(`other_indx', color(gray%60)) ///
				name(P2_E_`exm_desc_id'_041_$year, replace)
			graph export "$out_dir/P2_E_`exm_desc_id'_041_$year.png", as(png) replace
		restore
		
		
		graph pie Exempted_Profit, over(T00_ActivityType) ///
			sort descending ///
			pie(3, color(236 107 86)) ///
			pie(2, color(255 193 84)) ///
			pie(1, color(71  179 156)) ///
			plabel(1  name)  ///
			title(عمده نوع فعالیت مشمولین معافیت - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			name(P2_E_`exm_desc_id'_05_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_05_$year.png", as(png) replace

		
// #################################### by Activity Type Name charts

		// collapse data:
		gen count = 1
		gen count_p100 = 0
		replace count_p100 = 1 if percentile_g == 100
		
		gen Exempted_Profit_p100 = Exempted_Profit * (percentile_g == 100)
		collapse (sum) count count_p100 Exempted_Profit Exempted_Profit_p100, by(T00_ActivityTypeName)
		
		// Add new row for 'others':
		gen is_other_row = 0
		insobs 1
		replace is_other_row = 1 if missing(is_other_row)
		replace T00_ActivityTypeName = -1 if is_other_row
		label define temp1 -1 "سایر فعالیت‌ها", modify
		label values T00_ActivityTypeName temp1
		
		
		local corp_count 9
		gsort -Exempted_Profit
		gen order = _n
		egen Exempted_Profit_other = sum(Exempted_Profit * (order >= `corp_count'))
		replace Exempted_Profit = Exempted_Profit_other if is_other_row
		replace order = 1000 if is_other_row
		
		
		graph pie Exempted_Profit ///
				if (order < `corp_count' | order == 1000), ///
			over(T00_ActivityTypeName) ///
			sort(order) ///
			title(عمده نوع فعالیت مشمولین معافیت - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			legend(rows(3) symxsize(*1.5) size(*1.2) ring(1) pos(6)) ///
			plabel(1 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(2 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(3 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(4 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(5 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(1 name) ///
			plabel(2 name) ///
			plabel(3 name, gap(2)) ///
			plabel(`corp_count' "سایر", gap(2)) ///
			plabel(`corp_count' percent, format(%2.0f) color(black) gap(-12)) ///
			name(P2_E_`exm_desc_id'_06_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_06_$year.png", as(png) replace
		
		
		local corp_count 9
		gsort -Exempted_Profit_p100
		gen order_p100 = _n
		replace order_p100 = 1000 if is_other_row
		egen Exempted_Profit_p100_other = sum(Exempted_Profit_p100 * (order_p100 >= `corp_count'))
		replace Exempted_Profit_p100 = Exempted_Profit_p100_other if order == 1000
		
		
		graph pie Exempted_Profit_p100 ///
				if (order_p100 < `corp_count' | order_p100 == 1000), ///
			over(T00_ActivityTypeName) ///
			sort(order_p100) ///
			title(عمده نوع فعالیت مشمولین معافیت در صدک ۱۰۰ام - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			legend(rows(3) symxsize(*1.5) size(*1.2) ring(1) pos(6)) ///
			plabel(1 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(2 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(3 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(4 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(5 percent, format(%2.0f) color(black) gap(-12)) ///
			plabel(1 name) ///
			plabel(2 name) ///
			plabel(3 name, gap(2)) ///
			plabel(`corp_count' "سایر", gap(2)) ///
			plabel(`corp_count' percent, format(%2.0f) color(black) gap(-12)) ///
			name(P2_E_`exm_desc_id'_07_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_07_$year.png", as(png) replace
		
		
		graph bar (asis) count if order < 10, ///
			over(T00_ActivityTypeName, label(angle(45))) ///
			title(تعداد شرکت‌های فعال در هر فعالیت - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) ///
			ytitle(تعداد شرکت بهره‌مند از معافیت, size(medium)) ///
			yscale(titlegap(1.5)) ///
			name(P2_E_`exm_desc_id'_08_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_08_$year.png", as(png) replace
		
		
		graph bar (asis) count_p100 if order_p100 < 10, ///
			over(T00_ActivityTypeName, label(angle(45))) ///
			title(تعداد شرکت‌های فعال در هر فعالیت در صدک ۱۰۰ام - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) ///
			ytitle(تعداد شرکت بهره‌مند از معافیت در صدک ۱۰۰ام, size(medium)) ///
			yscale(titlegap(1.5)) ///
			name(P2_E_`exm_desc_id'_09_$year, replace)
		graph export "$out_dir/P2_E_`exm_desc_id'_09_$year.png", as(png) replace
		
		
	frame change Moafiat_frame
	frame drop Moafiat_frame_temp
}



frame change default
frame drop Moafiat_frame

