libname auto base "/home/u47236280/Projects-Automobile";
*importing csv file for analyzing automobile dataset;

data auto.auto_mob;
	infile "/home/u47236280/Projects-Automobile/imports-85.data" dlm=',' dsd;
	input symboling normalized_losses make $ fuel_type $
	aspiration $ num_of_doors $ body_style $ drive_wheels $
	engine_location $ wheel_base length width height curb_weight
	engine_type $ num_of_cylinders $ engine_size fuel_system $
	bore stroke compression_ratio horse_power peak_rpm
	city_mpg highway_mpg price;
run;
* total number of row is 204 in auto_mob dataset;
* dropping rows with missing value for price, the total
number of rows remaining in auto_mob dataset is 201;

data auto.auto_mob;
	 set auto.auto_mob;
	 if price ne . then output;
run;
ods rtf file="/home/u47236280/Projects-Automobile/Project-Automobile1.rtf" startpage=no;
proc contents data=auto.auto_mob;
run;

proc means data=auto.auto_mob;
run;

proc freq data=auto.auto_mob;
tables _character_;
run;


/*replacing missing values with the means of the variables*/

%let variable1= stroke;
%let variable2= bore;
proc means data=auto.auto_mob mean maxdec=2 noprint;
var &variable1 &variable2;
output out= avg_auto_mob mean=&variable1._50 &variable2._50;
run;

data auto.auto_mob_mi(drop=_TYPE_ _FREQ_ stroke_50 bore_50);
	if _N_=1 then set avg_auto_mob;
	set auto.auto_mob;
	array mi{*} stroke bore;
	array new{*} &variable1._50 &variable2._50;
	do i= 1 to dim(mi);
	if mi(i)=. then mi(i)=round(new(i), .2);
	end;
	drop i;
run;

proc means data=auto.auto_mob_mi;
var _numeric_;
run;

%let interval= normalized_losses horse_power peak_rpm;
proc stdize data=auto.auto_mob_mi method=mean reponly out= auto.auto_mob_mi;
var &interval;
run;

/*Since the num_of_doors shows maximum frequency count for the value 'four', the
missing num_of_doors indicated by '?' will be replaced with 'four'*/

data auto.auto_mob_mi;
	set auto.auto_mob_mi;
	if num_of_doors='?' then num_of_doors='four';
run;


proc means data=auto.auto_mob_mi;
var _numeric_;
run;

proc freq data=auto.auto_mob_mi;
tables _character_;
run;


/*Normalizing the Data*/

%let interval= normalized_losses peak_rpm stroke bore length width height curb_weight compression_ratio city_mpg 
engine_size highway_mpg wheel_base;
proc means data=auto.auto_mob_mi mean stddev noprint;
var &interval;
output out=auto.avg_mob mean= normalized_losses50 peak_rpm50 stroke50 bore50 length50 width50 height50 width50 curb_weight50 compression_ratio50
						city_mpg50 engine_size50 highway_mpg50 wheel_base50 
						std= normalized_losses_std peak_rpm_std stroke_std bore_std length_std width_std height_std curb_weight_std
						compression_ratio_std city_mpg_std engine_size_std highway_mpg_std wheel_base_std;
run;

data auto.auto_mob_mi (drop = normalized_losses50 peak_rpm50 stroke50 bore50 length50 width50 height50 curb_weight50 compression_ratio50
						city_mpg50 engine_size50 highway_mpg50 wheel_base50 normalized_losses_std peak_rpm_std stroke_std bore_std length_std width_std height_std curb_weight_std
						compression_ratio_std city_mpg_std engine_size_std highway_mpg_std wheel_base_std
					 _TYPE_ _FREQ_ i);
	if _N_=1 then set auto.avg_mob;
	set auto.auto_mob_mi;
	array dat{*} normalized_losses peak_rpm stroke bore length width height curb_weight compression_ratio city_mpg 
engine_size highway_mpg wheel_base;
	array datmean{*} normalized_losses50 peak_rpm50 stroke50 bore50 length50 width50 height50 curb_weight50 compression_ratio50
						city_mpg50 engine_size50 highway_mpg50 wheel_base50;
	array datstd{*} normalized_losses_std peak_rpm_std stroke_std bore_std length_std width_std height_std curb_weight_std
						compression_ratio_std city_mpg_std engine_size_std highway_mpg_std wheel_base_std;
	do i = 1 to dim(dat);
	dat(i)=(dat(i)-datmean(i))/datstd(i);
	end;
run;

/*Binning the horse_power variable into 4 levels*/
proc rank data=auto.auto_mob_mi groups=4 out=auto.auto_mob_bin;
var horse_power;
ranks bin_hp;
run;
data auto.auto_mob_bin;
	set auto.auto_mob_bin(rename=(bin_hp=binned));
	bin_hp= put(binned, z.);
	drop i binned;
run;
proc format;
	value $binf '0'='Low'
		       '1'= 'Medium'
		       '2'='Medium'
		         '3'= 'High';
run;
title "The first 20 observations in the final dataset";
proc print data=auto.auto_mob_bin (obs=20);
	format bin_hp $binf.;
run;
ods rtf close;
	
	
	
	
	
	
	
	









