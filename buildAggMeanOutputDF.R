#install dependencies we will require
library(data.table)

#create buildAggMeanOutputDF function
	#with args:
	# - origData : Data Frame representing the processed data for means and std deviations from step 4
	#returns:
	# data table grouped by activity and the averages from previous variables as observations 
	# with "AVG-" appended to indicate their new purpose
buildAggMeanOutputDF <- function(origData, orderBySubject){

	#determine if we want to order by subject or activity
	if(orderBySubject == 1){
		#this is the requested default as described in the assignment. 
		#this aggregates by subject first, which will create roughly 180 observations
		orderByUse <- c("ACTIVITY", "SUBJECT")
	} else if(orderBySubject == 2){
		#this is actually my FAVORITE, as it breaks down the output by simply providing the aggregate averages across all observations GROUPED only by the
		#activities. This seems much more meaningful than any of the others, but was not what was requested.
		orderByUse <- c("ACTIVITY")
	} else if(orderBySubject == 3) {
		#simply replicates the original dataset as the avg is applied to each subject, and activity, which would include every observation
		orderByUse <- c("SUBJECT", "ACTIVITY")
	}
	
	#switch the numbers for the activity labels to names
	switchNames <- function(labelID) {
		#ordering provides proper index
		activityLabels <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING")

		#return indexed value
		return(activityLabels[labelID])
	}

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

	#setup the file location variables
	testSubjectLabelsFH <- "./data/UCI HAR Dataset/test/subject_test.txt"
	trainSubjectLabelsFH <- "./data/UCI HAR Dataset/train/subject_train.txt"

	#concatenate the data together (since above we selected out columns but all rows were maintained, these labels will match in the same order of combination -> c(test,train))
	dataLabelIDs <- c(testDataLabels$V1, trainDataLabels$V1)

		#created:
		#> str(fullDataLabels)
		# int [1:10299] 5 5 5 5 5 5 5 5 5 5 ...
		#also I am not going to remove labelIDs when we are done with it as we will use it to manage groupings
		#in a later function

	#create a new vector with the name for each data label instead of its int identifier
	namedDataLabels <- sapply(dataLabelIDs, switchNames)

	#grab the labels for the training data
	testSubjectLabels <- read.table(testSubjectLabelsFH,stringsAsFactors = FALSE)
	trainSubjectLabels <- read.table(trainSubjectLabelsFH,stringsAsFactors = FALSE)

	#repeat for subject data against the observations 
	subjectLabelIDs <- c(testSubjectLabels$V1, trainSubjectLabels$V1)

	#DEPRECATED FUNCTIONS#
	#now add this column to our existing dataset so we have labels which we can use to subset on
	#fDataWithLabels <- data.table(cbind(origData,dataLabelIDs))
	#origWithDataLabels <- cbind(namedDataLabels,origData)
	#origWithDataAndSubject <- cbind(subjectLabelIDs, origWithDataLabels)

	#create a new data table with subjects and activities applied as the first 2 columns
	fDataWithLabels <- data.table(ACTIVITY=namedDataLabels,
					SUBJECT=subjectLabelIDs,
					origData)

	#another nice thing about the data table package is you can see how much memory it takes up:
	#     NAME              NROW NCOL MB COLS                                                                             KEY
	#[1,] fDataWithLabels 10,299   68  6 tBodyAcc.mean...X,tBodyAcc.mean...Y,tBodyAcc.mean...Z,tBodyAcc.std...X,tBodyAcc.    
	#Total: 6MB
	#so... 6MB for 10,299 observations across 68 variables. Not too shabby.

	#set a key(index) to make sorting faster, but optimizations can also have unintended side-effects. Skipping for now.
	#setkey(fDataWithLabels,SUBJECT)
	#setkey(fDataWithLabels,ACTIVITY)

	#column names without Activity and Subject labels to use for averaging aggregation
	colNames <- names(fDataWithLabels[1,!names(fDataWithLabels) %in% orderByUse, with=FALSE])

	#first start by creating the means of each grouping 
	#by StrLabel (Walking, Laying, Sitting etc... 
	#and this can all be done in one simple line:
	returnData <- fDataWithLabels[,lapply(.SD,mean) ,by=orderByUse, .SDcols=colNames]

	avgColNames <- c("Activity","Subject")

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















