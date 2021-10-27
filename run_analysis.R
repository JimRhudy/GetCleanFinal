# submitted by Jim Rhudy, 10/26/2021
# I acknowledge my use of the following resource linked from within the MOOC materials:
# https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/
# 
# A full description of the dataset is available at: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# 
# The data are available at: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## Setup

library(tidyverse)

#assemble downloaded data and files to project folder
#copy files from nested folders to project folder avoiding file path white space
#setwd in tool bar to project folder
train<-read.table("X_train.txt")  #training subset
#dim(train)     #   7352  561    corresponds to expected 70% of total instances
test<-read.table("X_test.txt")    #testing subset
#dim(test)      #  2947  561    corresponds to expected 30% of total instances


## Step One

#1.	Merges the training and the test sets to create one data set.

# Windows users open files in notepad++ to prepare for the following steps

#label rows in train 
subjectTrain<-read.table("subject_train.txt") #prepare to label subjects
activityTrain<-read.table("y_train.txt")      #prepare to label activities
trainLabelled<-cbind(subjectTrain, activityTrain, train) #label all rows

#label rows in test as above
subjectTest<-read.table("subject_test.txt")
activityTest<-read.table('y_test.txt')
testLabelled<-cbind(subjectTest, activityTest, test)

#rowbind train and test to entire combined dataset
entireRowLabelled<-rbind(trainLabelled, testLabelled)   
#I now have the data combined with rows labelled

#label columns in combined dataset
givenColumnNames<-read.table("features.txt")
fullColumnNames<-c("subject", "activity", givenColumnNames$V2)

#length(fullColumnNames) #563
#ncol(entireRowLabelled) #563
entireFullyLabelled<-rbind(fullColumnNames, entireRowLabelled)
#dim(entireFullyLabelled) #10300   563
#entireFullyLabelled[1:5, 1:5]

## Step Two

#2.	Extracts only the measurements on the mean and standard deviation for each measurement.

#table(grepl("mean", entireFullyLabelled))  #inspect subset of "mean" 
meanList<-grep("mean", entireFullyLabelled) #list all columns referring to mean
#meanList

  
#table(grepl("std", entireFullyLabelled))   #inspect subset of "std
stdList<-grep("std", entireFullyLabelled)   #list columns referring to std
#stdList

meanCols<-entireFullyLabelled[, meanList]   #select columns referring to mean
#meanCols[1:5, 1:4]

stdCols<-entireFullyLabelled[, stdList]     #select columns referring to std
#stdCols[1:5, 1:4]

selectEntire<-cbind(meanCols, stdCols)      #limit data to columns of interest
#selectEntire[1:5, 1:4]
#dim(selectEntire) 

#relabel rows in selectEntire

#relabel subjects
# nrow(subjectTrain) #7352
# nrow(subjectTest)  #2947
nameSubject<-("subject")                    #prepare a column name
subjectEntire<-rbind(nameSubject, subjectTrain, subjectTest)
#nrow(subjectEntire) #10300, matching length of dataframe to be labelled

#relabel activities
# nrow(activityTrain) #7352
# nrow(activityTest)  #2947
nameActivity<-("activity")
activityEntire<-rbind(nameActivity, activityTrain, activityTest)
#nrow(activityEntire) #10300, matching length of dataframe to be labelled

#relabel all rows of selectEntire
#ncol(selectEntire) #79
labelledEntire<-cbind(subjectEntire, activityEntire, selectEntire)
#ncol(labelledEntire) #81
#labelledEntire[1:5, 1:5]          #inspect result of procedure to label rows
#labelledEntire[10298:10300, 1:5]  #inspect result of procedure to label rows
#dim(labelledEntire)               #10300    81

## Steps Three and Four
 
#3.	Uses descriptive activity names to name the activities in the data set
#4.	Appropriately labels the data set with descriptive variable names.

# head(labelledEntire)  #inspect data pre-transformation
# tail(labelledEntire)

library(janitor)  #prepare for row_to_names to replace V1, V2, etc.

# rename columns meaningfully
relabelledEntire<-labelledEntire%>%
  janitor::row_to_names(1)
#labelledEntire[1:5, 1:4]

#rename activity meaningfully
activityDescriptive<-recode(relabelledEntire$activity, 
       "1"="walking",
       "2"="walking_upstairs",
       "3"="walking_downstairs",
       "4"="sitting",
       "5"="standing",
       "6"="laying"
       )

# head(activityDescriptive)   # inspect column names and data post-transformation
# tail(activityDescriptive)
# 
# length(activityDescriptive) #10299
# dim(relabelledEntire) #10299 81

entire3_4<-cbind(activityDescriptive, relabelledEntire)
#entire3_4[1:5, 1:4]

## Step Five
 
# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# four corners of a rectangular data.frame
# entire3_4[1:3, 1:5]             # upper left corner 
# entire3_4[10297:10299, 1:5]     # lower left corner
# entire3_4[1:4, 79:82]           # upper right corner
# entire3_4[10297:10299, 79:82]   # lower right corner

varList<-names(entire3_4[4:82])
#length(varList) #79
# data are provided over a list of 79 different mean or std variables
# write_csv(as.data.frame(varList), "varList.csv")
#length(meanList) #46 mean variables
#length(stdList) #33 std variables

#dim(entire3_4) #10299    82

prefinalDF<-entire3_4%>%
  group_by(subject, activityDescriptive)%>%
  summarise(count=n(), .groups = "keep")%>%
  arrange(subject)

# %>%
#   glimpse

back<-apply(entire3_4[, 4:82], 2, as.numeric)

front<-entire3_4[, 1:3]

finalDF<-cbind(front, back)

# finalDF[1:3, 1:4]
# finalDF[10297:10299, 80:82] 
# dim(finalDF) #10299    82

tidyMeanDF<-finalDF %>%

  group_by(subject, activityDescriptive) %>%
  
  #summarise(count=n()) %>%
  
  summarise(across(2:80, mean))

# four corners of rectangular data.frame
# tidyMeanDF[1:3, 1:4]      #upper left corner 
# tidyMeanDF[178:180, 1:4]  #lower left corner
# tidyMeanDF[1:3, 79:81]    #upper right corner
# finalDF[178:180, 79:81]   #lower right corner
# dim(tidyMeanDF) #180 81

#names(tidyMeanDF)

meanMean<-tidyMeanDF%>%
  group_by(subject, activityDescriptive) %>%
  summarise(means=mean(c_across(1:46))) 

# %>%
#   glimpse

# dim(meanMean)
# head(meanMean)
# tail(meanMean)

meanStd<-tidyMeanDF%>%
  group_by(subject, activityDescriptive) %>%
  summarise(means=mean(c_across(47:79))) 

# %>%
#   glimpse

# dim(meanStd)
# head(meanStd)
# tail(meanStd)

#write.table(tidyMeanDF, "tidyMeanDF.txt", row.names = FALSE)

