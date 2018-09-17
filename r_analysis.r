## reshape2 is an R package written by Hadley Wickham that makes it easy to transform data between wide and long formats
install.packages("reshape2")
library(reshape2)



## Download and unzip the data

if (!file.exists(Projectfile))
{
  projectfileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(projectfileURL, Projectfile, method="curl")
} 

if (!file.exists("UCI HAR Dataset")) 
{ 
  unzip(Projectfile) 
}

# Read from text files activity labels 
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])

# Read from text files features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresneeded <- grep(".*mean.*|.*std.*", features[,2])
featuresneeded.names <- features[featuresneeded,2]

featuresneeded.names = gsub('-mean', 'Mean', featuresneeded.names)
featuresneeded.names = gsub('-std', 'Std', featuresneeded.names)
featuresneeded.names <- gsub('[-()]', '', featuresneeded.names)

featuresneeded.names<-gsub("^t", "time", featuresneeded.names)
featuresneeded.names<-gsub("^f", "frequency", featuresneeded.names)
featuresneeded.names<-gsub("Acc", "Accelerometer", featuresneeded.names)
featuresneeded.names<-gsub("Gyro", "Gyroscope", featuresneeded.names)
featuresneeded.names<-gsub("Mag", "Magnitude", featuresneeded.names)
featuresneeded.names<-gsub("BodyBody", "Body", featuresneeded.names)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresneeded]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")

# binding train Subjects and activities
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresneeded]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")

# binding test Subjects and activities
test <- cbind(testSubjects, testActivities, test)

# combine datasets train and test
combinedData <- rbind(train, test)
colnames(combinedData) <- c("subject", "activity", featuresneeded.names)

# conversion to factors
combinedData$activity <- factor(combinedData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
combinedData$subject <- as.factor(combinedData$subject)

combinedData.melted <- melt(combinedData, id = c("subject", "activity"))
combinedData.mean <- dcast(combinedData.melted, subject + activity ~ variable, mean)

#create tidy.txt file
write.table(combinedData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
