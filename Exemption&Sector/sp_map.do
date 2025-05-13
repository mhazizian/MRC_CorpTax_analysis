// ssc install spmap
// ssc install shp2dta
// ssc install mif2dta

frame change default
graph drop _all

graph set svg fontface "B Nazanin"
graph set window fontface "B Nazanin"

frame copy default sp_frame, replace
frame change sp_frame



// #######################################################################

	drop if missing(etr_ghati_s)
	gen count = 1
	
	gen p100_count = 0
	replace p100_count = 1 if percentile_g == 100
	
	gen zrate_count = 0
	replace zrate_count = 1 if etr_ghati_s <= 0.01
	
	gen p100_zrate_count = 0
	replace p100_zrate_count = 1 if etr_ghati_s <= 0.01
	
	
	collapse (sum) lost_income_ebrazi2  tax_ghati profit_ghati_cal ///
		count p100_count zrate_count p100_zrate_count, by(province_id)
	
	replace lost_income_ebrazi2 = lost_income_ebrazi2 / 1000 / 1000 / 1000 / 10
	gen weighted_etr = tax_ghati / profit_ghati_cal
	gen zero_rate_percent = zrate_count / count * 100
	
// 	clmethod(eqint) eirange(${min} ${max}) ///
	
	spmap count ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(quantile) ///
		title(توزیع جغرافیایی شرکت‌ها - سال $year, size(large)) ///
		legtitle(تعداد شرکت‌های فعال) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(GnBu) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP01_$year, replace)
	graph export "$out_dir/SP01_$year.png", as(png) replace
	

	
	spmap p100_count ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(quantile) ///
		title(توزیع جغرافیایی شرکت‌های پرسود- سال $year, size(large)) ///
		legtitle(تعداد شرکت‌های پرسود) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(GnBu) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP02_$year, replace)
	graph export "$out_dir/SP02_$year.png", as(png) replace
	
	
	spmap zrate_count ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(quantile) ///
		title(توزیع جغرافیایی شرکت‌های معاف - سال $year, size(large)) ///
		legtitle(تعداد شرکت‌های معاف) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(GnBu) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP03_$year, replace)
	graph export "$out_dir/SP03_$year.png", as(png) replace
	

	format zero_rate_percent %2.0f
	spmap zero_rate_percent ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(eqint) ///
		title(توزیع جغرافیایی شرکت‌های معاف - سال $year, size(large)) ///
		legtitle(درصد شرکت‌های معاف) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(GnBu) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP031_$year, replace)
	graph export "$out_dir/SP031_$year.png", as(png) replace
		
	
	spmap p100_zrate_count ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(quantile) ///
		title(توزیع جغرافیایی شرکت‌های معاف و پرسود - سال $year, size(large)) ///
		legtitle(تعداد شرکت‌های معاف و پرسود) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(GnBu) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP04_$year, replace)
	graph export "$out_dir/SP04_$year.png", as(png) replace
	
	
	
	format weighted_etr %9.2f
	spmap weighted_etr ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(eqint) ///
		title(توزیع جغرافیایی نرخ موثر شرکت‌ها - سال $year, size(large)) ///
		legtitle(متوسط موزون نرخ موثر استان) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(Reds2) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP05_$year, replace)
	graph export "$out_dir/SP05_$year.png", as(png) replace
	
	
	
	format lost_income_ebrazi2 %12.0fc
	spmap lost_income_ebrazi2 ///
	using $geo_dir/ircoord_province, id(province_id) ///
		clnumber(9) ///
		clmethod(quantile) ///
		title(توزیع جغرافیایی مخارج مالیاتی شرکت‌ها - سال $year, size(large)) ///
		legtitle(میلیارد تومان) ///
			legend(region(lcolor(black)) position(7)) ///
			legstyle(2) ///
		graphregion(icolor()) ///
		graphregion(margin(t=3)) ///
		fcolor(Reds2) ///
			ocolor(gray) ///
			ndfcolor(navy) ///
		ndsize(thin) ///
		polygon (data("$geo_dir/basemap.dta") ///
			ocolor(navy) ///
			osize(thin) ///
		) ///
	name(SP06_$year, replace)
	graph export "$out_dir/SP06_$year.png", as(png) replace
	
	

frame change default
frame drop sp_frame

