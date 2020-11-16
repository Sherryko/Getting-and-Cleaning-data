# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## load activity labels and features
library(data.table)

activitylabels <- fread("UCI HAR Dataset/activity_labels.txt",
                        col.names = c("label", "activity"))
features <- fread("UCI HAR Dataset/features.txt",
                  col.names = c("index", "feature"))
features_wanted <- grep("(mean|std)\\(\\)", features[, feature])
measurements <- features[features_wanted, feature]
measurements <- gsub("[()]", "", measurements)

## load train data
train <- fread("UCI HAR Dataset/train/X_train.txt")[, features_wanted, with = FALSE]
setnames(train, colnames(train), measurements)
train_activities <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = "Activity")
train_subjects <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = "Subject")
train <- cbind(train_subjects, train_activities, train)

## load test data
test <- fread("UCI HAR Dataset/test/X_test.txt")[, features_wanted, with = FALSE]
setnames(test, colnames(test), measurements)
test_activities <- fread("UCI HAR Dataset/test/Y_test.txt", col.names = "Activity")
test_subjects <- fread("UCI HAR Dataset/test/subject_test.txt", col.names = "Subject")
test <- cbind(test_subjects, test_activities, test)

## merge data sets
mergedDT <- rbind(train, test)

## label the data set with descriptive variable names
mergedDT[["Activity"]] <- factor(mergedDT[, Activity], levels = activitylabels[["label"]],
                                 labels = activitylabels[["activity"]])
names(mergedDT) <- gsub("^t", "time", names(mergedDT))
names(mergedDT) <- gsub("^f", "frequence", names(mergedDT))
names(mergedDT) <- gsub("-mean", "Mean", names(mergedDT))
names(mergedDT) <- gsub("-std", "Std", names(mergedDT))

## create a second tidy data set with the average of each variable for each activity and each subject
library(dplyr)
groupData <- mergedDT %>%
  group_by(Subject, Activity) %>%
  summarise_all(mean)
