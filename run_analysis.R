## Loads dplyr package

library(dplyr)

##working directory
setwd("~/Documents/R_code/Clean_data4/UCI HAR Dataset")

##Step 1
## reading the names of variables from features
features <- read.table("features.txt", stringsAsFactors=FALSE)
features <- cbind(features, names=gsub("()","",features$V2, fixed=TRUE), stringsAsFactors=FALSE)

## reading the data (all datasets separately)
traindt <- read.table("train/X_train.txt", col.names = features$names)
testdt <-  read.table("test/X_test.txt", col.names = features$names)
traindtY <- read.table("train/Y_train.txt", col.names = "activity")
testdtY <-  read.table("test/Y_test.txt", col.names = "activity")
subject_testdt <- read.table("test/subject_test.txt", col.names = "subject")
subject_traindt <- read.table("train/subject_train.txt", col.names = "subject")
activity_lbl <- read.table("activity_labels.txt", col.names = c("V1", "activity.name"))

## populating 2 datasets with all the measurements
testdt_full <- cbind(testdtY, subject_testdt, testdt)
traindt_full <- cbind(traindtY, subject_traindt, traindt)

## all the data is combined
full_dt <- rbind(traindt_full, testdt_full)

## Verify for NA's. 
any(is.na(full_dt))


## Step 2
## reading the mean and std deviation for each measurement. 
## using columns "activity_id","subject","mean" and "std"
full_dt_mean_std <- select(full_dt, activity, subject, contains("mean"), contains("std"))


## Step 3 
## Uses descriptive activity names to name the activities in the data set. 
## I merge the "full_data_mean_and_std" with the "activity_labels", where the 
## key in "full_data_mean_and_std"(by.x) is "activity" and the key in 
## "activity_labels" (by.y) is "V1".
full_dt_merged <- merge(activity_labels, full_data_mean_and_std, by.y = "activity",
                        by.x = "V1", sort = FALSE)

## removing column V1 because has the same data as activity name
full_dt_merged <- select(full_dt_merged,-V1)

## Step 4 Appropriately labels the data set with descriptive variable names
## renaiming col names and replacing "-" with "_"
colnames(full_dt_merged) <- gsub("[-]", "_", colnames(full_dt_merged))
colnames(full_dt_merged) <- gsub("Bodybody", "Body", colnames(full_dt_merged))
colnames(full_dt_merged) <- gsub("tBody", "TimeBody", colnames(full_dt_merged))
colnames(full_dt_merged) <- gsub("f", "Frequency", colnames(full_dt_merged))
colnames(full_dt_merged) <- gsub("Mag", "Magnitude", colnames(full_dt_merged))

## Step 5 From the data set in step 4, 
## creates a second, independent tidy data set with the average of each variable 
## For each activity and each subject. 

## dt_mean_gr is created to group activity.name and subject. 
## Next all variables are summarised
dt_mean_gr <- full_dt_merged %>% group_by(activity.name, subject) %>%
    summarise_each(funs(mean))
## Writng the final result in file dt_mean_gr.txt
write.table(dt_mean_gr, file="dt_mean_gr.txt", row.name=FALSE)