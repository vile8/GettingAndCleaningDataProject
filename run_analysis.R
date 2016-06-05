## This script is intended to perform the following tasks:
## Download and unzip the data required for the UCI Dataset of telemetry 
## against activities (Sleeping, walking, etc...) 
## - Merge the training and testing data
## - Label it appropriately against the features file
## - Reduce the data to mean and std deviations only for each observation
## - load this into a dataframe (dataStdMeanOnly) 
## - Create a secondary independant dataset that averages each column (variable) against activities
##   which will provide activities as the observations, and the averages of vars as the variables
##   in a dataframe (activitiesStdMeanOnlyAverages)
## - Perform cleanup along the way so as not to waste memory space
## - More is described inline below, as well as potential optimizations

#install dependencies we will require
install.packages("data.table")
library(data.table)

#fetch and unpack our data first, and handle problematic conditions
if(fetchAndUnpackData()){

	##Requirements 1-4
	#1:Merge training and test data sets to create ONE data set
	#2:Extract only the measurements on the MEAN and STANDARD DEVIATION for each measurement
	#3:Use descriptive names to name the activities in the data set....?
	#4:Appropriately label the dataset with descriptive variable names
	dataStdMeanOnly <- createNamedDataSet()

	##Requirements for item 5
	#5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
	averagedStdMeanOnlyActivities <- buildAggMeanOutputDF(dataStdMeanOnly)

} else {
	print("Problem downloading and extracting data from zip file!")
}

fetchAndUnpackData <- function() {
	#download the zip file to the ./data directory and extract the zip
	if(!file.exists("./data")){
		dir.create("./data")
	}
	fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileUrl, destfile = "./data/UCIDATA.zip", method = "curl")
	unzip("./data/UCIDATA.zip", exdir = "./data")
	if(file.exists("./data/UCI HAR Dataset")){
		return(TRUE)
	} else {
		return(FALSE)
	}
}

#wrap data processing in a function to make it more readable
createNamedDataSet <- function() {


	#Load variable names as described in the features.txt file.
	#to create clear and meaningful labels these will be used on import to label the 
	#column names appropriately to start with
	featuresFH <- "./data/UCI HAR Dataset/features.txt"
	features <- read.table(featuresFH, stringsAsFactors = FALSE)

	#create a vector with the column names from the features list
	columnNamesList <- features$V2

	#next create file handles to the test and train data sets
	testDataFH <- "./data/UCI HAR Dataset/test/X_test.txt"
	trainDataFH <- "./data/UCI HAR Dataset/train/X_train.txt"

	#now use the labels provided 
	testData <- read.table(testDataFH, stringsAsFactors = FALSE, col.names = columnNamesList)
	trainData <- read.table(trainDataFH, stringsAsFactors = FALSE, col.names = columnNamesList)

	#use these values to join the labels to the dataset
	#this provides nicely labeled data sets to start, now we just need to simply merge them
	mergedData <- rbind(trainData,testData)

	#free up memory so we dont have large artifacts wasting space
	rm(testData)
	rm(trainData)
	rm(features)

	# grep the list for mean and median column names to reduce the dataset to only the columns requested 
	colsNamesStdMeanOnly <- grep("-std\\(|-mean\\(",columnNamesList)

	### Now to create the final dataset that represents:
	### 1: The merged train and test datasets
	### 2: Properly labeled columns with descriptive names as found in the features.txt per column
	### 3: ONLY the standard deviation and mean columns
	#Use these to subset the main table into a new table with just the items requested
	processedData <- mergedData[,colsNamesStdMeanOnly]

		### ***ALTERNATIVE OPTIMIZATION USING THIS METHOD***
		### This process could easily reduce memory overhead and function just fine by opening the table 1 chunk at a time
		### instead of all at once. This would allow the data to be importer, rowbound, labeled, and reduced in clean small
		### consumable chunks

		### ***OR...***
		### This process could likely be optimized using the column ids pulled from 
		### the features list by number with grep and then imported using dplyr on import, but this implementation is effective
		### at creating the correct data regardless


	###Thats it for part 1. processedData represents everything requested by the assignment in a tidy dataset
	###Example output:
	###> str(dataStdMeanOnly)
	###'data.frame':	10299 obs. of  66 variables:
	### $ tBodyAcc.mean...X          : num  0.289 0.278 0.28 0.279 0.277 ...
	### $ tBodyAcc.mean...Y          : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
	### $ tBodyAcc.mean...Z          : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
	### $ tBodyAcc.std...X           : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
	### $ tBodyAcc.std...Y           : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
	### $ tBodyAcc.std...Z           : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
	### $ tGravityAcc.mean...X       : num  0.963 0.967 0.967 0.968 0.968 ...
	### $ tGravityAcc.mean...Y       : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
	### ...
	#and again, free up space in memory
	rm(mergedData)
	rm(colsNamesStdMeanOnly)

	return(processedData)
}

