===========================================================
Getting and cleaning data Week 4 Project 
===========================================================
Version 1.0
===========================================================
James McDermott
james@vaniv.com
===========================================================
Assignment: Getting and Cleaning Data Course Project
===========================================================

This assignment indicated we need to achieve 4 core objectives

	* The data set is tidy (as per the definition)
	* The github repo (project) contains the required scripts
	* The github repo (project) contains a codebook that describes the changes to the codebooks
	  of the initial dataset, and describes the variables, summaries calculated, along with units, and any other relevant information
	* This readme file, which should be clear and understandable

This assignment requires the above be generated based on the dataset provided here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip	

This assignment requires we provide a script named: run_analysis.R which modifies the zipped data to provide:

	1. Merges the training and the test sets to create one data set.
	2. Extracts only the measurements on the mean and standard deviation for each measurement.
	3. Uses descriptive activity names to name the activities in the data set
	4. Appropriately labels the data set with descriptive variable names.
	5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In addition to creating the run_analysis.R file there are 3 additional files to make it simpler to (re)use components of this project and make it more readable.
These scripts will automatically be sourced by running the main run_analysis.R file so long as they are in the same directory and include:
	
	1. buildAggMeanOutputDF.R 
	2. createNamedDataSet.R   
	3. fetchAndUnpackData.R

===========================================================

Before you being it is NECESSARY to ensure the data.tables package is installed:
	install.packages("data.table")

My script for run_analysis.R can be run by loading it with: 
	source("run_analysis.R")

The run_analysis.R script:

	* will create 2 artifacts in memory which you can leverage:
		* dataStdMeanOnly -> which represents the data transformed for the first 4 requirements as listed above
		* averagedStdMeanOnlyActivities -> which represents the data for the 5th requirement as listed above
	* will write the file: summarized_data.txt -> which represents the data from averagedStdMeanOnlyActivities
		* this data includes the subject, the activity, and each variable described in the original data set averaged(mean) by c(activity,subject) as requested
	* is heavily documented inline
	* provides ALTERNATIVE aggregate behaviors for viewing the data in alternate ways
	* will automatically create the ./data directory respective to the session workspace
	* will automatically download and unzip the dataset
	* will only execute the transformations if the dataset has downloaded and unpacked appropriately
	* contains 3 functions:
		* fetchAndUnpack() : download and unpack the UCI data source
		* createNamedData() : which extracts the std and mean columns from the test and train data, merges the datasets, and renames the column variables
				      to be more readable
		* buildAggMeanOutputDF() : which creates the column averages grouped by activity, and then renames the columns to add the "AVG-" prefix to each
					   to maintain readability
	* utilizes the following features explained in this class:
		* subsetting for data selection, 
		* binding for merges, 
		* grep for subsetting
		* data.table package usage for performing aggregation and grouping 

The fetchAndUnpackData.R script:
	
	* provides the function fetchAndUnpackData which returns a boolean value
	* Downloads places in the ./data directory the UCI dataset
	

The createNamedDataSet.R script:
	
	* provides the function createNamedDataSet
	* is used to create the dataStdMeanOnly dataframes 
	* loads and merges the train and test datasets
	* applies labels
	* reduces to std() and mean() only columns
	* is heavily documented inline

The buildAggMeanOutputDF.R script:

	* provides the functionality buildAggMeanOutputDF which returns the aggregated dataset
		* buildAggMeanOutputDF takes alternate arguments to alter the behavior of the aggregation for viewing different possible results
	* is used to create the mean of all variables in a new dataset 
	* with proper renaming 
	* grouping by subject then activity labels
	* is heavily documented inline

===========================================================

Again, please see the run_analysis.R script itself, for more granular documentation
as each operation is explained, including example output for many of the advanced transformations

===========================================================

