frame change default
graph drop _all

graph set svg fontface "B Nazanin"


frame copy default graph_frame, replace
frame change graph_frame
	keep if actyear == $year

// 	drop if is_not_audited == 1
	drop if profit_ghati_cal == 0
	drop if profit_ghati_cal < 0
	
	sort percentile_g p100_decile
	
	replace zero_rate_percent_ghati_s = zero_rate_percent_ghati_s * 100
	replace low_rate_percent_ghati_s = low_rate_percent_ghati_s * 100
	replace middle_rate_percent_ghati_s = middle_rate_percent_ghati_s * 100
	replace high_rate_percent_ghati_s = high_rate_percent_ghati_s * 100

	
	// #########################################################################
	
	// 	note(مبتنی بر بهره‌مندی شرکت از بخشودگی تولیدی‌ها در قانون بودجه مطابق خوداظهاری شرکت) ///
	
	hist percentile_g if is_tolidi_b == 1 & actyear == 1400, ///
		percent ///
		title(توزیع شرکت‌های تولیدی در صدک‌های سودآوری شرکت‌ها - سال $year, size(large)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از شرکت‌های تولیدی, size(medium)) ///
		xtitle(صدک شرکت‌ها, size(medium)) ///
		note(مبتنی بر بهره‌مندی شرکت از بخشودگی تولیدی‌ها در قانون بودجه مطابق خوداظهاری شرکت) ///
		color(green%60)	 ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
		name(E01_$year, replace)
	graph export "./out/E001_$year.png", as(png) replace
	

	hist etr_ghati_s2 if is_tolidi_b == 1 & actyear == 1400, ///
		percent bin(26) ///
		title(توزیع نرخ موثر مالیاتی در شرکت‌های تولیدی - سال $year, size(large)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از شرکت‌های تولیدی, size(medium)) ///
		xtitle(نرخ موثر شرکت, size(medium)) ///
		color(green%60)	 ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
		name(E02_$year, replace)
	graph export "./out/E002_$year.png", as(png) replace

	
	hist etr_ghati_s2 if is_tolidi_b == 1 & actyear == 1400 & percentile_g == 100, ///
		percent bin(26) ///
		title(توزیع نرخ موثر مالیاتی در شرکت‌های تولیدی صدک ۱۰۰‌ام - سال $year, size(large)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از شرکت‌های تولیدی صدک ۱۰۰‌ام, size(medium)) ///
		xtitle(نرخ موثر شرکت, size(medium)) ///
		color(green%60)	 ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
		name(E03_$year, replace)
	graph export "./out/E003_$year.png", as(png) replace

	

frame change default

frame drop graph_frame