#create buildAggMeanOutputDF function
	#with args:
	# - origData : Data Frame representing the processed data for means and std deviations from step 4
	#returns:
	# data table grouped by activity and the averages from previous variables as observations 
	# with "AVG-" appended to indicate their new purpose
buildAggMeanOutputDF <- function(origData){

	# Get the labels from the train and test sets and merge them to the data
	# Labels are stored in the y_<test|train> files. It will be easiest to map these initially on import using cbind to add the columns

	#setup the file location variables
	testDataLabelsFH <- "./data/UCI HAR Dataset/test/y_test.txt"
	trainDataLabelsFH <- "./data/UCI HAR Dataset/train/y_train.txt"

	#grab the labels for the training data
	testDataLabels <- read.table(testDataLabelsFH,stringsAsFactors = FALSE)
	trainDataLabels <- read.table(trainDataLabelsFH,stringsAsFactors = FALSE)

		#created:
		#> str(trainDataLabels)
		#'data.frame':	7352 obs. of  1 variable:
		# $ V1: int  5 5 5 5 5 5 5 5 5 5 ...
		#> str(testDataLabels)
		#'data.frame':	2947 obs. of  1 variable:
		# $ V1: int  5 5 5 5 5 5 5 5 5 5 ...

	#concatenate the data together (since above we selected out columns but all rows were maintained, these labels will match in the same order of combination -> c(test,train))
	labelIDs <- c(testDataLabels$V1, trainDataLabels$V1)

		#created:
		#> str(fullDataLabels)
		# int [1:10299] 5 5 5 5 5 5 5 5 5 5 ...
		#also I am not going to remove labelIDs when we are done with it as we will use it to manage groupings
		#in a later function

	#now add this column to our existing dataset so we have labels which we can use to subset on
	fDataWithLabels <- data.table(cbind(origData,labelIDs))

	#now we have all the data we need to separate the chunks, but numbers are ugly, so lets switch the numbers for the activity labels to names
	switchNames <- function(labelID, activityLabels) {
		#ordering provides proper index
		activityLabels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")

		#return indexed value
		activityLabels[labelID]
	}

	#And using the data.table package we call our function for each observation against the labelID column and add an entry to the column StrLabel that
	#represents the element
	#this is one of the few functions I've seen that mutates the data structure without reassignment. 
	fDataWithLabels[,StrLabel:=switchNames(labelIDs)]

	#output from str (just the entry for StrLabel):
	#$ StrLabel                   : chr  "STANDING" "STANDING" "STANDING" "STANDING" ...

	#another nice thing about the data table package is you can see how much memory it takes up:
	#     NAME              NROW NCOL MB COLS                                                                             KEY
	#[1,] fDataWithLabels 10,299   68  6 tBodyAcc.mean...X,tBodyAcc.mean...Y,tBodyAcc.mean...Z,tBodyAcc.std...X,tBodyAcc.    
	#Total: 6MB
	#so... 6MB for 10,299 observations across 68 variables. Not too shabby.

	#set a key(index) to make sorting faster
	setkey(fDataWithLabels,StrLabel)

	#column names we want to turn into observations
	colNames <- names(fDataWithLabels[1,!names(fDataWithLabels) %in% c("StrLabel","labelIDs"), with=FALSE])

	#first start by creating the means of each grouping 
	#by StrLabel (Walking, Laying, Sitting etc... 
	#and this can all be done in one simple line:
	returnData <- fDataWithLabels[,lapply(.SD,mean) ,by=StrLabel, .SDcols=colLabels]

	avgColNames <- c()

	#last we want to rename the columns with the "AVG" handle as a prefix to indicate they are averages(means) 
	for(aColName in colNames){
		newColName <- paste(c("AVG"), sub("^\\s+", "", aColName), sep="-")
		avgColNames <- append(avgColNames, newColName)
	}	 

	#column names have been adjusted to represent:
	#[1] "AVG-tBodyAcc.mean...X"           "AVG-tBodyAcc.mean...Y"           "AVG-tBodyAcc.mean...Z" ...
	#now apply to our return data set	
	setnames(returnData, avgColNames)

	return(returnData)
}















