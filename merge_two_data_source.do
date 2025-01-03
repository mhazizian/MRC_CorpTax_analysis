clear


local dir2 "~\Documents\Majlis RC\data\tax_return\sharif"
use "`dir2'\Mohasebe_Maliat.dta"

gsort -T26_R01 
egen flag = tag(id actyear)
drop if flag == 0
drop flag

merge 1:1 id actyear using "`dir2'\Sanim.dta"
drop if _merge == 1
drop if _merge == 2
drop _merge


drop if missing(actyear)
drop if missing(T26_R01) & missing(T26_R25) & missing(T26_R23)
drop if missing(T26_R01)
drop if T26_R01 <= 0
drop if missing(T26_R25) & missing(T26_R23)
drop if missing(maliyat_ghati) & missing(maliyat_tashkhis)



gsort -T26_R01

duplicates drop actyear T26_R01 T26_R02 T26_R03 ///
	T26_R04 T26_R05 T26_R07 T26_R08 T26_R09 ///
	T26_R10 T26_R11 T26_R12 T26_R13 T26_R14 ///
	T26_R15 T26_R16 T26_R19 T26_R21 ///
	T26_R23 T26_R25 //, gen(flag1)



rename id id_shr
rename T26_001 T26_001_S

frame create MRC_data
frame change MRC_data

	clear

	// local dir "D:\Data_Output\Hoghooghi"
	local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"

	use "`dir'\Mohasebe_Maliat.dta", clear
	drop if missing(actyear)

	gsort -T26_R01 
	egen flag = tag(id actyear)
	duplicates drop id actyear flag, force
	drop if flag == 0
	drop flag
	
	drop if missing(T26_R01)
	drop if T26_R01 <= 0
	drop if missing(T26_R25) & missing(T26_R23)
	
	duplicates tag actyear T26_R01 T26_R02 T26_R03 ///
		T26_R04 T26_R05 T26_R07 T26_R08 T26_R09 ///
		T26_R10 T26_R11 T26_R12 T26_R13 T26_R14 ///
		T26_R15 T26_R16 T26_R19 T26_R21 ///
		T26_R23 T26_R25, gen(flag)

frame change default


// local dir "D:\Data_Output\Hoghooghi"
local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"

merge 1:1  actyear T26_R01 T26_R02 T26_R03 ///
	T26_R04 T26_R05 T26_R07 T26_R08 T26_R09 ///
	T26_R10 T26_R11 T26_R12 T26_R13 T26_R14 ///
	T26_R15 T26_R16 T26_R19 T26_R21 ///
	T26_R23 T26_R25 ///
	using "`dir'\Mohasebe_Maliat.dta"


