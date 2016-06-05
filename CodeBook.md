## This file is intended to automate the generation of the codebook for 
## the project. As opposed to manually writing out 60+ columns plus aggregates.

# read the names from the dataset
# for each name compare against the type and apply the description as provided in the features labels to make it abundantly clear
# what data we are providing

2 output datasets are created by running the run_analysis.R script:

1. dataStdMeanOnly : This dataset represent the first four requirements as described in the assignment:
	a. Merges the training and the test sets to create one data set.
	b. Extracts only the measurements on the mean and standard deviation for each measurement.
	c. Uses descriptive activity names to name the activities in the data set
	d. Appropriately labels the data set with descriptive variable names.

	To achieve these four goals it first calls: fetchAndUnpackData which:
		- creates a ./data directory if one does not exist
		- downloads the dataset from: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
		- calls unzip() to extract the data into the ./data/UCI HAR Dataset/ directory
		- if successful it runs the functions "createNamedDataSet()" which populates the dataStdMeanOnly variable as a dataframe.

	The createNamedDataSet() function performs the following tasks to create the required dataset and stores the output in dataStdMeanOnly:
		- loads data for labels using read.table() with arguments for stringsAsFactors = FALSE as a dataframe from:
			- ./data/UCI HAR Dataset/features.txt for feature labels
		- creates a columnNamesList vector against the V2 of the features dataframe
		- uses the data from the columnNamesList vector as column labels argument to read.table(), as well as stringsAsFactors = FALSE against:
			- ./data/UCI HAR Dataset/test/X_test.txt for test data points
			- ./data/UCI HAR Dataset/train/X_train.txt for train data points
		- At this point we have the 2 datasets in memory with properly verbose feature labels
		- uses rbind() to merge the datapoints from test and train together into 1 dataset named "mergedData"
		- frees memory using rm() against datasets that will no longer be used
		- creates a vector named colsNamesStdMeansOnly using grep("-std\\(|-mean\\(") to identify which columns we wish to leverage as our final outputs
		- subsets against the "mergedData" using the colsNamesStdMeansOnly vector to reduce the dataset and stores the output in "processedData"
		- frees memory one more time for unused objects
		- returns the processedData dataframe which is appropriately labeled and reduced 

	The returned data is a dataframe with: 10299 obs. of  66 variables
		- These variables are all the same as what is described in the ./data/UCI HAR Dataset/features.txt and are all numeric

2. averagedStdMeanOnlyActivities : This dataset represents the 5th requirement as described in the assignment, and leverages the returned data stored in dataStdMeanOnly to do so:
	e. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

	To achieve this goal it calls: buildAggMeanOutputDF(dataStdMeanOnly) which:
		- loads the additional datasets for activity labels using read.table with the argument for stringsAsFactors = FALSE:
			- ./data/UCI HAR Dataset/test/y_test.txt
			- ./data/UCI HAR Dataset/train/y_train.txt
		- this creates a dataset matching the number of observations for each set respectively. 
		- Then concatenates the datasets together using c(testDataLabels$V1, trainDataLabels$V1) and assign the result to labelIDs
			creating a Int vector of length 10,299 entries, which matches in order and length the dataStdMeanOnly
		- Then the column is added using cbind to the dataStdMeanOnly internally to the function (the original is unchanged)
		- The data frame passed in (dataStdMeanOnly with the additional activity id column) is then converted to a data table and
			this is then assigned to the variable named fDataWithLabels
		- Inside the function is another function for simple nameswitching based on the descriptive text given in:
			data/UCI HAR Dataset/activity_labels.txt
		- This function is then applied against the activity ID column "labelIDs" to create a new column with the names of each activity to 
			the fDataWithLabels data.table named "StrLabel" which is the activity fullname as described in the activity_labels.txt
		- set a key(index) in the data.table fDataWithLabels against StrLabel to speed up group by processing
		- create a list of the column names we will be massaging later without the labelIDs or StrLabel names in it using the names() function 
			against a %in% negatively matched call and store the output in a variable named colNames
		- create our return data.table by performing an aggregation utilizing lapply, the special name ".SD", grouped by StrLabel, and specifying the 
			columns we wish to include using the colNames var we just created. Store the output of this aggregate mean operation to: returnData
		- create an internal function which takes the colNames and creates a vector using "sub()" and "paste" to remove whitespace from the column
			names, and prefix them with AVG- and store it in avgColNames
		- Update the returnData table with the new prefixed names in avgColNames and update the column headers for our return data using:
			setnames()

	The returned data is a data.table with: 

