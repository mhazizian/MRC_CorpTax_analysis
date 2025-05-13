frame change default

graph drop _all
graph set window fontface "B Nazanin"
graph set svg fontface "B Nazanin"

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


sort percentile_g
	
foreach exm_desc_id in 3 5 13 9 14 {
	preserve

		keep if actyear == $year
		keep if bakhshoodegi_description == `exm_desc_id'
		drop if Rebate_Amount < 0
		local exm_des : label (bakhshoodegi_description) `exm_desc_id'

		hist percentile_g, ///
			percent ///
			title(توزیع شرکت‌ها در صدک‌های سودآوری - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از شرکت‌های بهره‌مند از معافیت, size(medium)) ///
			xtitle(صدک شرکت‌ها, size(medium)) ///
			color(red%60)	 ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(p2_B_`exm_desc_id'_01_$year, replace)
		graph export "$out_dir/P2_B_`exm_desc_id'_01_$year.png", as(png) replace
		

		hist etr_ghati_s2, ///
			percent bin(26) ///
			title(توزیع نرخ موثر مالیاتی - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از شرکت‌های بهره‌مند از معافیت, size(medium)) ///
			xtitle(نرخ موثر مالیاتی, size(medium)) ///
			color(green%60)	 ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_B_`exm_desc_id'_02_$year, replace)
		graph export "$out_dir/P2_B_`exm_desc_id'_02_$year.png", as(png) replace

		
		hist etr_ghati_s2 if percentile_g == 100, ///
			percent bin(26) ///
			title(توزیع نرخ موثر مالیاتی در شرکت‌های صدک ۱۰۰‌ام - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از شرکت‌های بهره‌مند از معافیت صدم ۱۰۰ام, size(medium)) ///
			xtitle(نرخ موثر مالیاتی, size(medium)) ///
			color(green%60)	 ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_B_`exm_desc_id'_03_$year, replace)
		graph export "$out_dir/P2_B_`exm_desc_id'_03_$year.png", as(png) replace

		
		gsort -Rebate_Amount
		gen idx = _n
		cumul idx [w=int(Rebate_Amount)], gen(Rebate_Amount_cumul)
		replace Rebate_Amount_cumul = Rebate_Amount_cumul * 100
		gsort -Rebate_Amount_cumul
		line Rebate_Amount_cumul idx if idx < 500,  ///
			title(سهم تجمعی شرکت‌ها از این بخشودگی - سال $year, size(large)) ///
			subtitle(`exm_des') ///
			ylab(, grid) xlab(, grid) ///
			ytitle(درصد از مالیات مشمول بخشودگی, size(medium)) ///
			xtitle(تعداد شرکت, size(medium)) ///
			xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
			name(P2_B_`exm_desc_id'_04_$year, replace)
		graph export "$out_dir/P2_B_`exm_desc_id'_04_$year.png", as(png) replace
		
	restore
}


frame change default
frame drop Bakhshodegi_frame

