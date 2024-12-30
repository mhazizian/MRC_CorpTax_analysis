clear
graph set window fontface "B Nazanin"
graph drop _all

// ssc install egenmore
// ssc inst _gwtmean, replace
// net install cleanplots, from("https://tdmize.github.io/data/cleanplots") replace
set scheme cleanplots, perm
// set scheme s2color, perm


// local dir "D:\Data_Output\Hoghooghi"
local dir "~\Documents\Majlis RC\data\tax_return\Hoghooghi"
// local dir "~\Documents\Majlis RC\data\tax_return\sharif"


use "`dir'\Moafiat.dta", clear

drop if missing(actyear)

gen lost_income = Exempted_Profit * 0.25
tabstat lost_income , s(sum) by(actyear)



// #############################################3


use "`dir'\Bakhshhodegi.dta", clear
tabstat Rebate_Amount , s(sum) by(actyear)
