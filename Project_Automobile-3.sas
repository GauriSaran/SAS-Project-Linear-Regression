/*Model Development and Validation*/

/*We will use the numerical and categorical variables selected from the exploratory analysis to 
fit models on the training data and then validate those models based on the lowest Average Squared error
on the Validation data. The dataset is partitioned into training and validation data set using partition
fraction in proc glmselect. We will use these 3 Stepwise selection techniques: Forward selection, Backward selection,
and Stepwise selection. We use significance level of 0.05 to allow the input variables to enter or leave the model. We will
also include 2 factor interactions between the variables. 
*/
ods rtf file="/home/u47236280/Projects-Automobile/Project-Automobile3.rtf" startpage=no;
%let intervall= engine_size curb_weight width city_mpg bore horse_power;
%let category= drive_wheels make engine_type num_of_cylinders bin_hp aspiration;

proc glmselect data=auto.auto_mob_bin plots=all seed=123455 namelen=50;
	class &category/ param=glm ref=first;
	STEPWISE: model price= engine_size|curb_weight|width|city_mpg|bore|horse_power|drive_wheels|make|engine_type|num_of_cylinders|bin_hp|aspiration @2/
	selection=stepwise select=sl slentry=0.05 slstay=0.05 hierarchy=single choose=validate showpvalues;
	partition fraction(validate=0.233);
	store out=item_auto;
run;

/*In the above selection technique: Stepwise, the effects selected, 10 effects are selected in the model which
involves 2 interactions as well. These effects are:
engine_size, curb_weight, horse_power, engine_size*horse_power, curb_weight*horse_power, drive_wheels, make,
engine_size*make, drive_wheels*make and num_of_cylinders. 
These effects are chosen based on the lowest Average squared error on the validation data set.
Now we will use the next selection technique: Forward method of selection and Backward method
of selection with a significance level of 0.05 to allow input variables to enter the model or stay in the model.
*/
proc glmselect data=auto.auto_mob_bin plots=all seed=123455 namelen=50;
	class &category/ param=glm ref=first;
	FORWARD: model price= engine_size|curb_weight|width|city_mpg|bore|horse_power|drive_wheels|make|engine_type|num_of_cylinders|bin_hp|aspiration @2/
	selection=forward select=sl slentry=0.05 slstay=0.05 hierarchy=single choose=validate showpvalues;
	partition fraction(validate=0.233);
run;

proc glmselect data=auto.auto_mob_bin plots=all seed=123455 namelen=50;
	class &category/ param=glm ref=first;
	BACKWARD: model price= engine_size|curb_weight|width|city_mpg|bore|horse_power|drive_wheels|make|engine_type|num_of_cylinders|bin_hp|aspiration @2/
	selection=backward select=sl slstay=0.05 choose=validate details=steps showpvalues;
	partition fraction(validate=0.233);
run;
/*The results show that Forward and Stepwise selection gives the same results and the model chosen
based on lowest Average squared error is the model with the same 10 predictor variables.
However, the backward selection method does not give same result and it only eliminates 5 effects in which
4 of them are interaction effects for the model with lowest Average squared error. However, the lowest Average
squared error on validation data from backward selection process is a lot higher than 
the lowest Average squared error on the validation data from stepwise and forward selection process. Therefore,
we will not use the model from Backward. The overall fit of the model from stepwise and forward selection
from the ANOVA table shows that model is a good fit at a significance level of 0.05. The other fit statistics
criteria such as AIC, AICC, SBC have also reduced for the final model in Stepwise and Forward selection process.
Also these fit statistics criteria have smaller value as compared to the model from Backward selection process.
*/

/*Therefore the final set of screened variables to be included in the model are: */

%let screened= engine_size curb_weight horse_power engine_size*horse_power curb_weight*horse_power drive_wheels make
engine_size*make drive_wheels*make num_of_cylinders;

/*Now to make sure that the model will meet the assumptions of linear regression, we will look at the 
diagnostic plots to ensure that errors are normally distributed the residuals vs predicted value plots as well
the plots of residuals vs different predictor variables show constant variance.*/

proc glm data=auto.auto_mob_bin plots=all;
	class drive_wheels num_of_cylinders make/ ref=first;
	model price= engine_size curb_weight horse_power engine_size*horse_power curb_weight*horse_power drive_wheels make
engine_size*make drive_wheels*make num_of_cylinders;
run;
	 
/*The assumptions for linear regression model are also met as the plots of residuals vs predicted values and
residuals vs different predictor variables shows the constant variance and no significant pattern is visible.
The Q-Q plot shows that errors are normally distributed.*/

/*Now we will use the stored item: item_auto to score new cases. In this project, we don't have new observations.
Therefore we will simply score the same dataset that we used for model building even though this will not
be a real world scenario.
We will use 2 methods of scoring the data. One uses proc plm to score the data. The other uses 
Code statement in proc plm and then data step to score new cases.*/

proc plm restore=item_auto plots=all;
	score data= auto.auto_mob_bin out=scored_data;
	effectplot slicefit(x=engine_size sliceby=make);
	effectplot slicefit(x=curb_weight);
	Code file= "/home/u47236280/Projects-Automobile/score.sas";
run;
/*The effectplot shows that price increases as engine size increases for the make Subaru. However, it
decreases for make audi and pretty much remains consistent/ very slightly decreases for the make toyota.
*/
/*Now we use a data step to score the same dataset and we will compare the two scoring techniques using
proc compare to check whether there is any difference in the predicted values using a criterion of 0.0001
for comparison of predicted values.*/

data scored_data_new;
	set auto.auto_mob_bin;
	%include "/home/u47236280/Projects-Automobile/score.sas";
run;

proc compare base=scored_data compare=scored_data_new criterion=0.0001;
var Predicted;
with P_price;
run;

/*From proc compare results we can see that the total number of values which compares unequal are 0.
This shows that the two methods of scoring are quite comparable.*/
ods rtf close;








