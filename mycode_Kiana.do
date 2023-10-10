*loading data
cd "/Users/kiana/Desktop/Applied econometrics/projet"
use "pdata2.dta",clear 

*descriptive statistics
describe
sum

*tabulate prevelance of missing values
mdesc

*replacing missing values with 0


replace GR = 0 if GR==.
replace CR = 0 if  CR==.
replace OR = 0 if  OR==.
*replace RE=RE*0.000001

*calculating missing values again for double check
mdesc

*summarizing
summarize RE EI OR CR GR CI 

*calculating correlation
pwcorr RE EI OR CR GR CI , star(0.05)

*converting variables to logarithm

generate lnre  = ln(RE) 
generate lngr = ln(GR) 
generate lnci  = ln(CI) 
generate lncr = ln(CR) 
generate lnor = ln(OR) 
generate lnei = ln(EI) 

**Panel Data

*converting countries to numeric forms

egen Countryn = group(Country) 

*preparing panel data
xtset Countryn year

*plotting dependent variable RE vs. year
xtline RE, overlay title(Countries Renewable Energy Consumption)


*RE across countries
bysort Countryn: egen Mean_RE=mean(RE)
twoway scatter Mean_RE Countryn, msymbol(diamond) , xlabel(1 "Congo" 2 " Egypt " 3 "Etiopia" 4 "Nigeria" 5 "South Africa" )


*RE across years
bysort year: egen Mean_RE_2 = mean(RE)
twoway scatter Mean_RE_2 year, msymbol(square) , xlabel(1990(1)2015)

*IMS test for unit root
*H0: the panels have unit roots
xtunitroot ips lnci , trend demean lags(0)
xtunitroot ips lnor , trend demean lags(0)
xtunitroot ips lngr , trend demean lags(0)
xtunitroot ips lnre , trend demean lags(0)
xtunitroot ips lnei , trend demean lags(0)
*xtunitroot ips lncr , trend demean lags(0)

*xtcointtest tests for the presence of this long-run cointegration relationship (Pedroni)
xtcointtest pedroni lnre lnei lnor lncr lngr lnci
*xtcointtest pedroni lnei lncr lnci


**Replicating the paper:

*Pooled OLS  
regress lnre lnei lnor lncr lngr lnci 

*describe the panel data
xtdes 
xtsum lnre


*between estimator
xtreg lnre lnei lnor lncr lngr lnci, be 


*random effects estimator

xtreg lnre lnei lnor lncr lngr lnci, re
estimates store random_effect


*fixed effect estimator
xtreg lnre  lnei lnor lncr lngr lnci, fe 
estimates store fixed_effect


*Hausman test
*hausman random_effect fixed_effect
hausman random_effect fixed_effect, sigmamore
*hausman random_effect fixed_effect, sigmaless
*xtoverid
