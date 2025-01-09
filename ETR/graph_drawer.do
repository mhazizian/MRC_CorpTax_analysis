
frame change default
graph drop _all


frame copy default graph_frame, replace
frame change graph_frame
	keep if actyear == $year

frame copy graph_frame graph_frame_e, replace
frame copy graph_frame graph_frame_g, replace

frame change graph_frame_e
	drop if missing(tax_ebrazi)
	drop if profit_ebrazi < 0

frame change graph_frame_g
// 	drop if is_not_audited == 1
	drop if profit_ghati_cal == 0
	drop if profit_ghati_cal < 0



frame change graph_frame

// 	niceloglabels avg_profit_percentile , local(yla) style(1) powers
// 	line avg_profit_percentile percentile , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_$year.png, as(png) replace
//		
//		
// 	niceloglabels avg_profit_g_percentile , local(yla) style(1) powers
// 	line avg_profit_g_percentile percentile_g , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_g_$year.png, as(png) replace
	
	niceloglabels avg_profit_g_percentile if !missing(percentile_g), local(yla) style(1) powers
	twoway ///		
		( line avg_profit_g_percentile percentile_g	, sort ) ///
		( line avg_profit_percentile   percentile_g		, sort ), ///
		legend(order(1 "سود محاسبه شده" 2 "سود ابرازی") pos(6) rows(1)) ///
		yscale(log) yla(`yla', ang(h)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
		title(متوسط سود ویژه ابرازی صدک‌ها -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export C00_$year.png, as(png) replace	

	
	twoway ///		
		( line avg_etr_ghati_percentile  percentile_g	, sort ) ///
		( line avg_etr_ebrazi_percentile percentile_g	, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط نرخ مالیات موثر شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export C01_$year.png, as(png) replace
	
	
	twoway ///		
		( line low_rate_percent_ghati_s percentile_g	, sort ) ///
		( line low_rate_percent_ebrazi  percentile_g		, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۵ درصد در صدک‌ها -‍ $year‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۵ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
	graph export C03_$year.png, as(png) replace
	

	twoway ///		
		( line zero_rate_percent_ghati_s percentile_g	, sort ) ///
		( line zero_rate_percent_ebrazi  percentile_g	, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ $year‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
	graph export C04_$year.png, as(png) replace
	
	// TODO: check whether to use _g or not.
	niceloglabels sum_lost_income_percentile if !missing(percentile_g), local(yla) style(1) powers
	line sum_lost_income_percentile percentile_g, ///
		sort ///
		yscale(log) yla(`yla', ang(h)) ///
		ytitle(درآمد از دست رفته دولت ابرازی) xtitle(صدک شرکت) ///
		title(درآمد از دست رفته دولت در صدک -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export LI1_$year.png, as(png) replace
	
	
	gsort -lost_income_ebrazi2
	gen idx = _n
	cumul idx [w=int(lost_income_ebrazi2)], gen(lost_income_cumul)
	gsort -lost_income_cumul
	line lost_income_cumul idx if idx < 500, name(LI0_$year) ///
		title(سال $year) ytitle(سهم از درآمد از دست رفته دولت) xtitle(تعداد شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export LI0_$year.png, as(png) replace
	

// ##############
frame change graph_frame_g
graph drop _all

	gen seg = .
	replace seg = 1 if percentile_g == 100
	replace seg = 2 if percentile_g <= 99
	replace seg = 3 if percentile_g < 90
	
	label define seg_label ///
		1 "صدک ۱۰۰ ام" ///
		2 "صدک ۹۰ تا ۹۹" ///
		3 "صدک ۱ تا ۹۰"
	label values seg seg_label
	
	graph pie, ///
		over(etr_tag) ///
		by(seg, rows(1) title("توزیع نرخ موثر قطعی شرکت در صدک های مختلف") note("")) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(white) gap(-12)) ///
		line(lcolor(black) lwidth(0.2)) ///
		graphregion(color(white)) ///
		legend(rows(1) symxsize(*1.5) size(*1.2) ring(0)) 
	graph export CG13_$year.png, as(png) replace
	


	sort percentile_g
	niceloglabels sum_profit_g_prct_high_rate if !missing(percentile_g), local(yla) style(1) powers
	twoway ///
		(area  sum_profit_g_prct_zero_rate 	percentile_g ) || ///
		(rarea sum_profit_g_prct_zero_rate 		sum_profit_g_prct_low_rate	 percentile_g) || ///
		(rarea sum_profit_g_prct_low_rate 		sum_profit_g_prct_middle_rate	 percentile_g) || ///
		(rarea sum_profit_g_prct_middle_rate 	sum_profit_g_prct_high_rate	 percentile_g) if percentile_g > 95, ///
		legend(order(4 "از ۲۰ تا ۲۵ درصد" 3 "از ۵ تا ۲۰ درصد" 2 "از ۱ تا ۵ درصد" 1 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از مجموع سود شرکت‌ها در هر صدک) xtitle(صدک شرکت) ///
		title(توزیع نرخ موثر مالیات قطعی شرکت در هر صدک -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG12_$year.png, as(png) replace
	
	twoway ///
		(area  zero_rate_percent_ghati_sw 	percentile_g ) || ///
		(rarea zero_rate_percent_ghati_sw 		low_rate_percent_ghati_sw		 percentile_g) || ///
		(rarea low_rate_percent_ghati_sw	 	middle_rate_percent_ghati_sw	 percentile_g) || ///
		(rarea middle_rate_percent_ghati_sw 	high_rate_percent_ghati_sw		 percentile_g), ///
		legend(order(4 "از ۲۰ تا ۲۵ درصد" 3 "از ۵ تا ۲۰ درصد" 2 "از ۱ تا ۵ درصد" 1 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از مجموع سود شرکت‌ها در هر صدک) xtitle(صدک شرکت) ///
		title(توزیع نرخ موثر مالیات قطعی شرکت در هر صدک -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) range(0 1)) yla(0 0.2 0.4 0.6 0.8 1)
	graph export CG11_$year.png, as(png) replace	

	twoway ///
		(area  zero_rate_percent_ghati_s 	percentile_g ) || ///
		(rarea zero_rate_percent_ghati_s 	low_rate_percent_ghati_s	 percentile_g) || ///
		(rarea low_rate_percent_ghati_s 	middle_rate_percent_ghati_s	 percentile_g) || ///
		(rarea middle_rate_percent_ghati_s 	high_rate_percent_ghati_s	 percentile_g), ///
		legend(order(4 "از ۲۰ تا ۲۵ درصد" 3 "از ۵ تا ۲۰ درصد" 2 "از ۱ تا ۵ درصد" 1 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از شرکت‌های هر صدک) xtitle(صدک شرکت) ///
		title(توزیع نرخ موثر مالیات قطعی شرکت در هر صدک -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) range(0 1)) yla(0 0.2 0.4 0.6 0.8 1)
	graph export CG10_$year.png, as(png) replace
	
	
	twoway ///
		(area  zero_rate_percent_ghati_s_p100 		p100_decile ) || ///
		(rarea zero_rate_percent_ghati_s_p100 		low_rate_percent_ghati_s_p100		 p100_decile) || ///
		(rarea low_rate_percent_ghati_s_p100 		middle_rate_percent_ghati_s_p100	 p100_decile) || ///
		(rarea middle_rate_percent_ghati_s_p100 	high_rate_percent_ghati_s_p100		 p100_decile), ///
		legend(order(4 "از ۲۰ تا ۲۵ درصد" 3 "از ۵ تا ۲۰ درصد" 2 "از ۱ تا ۵ درصد" 1 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از شرکت‌ها) xtitle(دهک در صدک ۱۰۰ ام) ///
		title(توزیع نرخ موثر مالیات قطعی شرکت در صدک ۱۰۰ ام-‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) range(0 1)) yla(0 0.2 0.4 0.6 0.8 1)
	graph export CG14_$year.png, as(png) replace




	
	
	
	
	
	
	line avg_etr_ghati_percentile percentile_g, sort name(CG09_$year) ///
		ytitle(متوسط نرخ مالیات قطعی شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
	graph export CG09_$year.png, as(png) replace
	
	twoway ///		
		( line zero_rate_percent_ghati percentile_g		, sort ) ///
		( line zero_rate_percent_ghati_s percentile_g	, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ $year‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG08_$year) 
	graph export CG08_$year.png, as(png) replace

	
// 	line zero_rate_percent_ghati percentile, sort name(CG8_$year) ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
// 		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
// 	graph export CG08_$year.png, as(png) replace
	
	twoway ///
		( hist etr_ghati2 	if percentile_g >= 20 & percentile_g <= 90, ///
			percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g >= 20 & percentile_g <= 90, ///
			percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(صدک ۲۰ تا ۹۰ - $year) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG07_$year.png, as(png) replace	
	
// 	hist etr_ghati2 if percentile < 20 & percentile < 90 & etr_ebrazi < 0.251, percent name(CG7_$year) ///
// 		bin(26) title(صدک ۲۰ تا ۹۰ - $year) ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG07_$year.png, as(png) replace


	
	twoway ///
		( hist etr_ghati2   if percentile_g <= 99	, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g <= 99	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی صدک ۱ تا ۹۹ - $year) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG06_$year) 
	graph export CG06_$year.png, as(png) replace
	
// 	hist etr_ghati2 if percentile <= 20 & etr_ebrazi < 0.251, percent name(CG6_$year) ///
// 		bin(26) title(صدک ۱ تا ۲۰ - $year) ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG06_$year.png, as(png) replace
	
	
	twoway ///
		( hist etr_ghati2   if percentile_g == 100	, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g == 100	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ $year) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG05_$year.png, as(png) replace
	
// 	hist etr_ghati2 if percentile == 100, percent name(CG5_$year) bin(26) ///
// 		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ $year) ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG05_$year.png, as(png) replace
	
	
	
// 	twoway ///
// 		( hist etr_ghati2   [fw=int(profit_ebrazi)]		, percent bin(26) color(red%30) ) || ///
// 		( hist etr_ghati_s2 [fw=int(profit_ghati_cal)]	, percent bin(26) color(green%60) barw(0.005) ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ $year) ///
// 		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG03_$year) 
// 	graph export CG03_$year.png, as(png) replace

	hist etr_ghati_s2 [fw=int(profit_ghati_cal)], percent bin(26) color(green%60) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ $year) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG03_$year, replace) 
	graph export CG03_$year.png, as(png) replace
	
	
	// 	hist etr_ghati2 [w=int(profit_ebrazi)], percent name(CG3_$year) bin(26) ///
	// 		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
	// 		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ $year) color(cranberry) ///
	// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	// 	graph export CG03_$year.png, as(png) replace	
	
	
// 	cumul etr_ghati   [w=int(profit_ebrazi)] 	, gen(etr_ghati_cumul_w)
	cumul etr_ghati_s [w=int(profit_ghati_cal)] , gen(etr_ghati_cumul_w_s)
	
	line etr_ghati_cumul_w_s etr_ghati_s if etr_ghati_s <= 0.25, sort ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع تجمعی وزن‌دار نرخ مالیات موثر قطعی -‍ $year) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) r(0 1)) name(CG2_$year, replace) 
	graph export CG02_$year.png, as(png) replace
	
