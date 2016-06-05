fetchAndUnpackData <- function() {
	#download the zip file to the ./data directory and extract the zip
	if(!file.exists("./data")){
		dir.create("./data")
	}

	#set the file to download
	fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileUrl, destfile = "./data/UCIDATA.zip", method = "curl")

	#unzip the file to the ./data directory
	unzip("./data/UCIDATA.zip", exdir = "./data")

	if(file.exists("./data/UCI HAR Dataset")){
		return(TRUE)
	} else {
		return(FALSE)
	}
}
