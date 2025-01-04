
frame change default
local year 1400
graph drop _all


frame copy default graph_frame, replace
frame change graph_frame
	keep if actyear == `year'

frame copy graph_frame graph_frame_e, replace
frame copy graph_frame graph_frame_g, replace

frame change graph_frame_e
	drop if missing(tax_ebrazi)

frame change graph_frame_g
	drop if is_not_audited == 1
// 	drop if profit_ghati_cal == 0



frame change graph_frame

// 	niceloglabels avg_profit_percentile , local(yla) style(1) powers
// 	line avg_profit_percentile percentile , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_`year'.png, as(png) replace
//		
//		
// 	niceloglabels avg_profit_g_percentile , local(yla) style(1) powers
// 	line avg_profit_g_percentile percentile_g , ///
// 		sort yscale(log) yla(`yla', ang(h)) ///
// 		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
// 		title(متوسط سود ویژه ابرازی صدک‌ها -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export decile_profit_g_`year'.png, as(png) replace
	
	niceloglabels avg_profit_percentile , local(yla) style(1) powers
	twoway ///		
		( line avg_profit_g_percentile percentile_g	, sort ) ///
		( line avg_profit_percentile percentile		, sort ), ///
		legend(order(1 "سود محاسبه شده" 2 "سود ابرازی") pos(6) rows(1)) ///
		yscale(log) yla(`yla', ang(h)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط سود ویژه شرکت) xtitle(صدک شرکت) ///
		title(متوسط سود ویژه ابرازی صدک‌ها -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export C00_`year'.png, as(png) replace	

	
	twoway ///		
		( line avg_etr_ghati_percentile  percentile_g	, sort ) ///
		( line avg_etr_ebrazi_percentile percentile	, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(متوسط نرخ مالیات موثر شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export C01_`year'.png, as(png) replace
	
	
	twoway ///		
		( line low_rate_percent_ghati_s percentile_g	, sort ) ///
		( line low_rate_percent_ebrazi percentile		, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۵ درصد در صدک‌ها -‍ `year'‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۵ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
	graph export C03_`year'.png, as(png) replace
	

	twoway ///		
		( line zero_rate_percent_ghati_s percentile_	, sort ) ///
		( line zero_rate_percent_ebrazi  percentile		, sort ), ///
		legend(order(1 "نرخ موثر قطعی" 2 "نرخ موثر ابرازی") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) 
	graph export C04_`year'.png, as(png) replace
	
	
// ##############	
frame change graph_frame_e
// graph drop _all
	
	tab actyear
	
	line avg_etr_ebrazi_percentile percentile, sort name(CG12_`year') ///
		ytitle(متوسط نرخ مالیات ابرازی شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی ابرازی در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
	graph export CE12_`year'.png, as(png) replace
	
	
	
	cumul etr_ebrazi, gen(etr_ebrazi_cumul)
	line etr_ebrazi_cumul etr_ebrazi if etr_ebrazi < 0.251, sort name(CE0_`year') ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات ابرازی) ///
		title(توزیع تجمعی نرخ مالیات موثر ابرازی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
	graph export CE00_`year'.png, as(png) replace
	
	hist etr_ebrazi2, percent name(CE1_`year') bin(26) ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات ابرازی) ///
		title(توزیع نرخ مالیات موثر ابرازی -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE01_`year'.png, as(png) replace
	
	
	cumul etr_ebrazi [w=int(profit_ebrazi)] , gen(etr_ebrazi_cumul_w)
	line etr_ebrazi_cumul_w etr_ebrazi if etr_ebrazi < 0.251, sort name(CE2_`year') ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
		xtitle(نرخ موثر مالیات ابرازی) title(توزیع تجمعی وزن‌دار نرخ مالیات موثر ابرازی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
	graph export CE02_`year'.png, as(png) replace	
	
	
	hist etr_ebrazi2 [w=int(profit_ebrazi)], percent name(CE3_`year') bin(26) ///
		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) ///
		xtitle(نرخ موثر مالیات ابرازی) title(توزیع نرخ مالیات موثر ابرازی بر اساس سود شرکت -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE03_`year'.png, as(png) replace
		
	hist etr_ebrazi2 if percentile == 100, percent name(CE5_`year') bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی صدک شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE05_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if percentile <= 20 & etr_ebrazi < 0.251, percent bin(26) name(CE6_`year') ///
		title(صدک ۱ تا ۲۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE06_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if percentile < 20 & percentile < 90 & etr_ebrazi < 0.251, percent name(CE7_`year') ///
		bin(26) title(صدک ۲۰ تا ۹۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE07_`year'.png, as(png) replace
	
	line zero_rate_percent_ebrazi percentile if actyear == `year', sort name(CE8_`year') ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		title(توزیع شرکت‌های با نرخ موثر ابرازی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(blue)
	graph export CE08_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if top1000 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی ۱۰۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE09_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if top500 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی ۵۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE10_`year'.png, as(png) replace
	
	hist etr_ebrazi2 if top200 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر ابرازی ۲۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات ابرازی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CE11_`year'.png, as(png) replace
	

	
// ##############
frame change graph_frame_g
graph drop _all

	
	tab actyear
	
	
	line avg_etr_ghati_percentile percentile_g, sort name(CG09_`year') ///
		ytitle(متوسط نرخ مالیات قطعی شرکت) xtitle(صدک شرکت) ///
		title(متوسط نرخ موثر مالیاتی قطعی در هر صدک -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
	graph export CG09_`year'.png, as(png) replace
	
	twoway ///		
		( line zero_rate_percent_ghati percentile_g		, sort ) ///
		( line zero_rate_percent_ghati_s percentile_g	, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG08_`year') 
	graph export CG08_`year'.png, as(png) replace

	
// 	line zero_rate_percent_ghati percentile, sort name(CG8_`year') ///
// 		ytitle(درصد شرکت با نرخ موثر کمتر از ۱ درصد) xtitle(صدک شرکت) ///
// 		title(توزیع شرکت‌های با نرخ موثر قطعی کمتر از ۱ درصد در صدک‌ها -‍ `year'‍‍) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5)) color(cranberry)
// 	graph export CG08_`year'.png, as(png) replace
	
	twoway ///
		( hist etr_ghati2 	if percentile_g >= 20 & percentile_g <= 90, ///
			percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g >= 20 & percentile_g <= 90, ///
			percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(صدک ۲۰ تا ۹۰ - `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG07_`year'.png, as(png) replace	
	
// 	hist etr_ghati2 if percentile < 20 & percentile < 90 & etr_ebrazi < 0.251, percent name(CG7_`year') ///
// 		bin(26) title(صدک ۲۰ تا ۹۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG07_`year'.png, as(png) replace


	
	twoway ///
		( hist etr_ghati2   if percentile_g <= 99	, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g <= 99	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی صدک ۱ تا ۹۹ - `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG06_`year') 
	graph export CG06_`year'.png, as(png) replace
	
// 	hist etr_ghati2 if percentile <= 20 & etr_ebrazi < 0.251, percent name(CG6_`year') ///
// 		bin(26) title(صدک ۱ تا ۲۰ - `year') ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG06_`year'.png, as(png) replace
	
	
	twoway ///
		( hist etr_ghati2   if percentile_g == 100	, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 if percentile_g == 100	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG05_`year'.png, as(png) replace
	
// 	hist etr_ghati2 if percentile == 100, percent name(CG5_`year') bin(26) ///
// 		title(توزیع نرخ مالیات موثر قطعی صدک شرکت پرسود -‍ `year') ///
// 		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
// 	graph export CG05_`year'.png, as(png) replace
	
	
	
	twoway ///
		( hist etr_ghati2   [fw=int(profit_ebrazi)]		, percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2 [fw=int(profit_ghati_cal)]	, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ `year') ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG03_`year') 
	graph export CG03_`year'.png, as(png) replace
	
	// 	hist etr_ghati2 [w=int(profit_ebrazi)], percent name(CG3_`year') bin(26) ///
	// 		ylab(, grid) xlab(, grid) ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
	// 		title(توزیع نرخ مالیات موثر قطعی بر اساس سود شرکت -‍ `year') color(cranberry) ///
	// 		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	// 	graph export CG03_`year'.png, as(png) replace	
	
	
	cumul etr_ghati   [w=int(profit_ebrazi)] 	, gen(etr_ghati_cumul_w)
	cumul etr_ghati_s [w=int(profit_ghati_cal)] , gen(etr_ghati_cumul_w_s)
	twoway ///		
		( line etr_ghati_cumul_w etr_ghati if etr_ghati <= 0.25, sort ) ///
		( line etr_ghati_cumul_w_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از مجموع سود قبل از مالیات شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع تجمعی وزن‌دار نرخ مالیات موثر قطعی -‍ `year') ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5) r(0 1)) name(CG2_`year') 
	graph export CG02_`year'.png, as(png) replace		
	
	twoway ///
		( hist etr_ghati2  , percent bin(26) color(red%30) ) || ///
		( hist etr_ghati_s2, percent bin(26) color(green%60) barw(0.005) ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها (درصد)) xtitle(نرخ موثر مالیات قطعی) ///
		title(توزیع نرخ مالیات موثر قطعی -‍ `year'‍‍) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG01_`year'.png, as(png) replace
	
	
	cumul etr_ghati, gen(etr_ghati_cumul)
	cumul etr_ghati_s, gen(etr_ghati_cumul_s)
	twoway ///		
		( line etr_ghati_cumul etr_ghati if etr_ghati <= 0.25, sort ) ///
		( line etr_ghati_cumul_s etr_ghati_s if etr_ghati_s <= 0.25, sort ), ///
		legend(order(1 "سقف بالای نرخ موثر" 2 "سقف پایین نرخ موثر") pos(6) rows(1)) ///
		ylab(, grid) xlab(, grid) ///
		ytitle(سهم از تعداد شرکت‌ها) xtitle(نرخ موثر مالیات قطعی) title(توزیع تجمعی نرخ مالیات موثر قطعی -‍ `year') ///
		yscale(r(0 1)) ylabel(0 0.2 0.4 0.6 0.8 1) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5)) name(CG0_`year')
	graph export CG00_`year'.png, as(png) replace		
	
	hist etr_ghati2 if top1000 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۱۰۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG09_`year'.png, as(png) replace
	
	hist etr_ghati2 if top500 == 1, percent bin(26) ///
		title(توزیع نرخ مالیات موثر قطعی ۵۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG10_`year'.png, as(png) replace
	
	hist etr_ghati_s2 if top200 == 1, percent bin(25) ///
		title(توزیع نرخ مالیات موثر قطعی ۲۰۰ شرکت پرسود -‍ `year') ///
		ytitle(درصد) xtitle(نرخ موثر مالیات قطعی) color(cranberry) ///
		xscale(titlegap(2.5)) yscale(titlegap(1.5))
	graph export CG11_`year'.png, as(png) replace
	
frame change default