// 	twoway ///		
// 		( line etr_ghati_cumul_w etr_ghati if etr_ghati <= 0.25, sort ) ///
// 		( line etr_ghati_cumul_w_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
// 		title(توزیع تجمعی وزن‌دار نرخ مالیات موثر قطعی -‍ $year) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5) r(0 1)) name(CG2_$year) 
// 	graph export CG02_$year.png, as(png) replace		


	hist etr_ghati_s2, percent bin(26) color(green%60) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع نرخ مالیات موثر قطعی -‍ $year‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG01_$year.png, as(png) replace
	
	
// 	twoway ///
// 		( hist etr_ghati2  , percent bin(26) color(red%30) ) || ///
// 		( hist etr_ghati_s2, percent bin(26) color(green%60) barw(0.005) ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) ///
// 		title(توزیع نرخ مالیات موثر قطعی -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG01_$year.png, as(png) replace
	
	
// 	cumul etr_ghati, gen(etr_ghati_cumul)
	cumul etr_ghati_s, gen(etr_ghati_cumul_s)
	line etr_ghati_cumul_s etr_ghati_s if etr_ghati_s <= 0.25, sort ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(توزیع تجمعی نرخ مالیات موثر قطعی -‍ $year ) ///
		yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG0_$year )
	graph export CG00_$year.png, as(png) replace
	
	
