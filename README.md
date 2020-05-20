 # Machine-Learning-Project-Regression-to-Predict-Price-of-Automobile
Predicting Price of an Automobile using Linear and Multiple Regression
# Project
## Predicting the Price of the automobile based on different features of a car.

The goal of this project is to build a model that will predict the automobile prices using the data from already used car
prices from Automobile Dataset: : https://archive.ics.uci.edu/ml/machine-learning-databases/autos/imports-85.data
The project uses SAS/ STAT software to build a model by splitting the dataset in to training and validation dataset.
There are 25 independent variables that are used to build the model for predicting Automobile price such as:
*Aspiration
*Body_style
*Bore
*City_mpg
*Compression_ratio
*Curb_weight
*Drive_wheels
*Engine_location
*Engine_size
*Engine_type
*Fuel_system
*Fuel_type
*Height
*Highway_mpg
*Horse_power
*Length
*Make
*Normalized_losses
*Num_of_cylinders
*Num_of_doors
*Peak_rpm
*Stroke
*Symboling
*Wheel_base
*Width
# Project is divided in to 3 sections:
## Data-Wrangling which involves:
* Pre-processing Data
* Dealing missing values
* Data Formatting
* Data Normalization
* Binning
This part involves use of SAS procedures such as Proc contents, Proc means, Proc freq for calculating descriptive statistics, Proc stdize (for imputing missing values) Proc rank for binning the data, using SAS array and do loop for data normalization.
## Exploratory Data Analysis which involves:
* Descriptive Statistics
* Analysis of Variance
* Correlation
This part of project involves use of SAS procedures such as Proc corr, Proc sgscatter, Proc sgplot for data visualization and correlation analysis. Proc glm along with macro processing is used for ANOVA testing and Proc reg to confirm multicollinearity using Variance
Inflation factor.
## Model Development, Review and Evaluation which involves:
* Simple Linear Regression
* Multiple Linear Regression
* Regression plots
* Distribution plots
This part of project involves used of SAS procedures such as Proc glmselect to select list of candidate models
using the three stepwise selection techniques: Stepwise, Forward and Backward Selection using a significance level criterion for parameters to enter or leave the model at 0.05. The model is validated on the validation dataset to select the best performing model using Average Squared error. Model assumptions are checked using Proc glm for normally distributed error and constant variance of the errors.
Proc plm is finally used to score the fitted model to make predictions.
## Software Used:
* SAS University Edition


