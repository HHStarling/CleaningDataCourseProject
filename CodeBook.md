---
title: "Getting and Cleaning Data Course Project"
author: "H Starling"
date: "2015.09.24"
output:
  html_document:
    keep_md: yes
---

## Project Description
Wearable computing is an area that has growing interest. Wearable devices provide a means to understand the location and positioning of humans that could be utilized to better target consumers.  Experiments were carried out to collect data to understand and translate human activities into data points.  The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually.

An R-script called run_analysis.R should be created to do the following:
- 1. Merges the training and the test sets to create one data set.
- 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
- 3. Uses descriptive activity names to name the activities in the data set
- 4. Appropriately labels the data set with descriptive variable names. 
- 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

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

Abbreviations used in the original raw data variables:
- t or f leaading character indicates time or frequency
- Body - body movement measurement
- Gravity - acceleration of gravity
- Acc - accelerometer measurement
- Gyro - gyroscope measurement
- Mag - magnitude
- Jerk - sudden accelerated movement
- mean - calculated mean measurement
- std - standard deviation measurement


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

##Specific Processing Steps
###Download the data
- Download the data from the location provided in the course (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
- File should be downloaded and unzipped and the resulting folder placed in the working directory.

###Source the file to make the function available
```
> source('~/Documents/Development/Coursera Data Science/3 - Cleaning Data/CourseProject/CleaningDataCourseProject/run_analysis.R')
```

###Run the function to generate the file
```
> GenerateFile()
```
The tidy data file will be generated and placed in the data folder in the working directory.

###Steps executed by the function
####Load the data from the files
The directory is renamed (simpler name less typing) and data is loaded from the files.
```
  # ***** LOAD UP DATA SECTION *****
  # assuming that the dataset has been downloaded and is in a folder in the working directory
  # rename folder with data if it hasnt happened already
  if(!file.exists("./data")){
    file.rename("UCI HAR Dataset", "data")
  }
  
  # delete the existing results file if it exists
  if(file.exists("./data/Variable_Average_By_User.txt")){
    file.remove("./data/Variable_Average_By_User.txt")
  }
  
  # load test data files
  testX <- read.table("./data/test/X_test.txt", stringsAsFactors = FALSE)
  testY <- read.table("./data/test/y_test.txt", stringsAsFactors = FALSE)
  testSubject <- read.table("./data/test/subject_test.txt")
  
  # load train data files
  trainX <- read.table("./data/train/X_train.txt", stringsAsFactors = FALSE)
  trainY <- read.table("./data/train/y_train.txt", stringsAsFactors = FALSE)
  trainSubject <- read.table("./data/train/subject_train.txt")
  
  # load features.txt file
  features <- read.table("./data/features.txt", stringsAsFactors = FALSE)
  
  # load activity labels file
  activity <- read.table("./data/activity_labels.txt", stringsAsFactors = FALSE)
  ```
  
####Determine columns to use (Step 2 from the instructions)
Locate columns that have either mean or std to use and pull variable name and column number.  Also clean up variable names so they are more explanatory.
  ```
    # ***** CLEAN UP DATA AND DETERMINE COLUMNS AND ROWS TO USE *****
  # use features data frame to find names, columns to keep
  finalColumns <- features[grep("mean|std",features$V2, ignore.case = TRUE),]
```

####Appropriately label the data set with descriptive variable names (Step 4)
```
  # clean up column names:
  # Leaving column naming mostly as is to avoid changing something that I cannot confirm
  
  # replace -mean with Mean
  finalColumns$V2 <- gsub("-mean\\(\\)", "MEAN",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("-mean", "MEAN",finalColumns$V2, ignore.case = TRUE)
  # replace -std with Std
  finalColumns$V2 <- gsub("-std\\(\\)", "SD",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("-std", "SD",finalColumns$V2, ignore.case = TRUE)
  # remove parantheses ()
  finalColumns$V2 <- gsub("\\(\\)", "",finalColumns$V2, ignore.case = TRUE)
  # remove individual parantheses
  finalColumns$V2 <- gsub("\\(", "",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("\\)", "",finalColumns$V2, ignore.case = TRUE)
  # remove commas
  finalColumns$V2 <- gsub(",", "",finalColumns$V2, ignore.case = TRUE)
  # remove hyphens
  finalColumns$V2 <- gsub("-", "",finalColumns$V2, ignore.case = TRUE)
  # capitalize, use full desciriptors
  finalColumns$V2 <- gsub("anglet", "angleTime",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("gravity", "Gravity",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("Gyro", "Gyroscope",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("Acc", "Acceleration",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("gravity", "Gravity",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("^t", "time",finalColumns$V2, ignore.case = TRUE)
  finalColumns$V2 <- gsub("^f", "frequency",finalColumns$V2, ignore.case = TRUE)
  ```
  
####Uses descriptive activity names to name the activities (Step 3)
Both test and train data sets are loaded up with activity descriptions
```
  # add activity values to each activity data set
  # test activity data
  ii <- as.numeric(nrow(testY))
  testActivity <- vector(mode="character", length=ii)
  for(i in 1:ii){
    activityNum <- as.numeric(testY[i,1])
    newActivity <- activity[activityNum,2]
    testActivity[i] = newActivity
  }
  # add activity description column to activity data
  testY <- cbind(testY, testActivity)
  
  # repeat for train activity data
  ii <- as.numeric(nrow(trainY))
  trainActivity <- vector(mode="character", length=ii)
  for(i in 1:ii){
    activityNum <- as.numeric(trainY[i,1])
    newActivity <- activity[activityNum,2]
    trainActivity[i] = newActivity
  }
  # add activity description column to activity data
  trainY <- cbind(trainY, trainActivity)
```

####Merges the training and test sets to create one data set (Step 1)
Columns (variables) are pieced together separately for the test and train sets using the same structure. THen the rows (observations) of the two sets are joined using rbind.
```
  # ***** COLLECT DATA TOGETHER INTO ONE DATA SET *****
  #
  # First combine each set of data (test and train) to make a single data set
  # ordering of new data set columns will be:
  # 1 - subject identifier
  # 2 - activity description
  # 3-89 - feature measurements for mean and std only pulled from finalColumns dataset
  
  # Create table names vector
  dataNames <- c("SubjectIdentifier","ActivityDescription")
  # Create vector for column numbers to use from features measurements data
  dataColumns <- vector()
  ii <- as.numeric(nrow(finalColumns))
  iii <- ii + 2 # skip first two entries for vector since provided above
  for(i in 3:iii){
    dataNames[i] <- finalColumns[i-2,2]
    dataColumns[i-2] <- finalColumns[i-2,1]
  }
  
  # create data frame for test data load
  dataTest <- data.frame()
  dataTest <- data.frame(cbind(as.numeric(testSubject$V1),as.character(testY[,2])), stringsAsFactors = FALSE)
  for(i in 1:ii){
    dataTest <- data.frame(cbind(dataTest,as.numeric(testX[,i])))
  }
  colnames(dataTest) <- dataNames
  
  # create data frame for train data load
  dataTrain <- data.frame()
  dataTrain <- data.frame(cbind(as.numeric(trainSubject$V1),as.character(trainY[,2])), stringsAsFactors = FALSE)
  for(i in 1:ii){
    dataTrain <- data.frame(cbind(dataTrain,as.numeric(trainX[,i])))
  }
  colnames(dataTrain) <- dataNames
  
  # combine all data from test and train into one data set
  dataCombined <- data.frame(rbind(dataTest, dataTrain))
  # set identifier column to numeric
  dataCombined$SubjectIdentifier <- as.numeric(dataCombined$SubjectIdentifier)
  
  # Final data frame created is named dataCombined containing both test and train data
  # head(dataCombined)
  
  # end script to load and create first data set
```

####Create a second tidy data set (Step 5)
Second set is the average of each variable for each activity and each subject. Export the data as a text file using write.table().Look for the generated text file ***Variable_Average_By_User.txt*** in the folder named data.
```
  # *******************************************************************
  # ***** CREATE SECOND TIDY DATA SET QUESTION 5 *****
  # question 5 - create summary dataset
  library(dplyr)
  
  #convert data frame created to table data frame in dplyr and group
  dataCombined2 <- tbl_df(data.frame(dataCombined))
  
  # group data
  dataGrouped <- group_by(dataCombined2, SubjectIdentifier, ActivityDescription) %>% summarise_each(c("mean"))
  
  # create new names vector adding "_Average" to each column name
  dataNames2 <- c("SubjectIdentifier","ActivityDescription")
  for(i in 3:88) {
    dataNames2[i] <- paste(dataNames[i], sep="", "Average")
  }
  names(dataGrouped) <- dataNames2
  
  #write to table for output - use pipe | delimeter so as to avoid any confusion
  write.table(dataGrouped, row.names=FALSE, file="./data/Variable_Average_By_User.txt", sep="|")
```

###Outline of data cleaning steps
THe high level steps for processing and cleaning the data are as follows.  For detailed steps, either the run_analysis.R file has extensive commenting or the README file also has details.
- The raw data files (test, train, features, and activity data) are each loaded separately into data frames for processing.  Individual processing of each data frame is completed separately and then the final dataset is created by pulling the parts of the data frames together into one frame.
- The features data contains the list of measurements taken.  This information is used to determine the measurements that have either "mean" or "std" in them.  The results from this search are the final measurements used for the tidy data set.
- The variable names for the measurements (which will become the column names) are cleaned up, using Google R-style Guide (see sources).  Parentheses, hyphens and commas are removed. Capitalization of first letter for each word are used. Abbreviations like Std are spelled out (StandardDeviation).
- A data set is created from the final measurement names which also includes the column numbers for these measurements in the data.  This is used to pull the measurement associated with the measurement value since both are stored in this data set.
- The activity data set is used to translate the activity numeric value to an activity description. THese descriptions are added to the data set with the numeric values.
- A vector is then created with the names for the final data frame variables (columns).
- The test data is collected together starting with the subject identifier and the activity description data.  The data set with measurement column numbers is used to pull the appropriate columns from the measurement data and add to the growing data frame. 
- This process is repeated for the train data, assembling together an identical set of data from the train data.
- Finally the test and train data rows are combined together to create one large set.
- This set is then grouped by subject and activity, and averages (means) taken for each measurement per subject per activity.
- THe variable names are adjusted to add "Average" on to the end of each variable name to differentiate these from the original data set.
- The results of this are output to a file ***(Variable_Average_By_User.txt) and placed in the data folder***.

##Description of the Variable_Average_By_User.txt file
The text file generated has the following charachteristics:
- A pipe "|" delimeter is used to clearly define column breaks
- The file contains 181 rows (1 header row and 180 observations) and 88 columns (2 fixed variables and 86 measurements)
- The file can be opened in Excel using the delimeter as a pipe |

The structure of the dataset and its variables is as follows:
Classes ‘grouped_df’, ‘tbl_df’, ‘tbl’ and 'data.frame':	180 obs. of  88 variables:
- $ SubjectIdentifier                                  : num  1 1 1 1 1 1 2 2 2 2 ...
- $ ActivityDescription                                : chr  "LAYING" "SITTING" "STANDING" "WALKING" ...
- $ timeBodyAccelerationMEANXAverage                   : num  0.222 0.261 0.279 0.277 0.289 ...
- $ timeBodyAccelerationMEANYAverage                   : num  -0.04051 -0.00131 -0.01614 -0.01738 -0.00992 ...
- $ timeBodyAccelerationMEANZAverage                   : num  -0.113 -0.105 -0.111 -0.111 -0.108 ...
- $ timeBodyAccelerationSDXAverage                     : num  -0.928 -0.977 -0.996 -0.284 0.03 ...
- $ timeBodyAccelerationSDYAverage                     : num  -0.8368 -0.9226 -0.9732 0.1145 -0.0319 ...
- $ timeBodyAccelerationSDZAverage                     : num  -0.826 -0.94 -0.98 -0.26 -0.23 ...
- $ timeGravityAccelerationMEANXAverage                : num  -0.9321 -0.9795 -0.9961 -0.3407 -0.0441 ...
- $ timeGravityAccelerationMEANYAverage                : num  -0.8409 -0.9197 -0.9718 0.0618 -0.1074 ...
- $ timeGravityAccelerationMEANZAverage                : num  -0.822 -0.939 -0.979 -0.25 -0.212 ...
- $ timeGravityAccelerationSDXAverage                  : num  -0.906 -0.927 -0.939 -0.103 0.389 ...
- $ timeGravityAccelerationSDYAverage                  : num  -0.5016 -0.5174 -0.5609 -0.0557 -0.0953 ...
- $ timeGravityAccelerationSDZAverage                  : num  -0.703 -0.786 -0.813 -0.255 -0.317 ...
- $ timeBodyAccelerationJerkMEANXAverage               : num  0.7431 0.8203 0.8489 0.1196 0.0157 ...
- $ timeBodyAccelerationJerkMEANYAverage               : num  0.5849 0.6828 0.685 -0.0212 -0.0437 ...
- $ timeBodyAccelerationJerkMEANZAverage               : num  0.758 0.822 0.838 0.437 0.305 ...
- $ timeBodyAccelerationJerkSDXAverage                 : num  -0.842 -0.946 -0.984 -0.126 0.008 ...
- $ timeBodyAccelerationJerkSDYAverage                 : num  -0.984 -0.998 -1 -0.739 -0.463 ...
- $ timeBodyAccelerationJerkSDZAverage                 : num  -0.948 -0.99 -0.999 -0.758 -0.813 ...
- $ timeBodyGyroscopeMEANXAverage                      : num  -0.905 -0.987 -0.999 -0.748 -0.724 ...
- $ timeBodyGyroscopeMEANYAverage                      : num  -0.94 -0.983 -0.996 -0.424 -0.225 ...
- $ timeBodyGyroscopeMEANZAverage                      : num  -0.877 -0.932 -0.974 -0.299 -0.399 ...
- $ timeBodyGyroscopeSDXAverage                        : num  -0.823 -0.943 -0.979 -0.252 -0.206 ...
- $ timeBodyGyroscopeSDYAverage                        : num  -0.372 -0.594 -0.654 0.359 0.237 ...
- $ timeBodyGyroscopeSDZAverage                        : num  -0.491 -0.399 -0.563 0.437 0.376 ...
- $ timeBodyGyroscopeJerkMEANXAverage                  : num  -0.402 -0.5213 -0.5895 0.0424 0.1697 ...
- $ timeBodyGyroscopeJerkMEANYAverage                  : num  0.043 0.152 0.297 -0.335 -0.395 ...
- $ timeBodyGyroscopeJerkMEANZAverage                  : num  0.00523 -0.05942 -0.14551 0.34841 0.36759 ...
- $ timeBodyGyroscopeJerkSDXAverage                    : num  -0.0323 0.041 0.1136 -0.1492 -0.31 ...
- $ timeBodyGyroscopeJerkSDYAverage                    : num  0.14657 -0.00412 0.0807 0.07994 0.2763 ...
- $ timeBodyGyroscopeJerkSDZAverage                    : num  0.176 0.169 0.185 -0.167 -0.121 ...
- $ timeBodyAccelerationMagMEANAverage                 : num  -0.104 -0.129 -0.138 0.175 0.155 ...
- $ timeBodyAccelerationMagSDAverage                   : num  0.1842 0.1851 0.1903 0.1678 0.0867 ...
- $ timeGravityAccelerationMagMEANAverage              : num  0.0105 -0.117 -0.0158 -0.0514 0.0377 ...
- $ timeGravityAccelerationMagSDAverage                : num  0.2091 0.2589 0.2799 -0.1189 0.0804 ...
- $ timeBodyAccelerationJerkMagMEANAverage             : num  -0.1219 -0.1171 -0.1279 0.1673 0.0878 ...
- $ timeBodyAccelerationJerkMagSDAverage               : num  0.09054 0.08508 0.11685 0.00262 0.02916 ...
- $ timeBodyGyroscopeMagMEANAverage                    : num  0.00239 -0.02272 -0.10391 -0.27517 -0.2914 ...
- $ timeBodyGyroscopeMagSDAverage                      : num  -0.0409 -0.4029 0.1284 -0.1437 -0.4542 ...
- $ timeBodyGyroscopeJerkMagMEANAverage                : num  -0.00933 -0.20119 -0.00543 -0.19123 -0.22554 ...
- $ timeBodyGyroscopeJerkMagSDAverage                  : num  -0.0234 0.1183 0.2883 0.3802 0.0757 ...
- $ frequencyBodyAccelerationMEANXAverage              : num  -0.249 0.832 0.943 0.935 0.932 ...
- $ frequencyBodyAccelerationMEANYAverage              : num  0.706 0.204 -0.273 -0.282 -0.267 ...
- $ frequencyBodyAccelerationMEANZAverage              : num  0.4458 0.332 0.0135 -0.0681 -0.0621 ...
- $ frequencyBodyAccelerationSDXAverage                : num  -0.897 -0.968 -0.994 -0.977 -0.951 ...
- $ frequencyBodyAccelerationSDYAverage                : num  -0.908 -0.936 -0.981 -0.971 -0.937 ...
- $ frequencyBodyAccelerationSDZAverage                : num  -0.852 -0.949 -0.976 -0.948 -0.896 ...
- $ frequencyBodyAccelerationMEANFreqXAverage          : num  -0.899 -0.969 -0.994 -0.977 -0.951 ...
- $ frequencyBodyAccelerationMEANFreqYAverage          : num  -0.91 -0.938 -0.981 -0.972 -0.938 ...
- $ frequencyBodyAccelerationMEANFreqZAverage          : num  -0.855 -0.95 -0.977 -0.95 -0.898 ...
- $ frequencyBodyAccelerationJerkMEANXAverage          : num  -0.28 0.768 0.87 0.869 0.876 ...
- $ frequencyBodyAccelerationJerkMEANYAverage          : num  0.685 0.188 -0.288 -0.294 -0.27 ...
- $ frequencyBodyAccelerationJerkMEANZAverage          : num  0.4694 0.3319 0.0097 -0.0629 -0.0465 ...
- $ frequencyBodyAccelerationJerkSDXAverage            : num  -0.236 0.843 0.961 0.947 0.936 ...
- $ frequencyBodyAccelerationJerkSDYAverage            : num  0.692 0.205 -0.248 -0.26 -0.256 ...
- $ frequencyBodyAccelerationJerkSDZAverage            : num  0.41387 0.32184 0.00938 -0.07849 -0.0863 ...
- $ frequencyBodyAccelerationJerkMEANFreqXAverage      : num  0.248 0.225 -0.244 -0.142 -0.206 ...
- $ frequencyBodyAccelerationJerkMEANFreqYAverage      : num  -0.907 0.575 0.846 0.826 0.817 ...
- $ frequencyBodyAccelerationJerkMEANFreqZAverage      : num  0.165 -0.88 -0.862 -0.864 -0.879 ...
- $ frequencyBodyGyroscopeMEANXAverage                 : num  -0.32 -0.779 -0.995 -0.986 -0.988 ...
- $ frequencyBodyGyroscopeMEANYAverage                 : num  -0.906 -0.972 -0.994 -0.978 -0.953 ...
- $ frequencyBodyGyroscopeMEANZAverage                 : num  -0.916 -0.944 -0.981 -0.973 -0.941 ...
- $ frequencyBodyGyroscopeSDXAverage                   : num  -0.863 -0.954 -0.978 -0.955 -0.907 ...
- $ frequencyBodyGyroscopeSDYAverage                   : num  -0.518 -0.686 -0.886 -0.667 -0.445 ...
- $ frequencyBodyGyroscopeSDZAverage                   : num  -0.554 -0.489 -1 -1 -1 ...
- $ frequencyBodyGyroscopeMEANFreqXAverage             : num  -0.58 -0.626 -0.852 -0.993 -0.98 ...
- $ frequencyBodyGyroscopeMEANFreqYAverage             : num  -0.594 -0.53 -0.383 -0.298 -0.571 ...
- $ frequencyBodyGyroscopeMEANFreqZAverage             : num  0.609 0.543 0.404 0.383 0.63 ...
- $ frequencyBodyAccelerationMagMEANAverage            : num  -0.625 -0.555 -0.425 -0.464 -0.688 ...
- $ frequencyBodyAccelerationMagSDAverage              : num  0.64 0.568 0.447 0.543 0.745 ...
- $ frequencyBodyAccelerationMagMEANFreqAverage        : num  -0.3854 -0.4613 -0.394 0.0308 -0.2103 ...
- $ frequencyBodyBodyAccelerationJerkMagMEANAverage    : num  0.3503 0.414 0.3507 0.0226 0.2307 ...
- $ frequencyBodyBodyAccelerationJerkMagSDAverage      : num  -0.356 -0.401 -0.347 -0.147 -0.307 ...
- $ frequencyBodyBodyAccelerationJerkMagMEANFreqAverage: num  0.378 0.404 0.36 0.296 0.403 ...
- $ frequencyBodyBodyGyroscopeMagMEANAverage           : num  -0.542 -0.449 -0.393 -0.251 -0.204 ...
- $ frequencyBodyBodyGyroscopeMagSDAverage             : num  0.557 0.467 0.408 0.275 0.223 ...
- $ frequencyBodyBodyGyroscopeMagMEANFreqAverage       : num  -0.571 -0.484 -0.424 -0.297 -0.241 ...
- $ frequencyBodyBodyGyroscopeJerkMagMEANAverage       : num  0.583 0.498 0.436 0.314 0.256 ...
- $ frequencyBodyBodyGyroscopeJerkMagSDAverage         : num  -0.0846 -0.7392 0.4726 0.3214 0.2295 ...
- $ frequencyBodyBodyGyroscopeJerkMagMEANFreqAverage   : num  -0.0781 -0.4975 0.1378 -0.0401 -0.2974 ...
- $ angleTimeBodyAccelerationMeanGravityAverage        : num  -0.209 0.301 0.47 0.281 0.101 ...
- $ angleTimeBodyAccelerationJerkMeanGravityMeanAverage: num  0.0811 0.0775 0.0754 0.074 0.0542 ...
- $ angleTimeBodyGyroscopeMeanGravityMeanAverage       : num  0.003838 -0.000619 0.007976 0.028272 0.02965 ...
- $ angleTimeBodyGyroscopeJerkMeanGravityMeanAverage   : num  0.01083 -0.00337 -0.00369 -0.00417 -0.01097 ...
- $ angleXGravityMeanAverage                           : num  -0.9585 -0.9864 -0.9946 -0.1136 -0.0123 ...
- $ angleYGravityMeanAverage                           : num  -0.924 -0.981 -0.986 0.067 -0.102 ...
- $ angleZGravityMeanAverage                           : num  -0.955 -0.988 -0.992 -0.503 -0.346 ...
 
####Variable 1: SubjectIdentifier
- Description:  This is a unique identifier assigned to each person.
- Class:  numeric
- Values: 1 through 30 for the 30 subjects
- Unit of measure: none
- Notes:  These identifiers were provided directly from the raw data file with no transformations.

####Variable 2: ActivityDescription
- Description:  This is a description of the activity that the person was performing when the measurements were taken.
- Class:  character
- Values: one of six different activities, either LAYING, SITTING, STANDING, WALKING, WALKING_DOWNSTAIRS, WALKING_UPSTAIRS.
- Unit of measure: none
- Notes:  These descriptions were provided directly from the raw data file with no transformations other than replacing a numeric value with its corresponding activity.

####Variable 3-88: Measurements
- Description:  These are the measurements taken from the raw data that correspond to those for mean and standard deviation measurements. Specific variable names are listed above.
- Class:  numeric
- Values: Calculated mean values
- Unit of measure: same as the provided data- g’s for the accelerometer and rad/sec for the gyro;  g/sec and rad/sec/sec for the related jerks. 

##Sources
Sources cited in the material above:
Human Activity Recognition database
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
Google's R Style Guide was utilized for R standards
https://google-styleguide.googlecode.com/svn/trunk/Rguide.xml
Hadley Wickham paper on tidy data
http://vita.had.co.nz/papers/tidy-data.pdf