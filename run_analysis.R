# run_analysis.R file created to process the data collected from the
# accelerometers from the Samsung Galaxy S smartphone. Full explanation
# of the data files is found from the site at
# http://archive.ics.uci.edu/ml/datasets/Smartphone-Based+Recognition+of+Human+Activities+and+Postural+Transitions

# Assumptions:
# Data is downloaded from the site, unzipped and placed in a folder in the working directory
# The name of the folder that contains the dataset is "UCI HAR Dataset"
# The name of this folder will be changed as part of processing 
# to "data" (because I am lazy ;-) and didnt want to type the full name every time)
# The function loads the dplyr package as part of its execution. Notices to this effect 
# may be posted to the console when the function is executed.

# To run the analysis:
# 1. source the run_analysis.R file
# 2. at the console enter: 
#    GenerateFile()
# 3. NOTE file is created in the data directory and is named
#   Variable_Average_By_User.txt


GenerateFile <- function() {
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
  
  # ***** CLEAN UP DATA AND DETERMINE COLUMNS AND ROWS TO USE *****
  # use features data frame to find names, columns to keep
  finalColumns <- features[grep("mean|std",features$V2, ignore.case = TRUE),]
  
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
  #first row of the data set is the header row
  write.table(dataGrouped, row.names=FALSE, file="./data/Variable_Average_By_User.txt", sep="|")

} # end of function