// 	twoway ///		
// 		( line etr_ghati_cumul etr_ghati if etr_ghati <= 0.25, sort ) ///
// 		( line etr_ghati_cumul_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(توزیع تجمعی نرخ مالیات موثر قطعی -‍ $year ) ///
// 		yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG0_$year )
// 	graph export CG00_$year.png, as(png) replace		
	
	
	
	
	hist etr_ghati2 if top1000 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۱۰۰۰ شرکت پرسود -‍ $year ) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG081_$year.png, as(png) replace
	
	hist etr_ghati2 if top500 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۵۰۰ شرکت پرسود -‍ $year ) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG082_$year.png, as(png) replace
	
	hist etr_ghati_s2 if top200 == 1, percent bin(25) ///
		title(توزیع نرخ مالیات موثر قطعی ۲۰۰ شرکت پرسود -‍ $year ) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG083_$year.png, as(png) replace
	
//
//
//
//
//
//
//	
// ##############	


// frame change graph_frame_e
// // graph drop _all
//	
// 	line avg_etr_ebrazi_percentile percentile, sort name(CG12_$year) ///
// 		ytitle(متوسط نرخ مالیات ابرازی شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط نرخ موثر مالیاتی ابرازی در هر صدک -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
// 	graph export CE12_$year.png, as(png) replace
//	
//	
//	
// 	cumul etr_ebrazi, gen(etr_ebrazi_cumul)
// 	line etr_ebrazi_cumul etr_ebrazi if etr_ebrazi < 0.251, sort name(CE0_$year) ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
// 		title(توزیع تجمعی نرخ مالیات موثر ابرازی -‍ $year) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
// 	graph export CE00_$year.png, as(png) replace
//	
// 	hist etr_ebrazi2, percent name(CE1_$year) bin(26) ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) ///
// 		title(توزیع نرخ مالیات موثر ابرازی -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE01_$year.png, as(png) replace
//	
//	
// 	cumul etr_ebrazi [w=int(profit_ebrazi)] , gen(etr_ebrazi_cumul_w)
// 	line etr_ebrazi_cumul_w etr_ebrazi if etr_ebrazi < 0.251, sort name(CE2_$year) ///
// 		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
// 		xtitle(نرخ موثر مالیات ابرازی) title(توزیع تجمعی وزن‌دار نرخ مالیات موثر ابرازی -‍ $year) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
// 	graph export CE02_$year.png, as(png) replace	
//	
//	
// 	hist etr_ebrazi2 [w=int(profit_ebrazi)], percent name(CE3_$year) bin(26) ///
// 		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
// 		xtitle(نرخ موثر مالیات ابرازی) title(توزیع نرخ مالیات موثر ابرازی بر اساس سود شرکت -‍ $year) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE03_$year.png, as(png) replace
//		
// 	hist etr_ebrazi2 if percentile == 100, percent name(CE5_$year) bin(26) ///
// 		title(توزیع نرخ مالیات موثر ابرازی صدک شرکت پرسود -‍ $year) ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE05_$year.png, as(png) replace
//	
// 	hist etr_ebrazi2 if percentile <= 20 & etr_ebrazi < 0.251, percent bin(26) name(CE6_$year) ///
// 		title(صدک ۱ تا ۲۰ - $year) ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE06_$year.png, as(png) replace
//	
// 	hist etr_ebrazi2 if percentile < 20 & percentile < 90 & etr_ebrazi < 0.251, percent name(CE7_$year) ///
// 		bin(26) title(صدک ۲۰ تا ۹۰ - $year) ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE07_$year.png, as(png) replace
//	
// 	line zero_rate_percent_ebrazi percentile if actyear == $year, sort name(CE8_$year) ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
// 		title(توزیع شرکت‌های با نرخ موثر ابرازی کمتر از ۱ درصد در صدک‌ها -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
// 	graph export CE08_$year.png, as(png) replace
//	
// 	hist etr_ebrazi2 if top1000 == 1, percent bin(26) ///
// 		title(توزیع نرخ مالیات موثر ابرازی ۱۰۰۰ شرکت پرسود -‍ $year) ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE09_$year.png, as(png) replace
//	
// 	hist etr_ebrazi2 if top500 == 1, percent bin(26) ///
// 		title(توزیع نرخ مالیات موثر ابرازی ۵۰۰ شرکت پرسود -‍ $year) ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE10_$year.png, as(png) replace
//	
// 	hist etr_ebrazi2 if top200 == 1, percent bin(26) ///
// 		title(توزیع نرخ مالیات موثر ابرازی ۲۰۰ شرکت پرسود -‍ $year) ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CE11_$year.png, as(png) replace
	

//
//
//
//
//
//
//
//
	
frame change default

frame drop graph_frame
frame drop graph_frame_e
frame drop graph_frame_g
