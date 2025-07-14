
// This code is suited only for Moafiat Table.


duplicates drop

gsort -Exempted_Profit
egen flag = tag( id actyear exemption_description exemption_id Exempted_Profit ///
		Exempted_Revenue Exempted_Cost Exempted_joint_Cost )
duplicates drop id actyear exemption_description exemption_id Exempted_Profit ///
		Exempted_Revenue Exempted_Cost Exempted_joint_Cost flag ///
		, force
drop if flag == 0
drop flag
