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

source("fetchAndUnpackData.R")
source("createNamedDataSet.R")
source("buildAggMeanOutputDF.R")

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

