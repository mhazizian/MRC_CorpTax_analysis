frame change default
graph drop _all

graph set svg fontface "B Nazanin"


frame copy default graph_frame, replace
frame change graph_frame
	keep if actyear == $year

frame copy graph_frame graph_frame_e, replace
frame copy graph_frame graph_frame_g, replace

frame change graph_frame_e
	drop if missing(tax_ebrazi)
	drop if profit_ebrazi < 0
	drop if profit_ebrazi == 0

frame change graph_frame_g
// 	drop if is_not_audited == 1
	drop if profit_ghati_cal == 0
	drop if profit_ghati_cal < 0
	
	sort percentile_g p100_decile
	
	replace zero_rate_percent_ghati_s = zero_rate_percent_ghati_s * 100
	replace low_rate_percent_ghati_s = low_rate_percent_ghati_s * 100
	replace middle_rate_percent_ghati_s = middle_rate_percent_ghati_s * 100
	replace high_rate_percent_ghati_s = high_rate_percent_ghati_s * 100



frame change graph_frame

	twoway ///		
		( line avg_etr_ghati_percentile  percentile_g	, sort ) ///
		( line avg_etr_ebrazi_percentile percentile_g	, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط نرخ مالیات موثر شرکت, size(medium)) ///
		xtitle(صدک شرکت, size(medium)) ///
		title(متوسط نرخ موثر مالیات در هر صدک -‍ سال $year, size(large)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
		name(C01_$year, replace)
	graph export "./out/C01_$year.png", as(png) replace
	
		
	niceloglabels sum_lost_income_percentile if !missing(percentile_g), local(yla) style(1) powers
	line sum_lost_income_percentile percentile_g, sort ///
		yscale(log) yla(`yla', ang(h)) ///
		ytitle(درآمد از دست رفته دولت از محل مشوق‌های مالیاتی, size(medium)) ///
		xtitle(صدک شرکت, size(medium)) ///
		title(مخارج مالیاتی دولت در هر صدک-‍ سال $year‍‍, size(large)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) ///
		name(LI1_$year, replace)
	graph export "./out/LI1_$year.png", as(png) replace

	
	gsort -lost_income_ebrazi2
	gen idx = _n
	cumul idx [w=int(lost_income_ebrazi2)], gen(lost_income_cumul)
	replace lost_income_cumul = lost_income_cumul * 100
	gsort -lost_income_cumul
	line lost_income_cumul idx if idx < 500, name(LI0_$year, replace) ///
		title(سهم تجمعی شرکت‌های بزرگ از مخارج مالیاتی کشور - سال $year, size(large)) ///
		ytitle(درصد از درآمد از دست رفته دولت, size(medium)) ///
		xtitle(تعداد شرکت, size(medium)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export "./out/LI0_$year.png", as(png) replace

// 	niceloglabels avg_profit_percentile , local(yla) style(1) powers
// 	line avg_profit_percentile percentile , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_$year.png, as(png) replace

	
// 	niceloglabels avg_profit_g_percentile , local(yla) style(1) powers
// 	line avg_profit_g_percentile percentile_g , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_g_$year.png, as(png) replace
	
	
	niceloglabels avg_profit_g_percentile if !missing(percentile_g), local(yla) style(1) powers
	twoway ///		
		( line avg_profit_g_percentile percentile_g if !missing(percentile_g), sort ) ///
		( line avg_profit_percentile   percentile_g	if !missing(percentile_g), sort ), ///
		legend(order(1 "سود محاسبه شده" 2 "سود ابرازی") pos(6) rows(1)) ///
		yscale(log) yla(`yla', ang(h)) ///
		ylab(, grid) xlab(, grid) ///
		title(متوسط سود ویژه ابرازی صدک‌ها -‍ سال $year, size(large‍‍)) ///
		ytitle(متوسط سود ویژه شرکت, size(medium)) ///
		xtitle(صدک شرکت, size(medium)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export "./out/C00_$year.png", as(png) replace	

	
	niceloglabels avg_profit_g_percentile if !missing(percentile_g), local(yla) style(1) powers
	line avg_profit_g_percentile percentile_g if !missing(percentile_g), sort  ///
		legend(order(1 "سود محاسبه شده" 2 "سود ابرازی") pos(6) rows(1)) ///
		yscale(log) yla(`yla', ang(h)) ///
		ylab(, grid) xlab(, grid) ///
		title(متوسط سود قبل از مالیات ابرازی صدک‌ها -‍ سال $year, size(large)) ///
		ytitle(متوسط سود ویژه شرکت, size(medium)) ///
		xtitle(صدک شرکت, size(medium)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export "./out/C001_$year.png", as(png) replace	

	
	
// 	twoway ///		
// 		( line low_rate_percent_ghati_s percentile_g	, sort ) ///
// 		( line low_rate_percent_ebrazi  percentile_g		, sort ), ///
// 		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۵ درصد در صدک‌ها -‍ $year‍‍) ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۵ درصد) xtitle(صدک شرکت) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
// 	graph export C03_$year.png, as(png) replace
	

// 	twoway ///		
// 		( line zero_rate_percent_ghati_s percentile_g	, sort ) ///
// 		( line zero_rate_percent_ebrazi  percentile_g	, sort ), ///
// 		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ $year‍‍) ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
// 	graph export C04_$year.png, as(png) replace
	
	
	

	

// ##############

// 		pie(4, color(dkgreen)) ///
// 		pie(1, color(cranberry)) ///
// 		pie(2, color(dknavy)) ///
// 		pie(3, color(teal)) 
		
// 		pie(4, color(102 194 165)) ///
// 		pie(1, color(252 141 98)) ///
// 		pie(3, color(166 216 84)) ///
// 		pie(2, color(255 217 47))	


frame change graph_frame_g

	gen seg = .
	replace seg = 3 if percentile_g == 100
	replace seg = 2 if percentile_g <= 99
	replace seg = 1 if percentile_g <= 90
	
	label define seg_label ///
		3 "صدک ۱۰۰ ام" ///
		2 "صدک ۹۱ تا ۹۹" ///
		1 "صدک ۱ تا ۹۰"
	label values seg seg_label

	graph pie, ///
		over(etr_tag) ///
		by(seg, rows(1) ///
			title("توزیع نرخ موثر قطعی شرکت در صدک های مختلف - سال$year", size(large)) note("")) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-12)) ///
		line(lcolor(black) lwidth(0.2)) ///
		graphregion(color(white)) ///
		legend(rows(1) symxsize(*1.5) size(*1.2) ring(0)) ///
		pie(1, explode color(236 107 86)) ///
		pie(2, color(255 193 84)) ///
		pie(3, color(30  144 225)) ///
		pie(4, color(71  179 156)) ///
		name(CG13_$year, replace)
	graph export "./out/CG13_$year.png", as(png) replace

	
	*********************
	
	gen is_p100 = .
	replace is_p100 = (percentile_g == 100)
// 	replace is_p100 = 2 if (top200 == 1)
	
	label define isp100_label ///
		1 "صدک ۱۰۰" ///
		0 "صدک ۱ تا ۹۹"
	label values is_p100 isp100_label
	
	graph pie profit_ghati_cal, ///
		over(is_p100) ///
		title(مجموع سود قبل از مالیات کت‌ها, size(large)) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-5)) ///
		plabel(_all name) ///
		line(lcolor(black) lwidth(0.2)) ///
		legend(off) ///
		pie(1, explode color(236 107 86)) ///
		pie(2, color(71  179 156)) ///
		name(CG14_$year, replace)
	graph export "./out/CG14_$year.png", as(png) replace
	
	graph pie tax_ghati, ///
		over(is_p100) ///
		title(مجموع مالیات قطعی شرکت, size(large)) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-5)) ///
		plabel(_all name) ///
		line(lcolor(black) lwidth(0.2)) ///
		legend(off) ///
		pie(1, explode color(236 107 86)) ///
		pie(2, color(71  179 156)) ///
		name(CG141_$year, replace)
	graph export "./out/CG141_$year.png", as(png) replace
	
	graph pie lost_income_ebrazi2, ///
		over(is_p100) ///
		title(مجموع مخارج مالیاتی دولت, size(large)) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-5)) ///
		plabel(_all name) ///
		line(lcolor(black) lwidth(0.2)) ///
		legend(off) ///
		pie(1, explode color(236 107 86)) ///
		pie(2, color(71  179 156)) ///
		name(CG15_$year, replace)
	graph export "./out/CG15_$year.png", as(png) replace
	
	graph combine CG14_$year CG141_$year CG15_$year, name(CG14_C_$year, replace) ///
		title(مقایسه صدک ۱۰۰ ام با سایر صدک‌ها - سال $year, size(large)) ///
		subtitle("   ") ///
		row(1)
	graph export "./out/CG14_C_$year.png", as(png) replace
	
	********************
	
	gen li_share = sum_lost_income_percentile / (sum_tax_g_percentile + sum_lost_income_percentile) * 100
	gen total_share = 100

	twoway ///
		(area  li_share 				percentile_g, color("236 107 86"))  || ///
		(rarea li_share total_share 	percentile_g, color("71  179 156")), ///
		legend(order(1 "درآمد از دست رفته دولت" 2 "مالیات قطعی") pos(6) row(1)) ///
		ylab(, grid) xlab(, grid) ///
		xtitle(صدک شرکت, size(medium)) ///
		title(مقایسه نسبت مجموع مالیات قطعی و مخارج مالیاتی در هر صدک -‍ سال $year‍‍, size(large)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) range(0 1))
	graph export "./out/CG15_A_$year.png", as(png) replace
	
	label variable tax_ghati "مالیات شرکت"
	label variable lost_income_ebrazi2 "درآمد از دست رفته از محل معافیت و بخشودگی‌ها"
	
	graph pie tax_ghati lost_income_ebrazi2, ///
		by(seg, rows(1) ///
			title("مقایسه نسبت مالیات و مخارج مالیاتی در صدک های مختلف - سال$year", size(large)) note("")) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-12)) ///
		line(lcolor(black) lwidth(0.2)) ///
		graphregion(color(white)) ///
		legend(rows(1) symxsize(*1.5) size(*1.2) ring(0)) ///
		pie(2, explode color(236 107 86)) ///
		pie(1, color(71  179 156)) ///
		name(CG15_P_$year, replace)
	graph export "./out/CG15_P_$year.png", as(png) replace
	
	*********************

	
	
	
	
	label define istop200_label ///
		1 "دویست  شرکت پر سود" ///
		0 "سایر شرکت‌ها"
	label values top200 istop200_label
	
	graph pie lost_income_ebrazi2, ///
		over(top200) ///
		title(توزیع مخارج مالیاتی دولت - سال $year, size(large)) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-5)) ///
		plabel(_all name) ///
		line(lcolor(black) lwidth(0.2)) ///
		legend(off) ///
		pie(1, explode color(236 107 86)) ///
		pie(2, color(71  179 156)) ///
		name(CG17_$year, replace)
	graph export "./out/CG17_$year.png", as(png) replace
	
	graph pie profit_ghati_cal, ///
		over(top200) ///
		title(توزیع مجموع سود ویژه محاسبه شده شرکت‌ها - سال $year, size(large)) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-5)) ///
		plabel(_all name) ///
		line(lcolor(black) lwidth(0.2)) ///
		legend(off) ///
		pie(1, explode color(236 107 86)) ///
		pie(2, color(71  179 156)) ///
		name(CG171_$year, replace)
	graph export "./out/CG171_$year.png", as(png) replace
	
	graph combine CG171_$year CG17_$year, name(CG17_C_$year, replace)
	graph export "./out/CG17_C_$year.png", as(png) replace
	
	
	gen istop200_inp100 = .
	replace istop200_inp100 = 0 if (percentile_g == 100)
	replace istop200_inp100 = 1 if (top200 == 1)
	
	label define istop200_inp100_label ///
		1 "دویست  شرکت پر سود" ///
		0 "سایر شرکت‌های صدک ۱۰۰ ام"
	label values istop200_inp100 istop200_inp100_label
	
	graph pie profit_ghati_cal, ///
		over(istop200_inp100) ///
		title(توزیع مجموع سود ویژه محاسبه شده شرکت‌ها, size(large)) ///
		subtitle(, alignment(middle)) ///
		plabel(_all percent, format(%2.0f) color(black) gap(-12)) ///
		line(lcolor(black) lwidth(0.2)) ///
		graphregion(color(white)) ///
		legend(rows(2) symxsize(*1.5) size(*1.2) ring(0)) ///
		pie(2, color(255 193 84)) ///
		pie(1, explode color(71  179 156)) ///
		name(CG16_$year, replace)
	graph export "./out/CG16_$year.png", as(png) replace


	
	
	
	twoway ///
		(area  zero_rate_percent_ghati_s 								  	 percentile_g, color("236 107 86"))  || ///
		(rarea zero_rate_percent_ghati_s 	low_rate_percent_ghati_s	 	 percentile_g, color("255 193 84"))  || ///
		(rarea low_rate_percent_ghati_s 	middle_rate_percent_ghati_s	 percentile_g, color("30  144 225")) || ///
		(rarea middle_rate_percent_ghati_s 	high_rate_percent_ghati_s	 percentile_g, color("71  179 156")), ///
		legend(order(4 "از ۲۰ تا ۲۵ درصد" 3 "از ۱۰ تا ۲۰ درصد" 2 "از ۱ تا ۱۰ درصد" 1 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(درصد از شرکت‌های هر صدک, size(medium)) ///
		xtitle(صدک شرکت, size(medium)) ///
		title(توزیع نرخ موثر مالیات قطعی شرکت در هر صدک -‍ سال $year‍‍, size(large)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) range(0 1))
	graph export "./out/CG10_$year.png", as(png) replace
	
	preserve
	keep avg_etr_ghati_percentile percentile_g
	duplicates drop
	graph twoway scatter avg_etr_ghati_percentile percentile_g, m(smplus) mc(gray) || lowess avg_etr_ghati_percentile percentile_g , sort bwidth(0.15) name(CG09_$year, replace) ///
		ytitle(متوسط نرخ مالیات قطعی شرکت, size(medium)) ///
		xtitle(صدک شرکت, size(medium)) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ سال $year‍‍, size(large)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry) ///
		legend(off)
	restore
	graph export "./out/CG09_$year.png", as(png) replace


	hist etr_ghati_s2 [fw=int(profit_ghati_cal)], percent bin(26) color(red%60) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ سال $year, size(large)) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها, size(medium)) ///
		xtitle(نرخ موثر مالیات قطعی, size(medium)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG03_$year, replace) 
	graph export "./out/CG03_$year.png", as(png) replace
	
	
	hist etr_ghati_s2, percent bin(26) color(green%60) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد), size(medium)) ///
		xtitle(نرخ موثر مالیات قطعی, size(medium)) ///
		title(توزیع نرخ مالیات موثر قطعی -‍ سال $year‍‍, size(large)) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG01_$year, replace)
	graph export "./out/CG01_$year.png", as(png) replace
	
	graph combine CG01_$year CG03_$year
	
	
	
	
	
		
	hist etr_ghati2 if top1000 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۱۰۰۰ شرکت پرسود -‍ $year ) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(green%60) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export "./out/CG081_$year.png", as(png) replace
	
	hist etr_ghati2 if top500 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۵۰۰ شرکت پرسود -‍ $year ) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(green%60) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export "./out/CG082_$year.png", as(png) replace
	
	hist etr_ghati_s2 if top200 == 1, percent bin(25) ///
		title(توزیع نرخ مالیات موثر قطعی ۲۰۰ شرکت پرسود -‍ $year ) ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(green%60) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export "./out/CG083_$year.png", as(png) replace
	
	
	
// 	twoway ///
// 		(bar sum_profit_g_p100_d_high_rate	 p100_decile, color("71  179 156")) || ///
// 		(bar sum_profit_g_p100_d_middle_rate	 p100_decile, color("30  144 225")) || ///
// 		(bar sum_profit_g_p100_d_low_rate	 	 p100_decile, color("255 193 84"))  || ///
// 		(bar sum_profit_g_p100_d_zero_rate 	 p100_decile, color("236 107 86")), ///
// 		legend(order(1 "از ۲۰ تا ۲۵ درصد" 2 "از ۱۰ تا ۲۰ درصد" 3 "از ۱ تا ۱۰ درصد" 4 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(درصد از مجموع سود شرکت‌ها در هر صدک) ///
// 		xtitle(دهک های صدک ۱۰۰ ام شرکت‌ها) ///
// 		title(توزیع نرخ موثر مالیات قطعی شرکت در هر صدک -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG12_$year.png, as(png) replace
	
	
	
// 	twoway ///
// 		(area  zero_rate_percent_ghati_sw 								  	 percentile_g, color("236 107 86"))  || ///
// 		(rarea zero_rate_percent_ghati_sw 	low_rate_percent_ghati_sw	 	 percentile_g, color("255 193 84"))  || ///
// 		(rarea low_rate_percent_ghati_sw 	middle_rate_percent_ghati_sw	 percentile_g, color("30  144 225")) || ///
// 		(rarea middle_rate_percent_ghati_sw 	high_rate_percent_ghati_sw	 percentile_g, color("71  179 156")), ///
// 		legend(order(4 "از ۲۰ تا ۲۵ درصد" 3 "از ۱۰ تا ۲۰ درصد" 2 "از ۱ تا ۱۰ درصد" 1 "از ۰ تا ۱ درصد") pos(6) row(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(درصد از مجموع سود شرکت‌ها در هر صدک) xtitle(صدک شرکت) ///
// 		title(توزیع نرخ موثر مالیات قطعی شرکت در هر صدک -‍ $year‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5) range(0 1))
// 	graph export CG11_$year.png, as(png) replace	

	
// 	twoway ///		
// 		( line zero_rate_percent_ghati percentile_g		, sort ) ///
// 		( line zero_rate_percent_ghati_s percentile_g	, sort ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ $year‍‍) ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG08_$year) 
// 	graph export CG08_$year.png, as(png) replace


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
	graph export "./out/CG07_$year.png", as(png) replace	
	
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
	graph export "./out/CG06_$year.png", as(png) replace
	
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
	graph export "./out/CG05_$year.png", as(png) replace
	
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
	graph export "./out/CG02_$year.png", as(png) replace
	
// 	twoway ///		
// 		( line etr_ghati_cumul_w etr_ghati if etr_ghati <= 0.25, sort ) ///
// 		( line etr_ghati_cumul_w_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
// 		title(توزیع تجمعی وزن‌دار نرخ مالیات موثر قطعی -‍ $year) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5) r(0 1)) name(CG2_$year) 
// 	graph export CG02_$year.png, as(png) replace		


	
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
	graph export "./out/CG00_$year.png", as(png) replace
	
	
// 	twoway ///		
// 		( line etr_ghati_cumul etr_ghati if etr_ghati <= 0.25, sort ) ///
// 		( line etr_ghati_cumul_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
// 		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
// 		ylab(, grid) xlab(, grid) ///
// 		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(توزیع تجمعی نرخ مالیات موثر قطعی -‍ $year ) ///
// 		yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG0_$year )
// 	graph export CG00_$year.png, as(png) replace		
	
	
	

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
