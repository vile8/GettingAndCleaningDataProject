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














