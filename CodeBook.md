---
title: "Codebook for run_analysis.R file"
author: "H Starling"
date: "2015.09.24"
output:
  html_document:
    keep_md: yes
---

## Study Design
Wearable computing is an area that has growing interest. Wearable devices provide a means to understand the location and positioning of humans that could be utilized to better target consumers.  Experiments were carried out to collect data to understand and translate human activities into data points.  The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually.

###Collection of the raw data
The original data was obtained from this site:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
The data is a Human Activity Recognition database built from the recordings of 30 subjects performing activities of daily living while carrying a waist-mounted smartphone with embedded inertial sensors.

The data provided for processing provided the following:
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration. 
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

###Data Processing
The desired output from the processing is a tidy data set that allows for the utilization of the data to better understand and be able to identify data that represents activities of daily living (ADL). The format chosen for this data is a tidy, **WIDE data set**. The reasons for this choice as the tidy data set format are as follows:
- The experiment involves observing ADL per person per activity to better identify activity by data points. According to H. Wickham (see Sources section below), it is easier to make comparisons between groups of observations than between groups of columns.  It is assumed that most comparisons will be across the subject+activity in order to create models that can identify ADL.
- The data was provided in a format with the measurements per subject per activity. Providing the wide format was more similar to this than the narrow format therefor it was assumed this format would be more familiar to the end user.
- The final output was an average of measurements grouped by subject + activity. THe wide format seemed more logical and better aligned with this format than the narrow.

The data fits the requirements of a tidy data set as explained below:
- Each variable forms a column - the first two columns are fixed variables and identify the subject and activity. THese variables are part of the experimental design and are known in advance.  The remaining columns are the measurement variables for that subject performing that activity. This is the structure recommended by H. Wickham.
- Each observation forms a row - the observation is of a subject performing an activity.  Each row represents a unique instance of this, per H. Wickham's recommendations.
- Each type of observation unit forms a table - these are all observations used to understand and analyze activities of daily living (ADL) with an observation unit consisting of measurements taken hile a subject performs one activity of daily living.

The end result of the data processing produces a file that is the activities of daily living grouped and averaged by subject + activity.  Each of the 30 subjects performed six activities multiple times.  Measurements were limited to those that represented either mean or standard deviation.  Since these specific variables were not called out, any variable that had the term "mean" or "std" was included in the output. (full variable descriptions are below). 

Minimal descriptions of these variables/measurements were provided so minimal changes were made to the variables to avoid confusion.  Per the information provided with the raw data, variable starting with a "t" indicates time domain signals (prefix 't' to denote time) that were captured at a constant rate of 50 Hz.  A Fast Fourier Transform (FFT) was applied to some of these signals which is indicated by the variable starting with an "f".  THese standards were carried through into the final tidy data set to ensure consistency. Google R-Style Guide (see Sources) was utilized as a guide for cleaning up the variable names and removing parantheses, hyphens, etc. THe term "Average" was concatenated onto the end of each variable in the final output to differentiate these measurements from the sample measurements.

The run_analysis.R file has extensive step by step comments that describe the details of the execution. THe file contains a function named GenerateAnalysis() that requires no variables and processes the data into a tidy data set.

##Create the tidy datafile
1. Data should first be downloaded from this site (from the class project description):
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
2. This downloaded file should be unzipped in the working directory.
3. Source the run_analysis.R file.
4. Enter in the R console: GenerateFile()
5. Look for the generated text file Variable_Average_By_User.txt in the folder named data.

###Guide to create the tidy data file
Description on how to create the tidy data file (1. download the data, ...)/

###Cleaning of the data
Short, high-level description of what the cleaning script does. [link to the readme document that describes the code in greater detail]()

##Description of the variables in the tiny_data.txt file
General description of the file including:
 - Dimensions of the dataset
 - Summary of the data
 - Variables present in the dataset

(you can easily use Rcode for this, just load the dataset and provide the information directly form the tidy data file)

###Variable 1 (repeat this section for all variables in the dataset)
Short description of what the variable describes.

Some information on the variable including:
 - Class of the variable
 - Unique values/levels of the variable
 - Unit of measurement (if no unit of measurement list this as well)
 - In case names follow some schema, describe how entries were constructed (for example time-body-gyroscope-z has 4 levels of descriptors. Describe these 4 levels). 

(you can easily use Rcode for this, just load the dataset and provide the information directly form the tidy data file)

####Notes on variable 1:
If available, some additional notes on the variable not covered elsewehere. If no notes are present leave this section out.

##Sources
Human Activity Recognition database
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
Google's R Style Guide was utilized for R standards
https://google-styleguide.googlecode.com/svn/trunk/Rguide.xml
Hadley Wickham paper on tidy data
http://vita.had.co.nz/papers/tidy-data.pdf

##Annex
If you used any code in the codebook that had the echo=FALSE attribute post this here (make sure you set the results parameter to 'hide' as you do not want the results to show again)