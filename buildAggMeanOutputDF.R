#install dependencies we will require
install.packages("data.table")
library(data.table)

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















