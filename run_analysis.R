# run_analysis.R script does the following

# 1. Merges the training and the test sets to create one data set
# 2. Extracts only the measurements on the mean and standard deviation for each measurement
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

# Loading R packages needed for this script
library(data.table)
library(plyr)
library(dplyr)

# Download and unzipping of datasets
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "C:/Users/perrecha/Documents/Getting and cleaning data/Getting and Cleaning Data Course Project/dataset.zip")
HAR_dataset <- unzip("C:/Users/perrecha/Documents/Getting and cleaning data/Getting and Cleaning Data Course Project/dataset.zip")

# Reading trainings tables:
Subject_train.data <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_train.data <- read.table("./UCI HAR Dataset/train/x_train.txt")
y_train.data <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Reading testing tables:
Subject_test.data <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x_test.data <- read.table("./UCI HAR Dataset/test/x_test.txt")
y_test.data <- read.table("./UCI HAR Dataset/test/y_test.txt")

# Reading features:
HAR_features <- read.table("./UCI HAR Dataset/features.txt")

# Assignment of column names
colnames(x_train.data) <- HAR_features[,2]
colnames(y_train.data) <-"activityId"
colnames(Subject_train.data) <- "subjectId"

colnames(x_test.data) <- HAR_features[,2]
colnames(y_test.data) <-"activityId"
colnames(Subject_test.data) <- "subjectId"

# 1. Merging training and test sets
train.data <- cbind(Subject_train.data, y_train.data, x_train.data)
test.data <- cbind(Subject_test.data, y_test.data, x_test.data)
Merged_train_test <- rbind(train.data, test.data)

# 2. Extract mean and standard deviation for each measurement
mean_std.measurements <-Merged_train_test[,grepl("subjectId|activityId|mean|std",colnames(Merged_train_test))]

# 3. Use descriptive activity names to name the activities in the data set
HAR_activity.lables <- read.table("./UCI HAR Dataset/activity_labels.txt")
colnames(HAR_activity.lables) <- c("activityId_2","activityType")
HAR_mean_std <- merge.data.frame(mean_std.measurements, HAR_activity.lables, by.x  = "activityId", by.y = "activityId_2")
HAR_mean_std <- HAR_mean_std[, c(2, 1, 82, 3:81)]

# 4. Appropriately labels the data set with descriptive variable names
names(HAR_mean_std)<-gsub("Acc", "Accelerometer", names(HAR_mean_std))
names(HAR_mean_std)<-gsub("Gyro", "Gyroscope", names(HAR_mean_std))
names(HAR_mean_std)<-gsub("Mag", "Magnitude", names(HAR_mean_std))
names(HAR_mean_std)<-gsub("BodyBody", "Body", names(HAR_mean_std))
names(HAR_mean_std)<-gsub("^t", "time", names(HAR_mean_std))
names(HAR_mean_std)<-gsub("^f", "frequency", names(HAR_mean_std))

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
tydy_Merged_train_test <- ddply(HAR_mean_std, c("subjectId","activityId", "activityType"), numcolwise(mean))
write.csv(tydy_Merged_train_test, file="tidydata.csv")

