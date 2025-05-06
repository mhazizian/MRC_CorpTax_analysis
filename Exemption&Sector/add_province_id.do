

// ##########################  Add province ID:

rename T00_PostalCode postal_code
replace postal_code = T00_WorkPlacePostCode1  if missing(postal_code)
	
do "$geo_dir/postal_code_to_geo_id.do"

// manual fix!!
replace province_id = 7  if missing(province_id) & T00_EdareCode  == 55
replace province_id = 1  if missing(province_id) & T00_EdareCode  == 49
replace province_id = 15 if missing(province_id) & T00_EdareCode  == 16
replace province_id = 29 if missing(province_id) & T00_EdareCode  == 14

replace province_id = 28 if missing(province_id) & T00_EdareCode  == 52
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 34
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 46
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 35
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 40
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 36
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 32
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 51
replace province_id = 28 if missing(province_id) & T00_EdareCode  == 53

replace province_id = 5  if missing(province_id) & T00_EdareCode  == 13
replace province_id = 24 if missing(province_id) & T00_EdareCode  == 19
replace province_id = 13 if missing(province_id) & T00_EdareCode  == 18
replace province_id = 3  if missing(province_id) & T00_EdareCode  == 88
