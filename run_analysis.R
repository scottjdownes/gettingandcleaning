# Here we grab the data, unzip it, and read it into R.

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","./data/dataset.zip", "curl")
unzip("./data/dataset.zip", exdir="./data")

# Let's get the right names for these features.
# We'll use these later to create meaningful column names.
featureNames <- read.table("./data/UCI HAR Dataset/features.txt")

# We also want to get the appropriate activity labels
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

# We first get the subject identifiers and give that an appropriate column name
testsubjectdata <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
names(testsubjectdata) <- "subject"

# Then we get the activity ID and add the appropriate text for that ID from the activityLabels
testydata <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
names(testydata) <- "activity"
testydata$activityName <- factor(testydata$activity, activityLabels$V1, activityLabels$V2)

# And then the actual measurements. We give them feature names based on an earlier step above.
testxdata <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
names(testxdata) <- featureNames[,2]

# Now we're almost done with the test data, let's narrow down to 
# the columns we want where we have std() or mean() measurements
# My interpretation is to capture features that include the literal "std()" or "mean()"
colIndexes <- c(grep("std()", names(testxdata)), grep("mean()", names(testxdata)))
testxdataNarrowed <- testxdata[,colIndexes] 

# Now let's put it all together on the test data
testdata <- cbind(testsubjectdata, testydata, testxdataNarrowed)

# We're going to repeat the steps above for the training data set now.
trainsubjectdata <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
names(trainsubjectdata) <- "subject"

trainydata <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
names(trainydata) <- "activity"
trainydata$activityName <- factor(trainydata$activity, activityLabels$V1, activityLabels$V2)

trainxdata <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
names(trainxdata) <- featureNames[,2]

# Just as before, let's narrow down to 
# the columns we want where we have std() or mean() measurements
colIndexes <- c(grep("std()", names(trainxdata)), grep("mean()", names(trainxdata)))
trainxdataNarrowed <- trainxdata[,colIndexes] 

traindata <- cbind(trainsubjectdata, trainydata, trainxdataNarrowed)

# And at long last, we now can row bind the test and training data sets
fulldata <- rbind(testdata, traindata)

# Now we have a full set of data, appropriately labeled and narrowed.
# Time to create an aggregated view of the data, with means for each measurement.
# These will be ordered by subject, then by activity name.

aggregateData <- aggregate(fulldata[,4:82], by=list(subject = fulldata$subject, activityName = fulldata$activityName), mean)
aggregateDataSorted <- aggregateData[order(aggregateData$subject, aggregateData$activity),]

# Finally, we will write out this sorted data to a table to make it easy to import back into R.
write.table(aggregateDataSorted, "./data/finaloutput.txt", row.name = FALSE)

