/*Exploratory Analysis*/
ods rtf file="/home/u47236280/Projects-Automobile/Project-Automobile2.rtf" startpage=no;
ods graphics/ reset=all imagemap;
proc corr data=auto.auto_mob_bin rank plots(only)= scatter(nvar=all ellipse=none);
var horse_power &interval;
with price;
run;
/* As we can see from the correlation matrix that only engine_size, curb_weight, horse_power, width, highway_mpg, length, city_mpg bore are the
variables that shows strong relationship with response variable price with engine_size being the strongest of all.
We further analyze the scatter plots for these variables adding a regression line to the plot as well.
*/

proc sgscatter data=auto.auto_mob_bin;
	plot price*(engine_size curb_weight width highway_mpg length city_mpg bore horse_power)/ reg;
run;

/*bore shows relatively weaker association compared to the rest but it is still showing a positive correlation to the response 
variable price, therefore we will keep it for now for model selection. City_mpg and highway_mpg shows a negative
correlation with the response variable price.*/

proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=body_style
				connect=mean;
run;
/*There is not much change in average price across different levels of body_style. Therefore, body_style 
can not be a good predictor*/

/*Checking distribution of price across different levels of categorical variables*/
proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=engine_location
				connect=mean;
run;

proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=drive_wheels
				connect=mean;
run;

proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=make
				connect=mean;
run;


proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=fuel_type
				connect=mean;
run;

proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=num_of_doors
				connect=mean;
run;


proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=aspiration
				connect=mean;
run;

proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=engine_type
				connect=mean;
run;


proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=num_of_cylinders
				connect=mean;
run;


proc sgplot data=auto.auto_mob_bin;
	vbox price/ category=fuel_system
				connect=mean;
run;

/*There is significant difference in the average price across two levels of engine location, drive wheels,
make, fuel type, aspiration, engine type, num of cylinders and fuel system therefore they can
be a potential categorical predictor in the model. There is not much difference in average price of two levels
of num of doors. Therefore, it might not be a good predictor of price. */

proc freq data=auto.auto_mob_bin;
tables _character_/ plots=freqplot(scale=percent);
run;

proc freq data=auto.auto_mob_bin;
	tables bin_hp/ plots=freqplot(scale=percent);
run;

/*We confirm the strength of association between categorical inputs and the price variable by performing One way Anova test.
The stronger the association, larger will be the F-value for ANOVA table that is calculated by dividing the explained
variation in model (model sum of squares) by unexplained variation in model (error sum of squares) and therefore, the p-value
for ANOVA test will be small. We will perform one way ANOVA test at a significance level, alpha=0.05 which corresponds to the
Type 1 error.
We also check the homoscadascity of the variance of price within different populations or levels of the categorical variable using
Hovtest= Levene option. The diagnostic plots further help us assess our assumptions for Avova testing to determine
whether the errors are normally distributed.*/
data auto.temptable;
infile datalines;
length categories $25;
input categories $;
datalines;
engine_location
drive_wheels
make
fuel_type
aspiration
engine_type
num_of_cylinders
fuel_system
bin_hp
;
run;

%macro anovatest (data=);
proc sql;
select categories into :categories1 -
	from auto.temptable;
quit;
%let lastindex= &sqlobs;
%do i = 1 %to &lastindex;
proc glm data=&data plots=diagnostics;
	class &&categories&i;
	model price= &&categories&i;
	means &&categories&i/ hovtest=levene;
run;
%end;
%mend;

%anovatest(data=auto.auto_mob_bin);

/*Based on ANOVA test, the only variables that seems to show a significant association with price variable and also 
meet the assumption of normal distribution of errors are:
drive wheels, make, engine type, num of cylinders, bin_hp and aspiration. 
These will be included in model selection. */

/*We will also assess Multicollinearity to make sure that the model we fit is not unstable as multicollinearity can
give rise to unstable parameter estimates and inflated standard errors. We check for multicollinearity using
variance inflation factor (vif) option in proc reg model statement. If vif is greater than 10 for a variable then
there there is multicollinearity in the model. */

%let intervals= engine_size curb_weight width highway_mpg length city_mpg bore horse_power;

proc reg data=auto.auto_mob_bin plots=all;
	model price= &intervals/ vif;
run;

/*The vif is greater than 10 for curb weight, highway mpg and city mpg. We will further explore the multicollinearity
through correlation matrix and scatter plots. We print top most 3 best correlations of each variables among each other.*/

proc corr data=auto.auto_mob_bin nosimple best= 3 plots(only)=scatter(nvar=all ellipse=none);
	var &intervals;
run;
*we see a very strong correlation between highway_mpg and city_mpg of 0.97. The curb_weight also show
a very strong correlation with length of 0.88.  We will remove highway_mpg and length and then
run the proc reg procedure again to check vif;
proc reg data=auto.auto_mob_bin plots=diagnostics;
	model price= engine_size curb_weight width city_mpg bore horse_power/ vif;
run;
/*Now all the variables have their VIF below 10. Therefore, we have solved the problem with multicollinearity in the model.
*/
/*Conclusion: Based on above exploratory analysis, the list of numerical input variables to be used are:
engine_size, curb_weight, width, city_mpg, bore, and horse_power.
The list of categorical variables to be used in the model are:
drive wheels, make, engine type, num of cylinders, bin_hp and aspiration. */
ods rtf close;
