===========================================================
Getting and cleaning data Assignment Week 4 assignment 
===========================================================
Version 1.0
===========================================================
James McDermott
james@vaniv.com
===========================================================
Assignment: Getting and Cleaning Data Course Project
===========================================================

This assignment indicated we need to achieve 4 core objectives
	- The data set is tidy (as per the definition)
	- The github repo (project) contains the required scripts
	- The github repo (project) contains a codebook that describes the changes to the codebooks
	  of the initial dataset, and describes the variables, summaries calculated, along with units, and any other relevant information
	- This readme file, which should be clear and understandable

This assignment requires the above be generated based on the dataset provided here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip	

This assignment requires we provide a script named: run_analysis.R which modifies the zipped data to provide:
	- 1 Merges the training and the test sets to create one data set.
	- 2 Extracts only the measurements on the mean and standard deviation for each measurement.
	- 3 Uses descriptive activity names to name the activities in the data set
	- 4 Appropriately labels the data set with descriptive variable names.
	- 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

===========================================================

My script for run_analysis.R can be run by loading it with: 
	source("run_analysis.R")

The run_analysis.R script:
	- will create 2 artifacts in memory which you can leverage:
		- dataStdMeanOnly -> which represents the data transformed for the first 4 requirements as listed above
		- averagedStdMeanOnlyActivities -> which represents the data for the 5th requirement as listed above
	- is heavily documented inline
	- will automatically create the ./data directory respective to the session workspace
	- will automatically download and unzip the dataset
	- will only execute the transformations if the dataset has downloaded and unpacked appropriately
	- contains 3 functions:
		- fetchAndUnpack() : download and unpack the UCI data source
		- createNamedData() : which extracts the std and mean columns from the test and train data, merges the datasets, and renames the column variables
				      to be more readable
		- buildAggMeanOutputDF() : which creates the column averages grouped by activity, and then renames the columns to add the "AVG-" prefix to each
					   to maintain readability
	- utilizes the following features explained in this class:
		- subsetting for data selection, 
		- binding for merges, 
		- grep for subsetting
		- data.table package usage for performing aggregation and grouping 

===========================================================

Again, please see the run_analysis.R script itself, for more granular documentation
as each operation is explained, including example output for many of the advanced transformations

===========================================================

