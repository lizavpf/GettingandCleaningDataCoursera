"""
Assignment for Getting and Cleaning Data
"""
library(reshape2)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
              "original_data.zip", method="curl")
unzip("original_data.zip")

activityLabels = read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] = as.character(activityLabels[,2])
features = read.table("UCI HAR Dataset/features.txt")
features[,2] = as.character(features[,2])

featuresWanted = grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names = features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names = gsub('[-()]', '', featuresWanted.names)

training = read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainingActivities = read.table("UCI HAR Dataset/train/Y_train.txt")
trainingSubjects = read.table("UCI HAR Dataset/train/subject_train.txt")
training = cbind(trainingSubjects, trainingActivities, training)

test = read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities = read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects = read.table("UCI HAR Dataset/test/subject_test.txt")
test = cbind(testSubjects, testActivities, test)

togetherData = rbind(training, test)
colnames(togetherData) = c("subject", "activity", featuresWanted.names)
togetherData$activity = factor(togetherData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
togetherData$subject = as.factor(togetherData$subject)
togetherData.melted = melt(togetherData, id = c("subject", "activity"))
togetherData.mean = dcast(togetherData.melted, subject + activity ~ variable, mean)
write.table(togetherData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
