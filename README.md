# GetCleanFinal
This repo hosts my materials submitted for peer review in the Getting and Cleaning Data final project.

This README highlights the analysis steps I undertook to complete the project. For a detailed list, including code chunks and illustrative output, please refer to my finalReadMe.pdf document.

Getting and Cleaning Data Final Project, Jim Rhudy, 10/25/2021

Although this project is my own work, I have freely made use of materials presented and/or linked within the Getting and Cleaning Data MOOC offered by Johns Hopkins University, especially: https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/

A full description of the dataset is available at: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The data are available at: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The data were downloaded and unzipped into a main project folder. The data and all supplemental files were found in a series of nested folders. For this reason each file specified in the provided README was copied into the main folder to avoid file path white space and to simplify file management. The download includes training and testing subsets for 10,299 observations of 30 subjects undertaking six activities while wearing a smart phone. The observations are reported in a multivariate time series dataset with 559 gyroscopic and accelerometric measurements in three axes and labelled by subject number and activity.

##Setup

I downloaded and unzipped the project raw data and supplemental files into the project directory. Since the various documents were found within nested folders, some with white space in file names, all supplemental files were copied back into the main project folder for ease of file management.

##Step One: Merges the training and the test sets to create one data set.

The project documentation was read carefully until the purpose of every supplemental file was understood. The files were used to label, inspect, and merge the data back into the entire dataset. I seperately read in and labelled the train and test files, then re-assembled the entire dataset. With the dataset reassembled, I then prepared column names and labelled the columns. The output of this step is a reassembled dataset with rows and columns labelled.

##Step Two: Extracts only the measurements on the mean and standard deviation for each measurement.

I used grep() and grepl() to identify columns referring to either mean or standard deviation without regard to the position of the string within the variable label. With these columns identified, I subset the reassembled dataset into separate mean and standard deviation tables, then joined the subsets and relabelled columns. The output of this step is a subset of the original dataset which includes only those columns which refer to a mean or standard deviation measurement.

##Step Three: Uses descriptive activity names to name the activities in the data set.

##Step Four: Appropriately labels the data set with descriptive variable names.

I recoded the activity labels from numeric to descriptive text. The output of this step is a dataset with descriptive names for each of the six activities undertaken by the subjects.

##Step Five: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Components of tidy data specify that (1) each variable should be in one column and that (2) each observation should be in a different row. Inspection of a larger sample of the output of the previous step, shown in my finalReadMe.pdf, demonstrates this. The names of the first three columns specify descriptive activity, subject, and activity labels; the other column names represent a list of 79 different measurements either collected or calculated during each experiment undertaken by a subject during a particular activity. The dataset resulting from the previous step is tidy because both the above conditions are met. Each unique variable completely occupies a single column and the outcomes of each unique experiment completely occupy a single row.

Given that each of 30 subjects undertook each of six different activities, there are 180 possible distinct combinations of subject and activity; however, the dataset contains 10,299 rows, each reporting measurements from a single experiment. This can be explained by the multivariate time-series design of the overall study. Each of the subject and activity combinations occurs many times in the dataset; this number ranges from 36 to 95.There are 46 and 33 columns which report mean and standard deviation data, respectively. These findings would tend to hinder rectangular pivoting. The documentation accompanying the data download does not explicitly account for this variability, nor does the metadata available on the webpage. I do not have the substantive knowledge to fully interpret the given variable labels and render them more human-readable so I did not attempt this.
 
The output of steps 3 and 4 is a tidy dataset which fulfills the two specifications noted above; however, this dataset is not optimized to solve the assigned problem (calculation of the average of each variable grouped by activity and subject). For this reason, I aggregated the mean of each measurement grouped by subject and activity.
                          
The output of this step is a data.frame which has been optimised to fulfill the assignment specifications as follows:

meanMean<-tidyMeanDF%>%
  group_by(subject, activityDescriptive) %>%
  summarise(means=mean(c_across(1:46))) %>%
  glimpse
 `summarise()` has grouped output by 'subject'. You can override using the `.groups` argument.
 Rows: 180
 Columns: 3
 Groups: subject [30]
 $ subject             <chr> "1", "1", "1", "1", "1", "1", "10", "10", "10", "1~
 $ activityDescriptive <chr> "laying", "sitting", "standing", "walking", "walki~
 $ means               <dbl> -0.323455253, -0.313691419, -0.329807396, -0.06302~
 
dim(meanMean)
 [1] 180   3
 
head(meanMean)
 A tibble: 6 x 3
 Groups:   subject [1]
   subject activityDescriptive   means
   <chr>   <chr>                 <dbl>
 1 1       laying              -0.323 
 2 1       sitting             -0.314 
 3 1       standing            -0.330 
 4 1       walking             -0.0630
 5 1       walking_downstairs  -0.0227
 6 1       walking_upstairs    -0.220
    
tail(meanMean)
 A tibble: 6 x 3
  Groups:   subject [1]
   subject activityDescriptive   means
   <chr>   <chr>                 <dbl>
 1 9       laying              -0.400 
 2 9       sitting             -0.382 
 3 9       standing            -0.372 
 4 9       walking             -0.133 
 5 9       walking_downstairs  -0.0787
 6 9       walking_upstairs    -0.232
    
meanStd<-tidyMeanDF%>%
  group_by(subject, activityDescriptive) %>%
  summarise(means=mean(c_across(47:79))) %>%
  glimpse
 `summarise()` has grouped output by 'subject'. You can override using the `.groups` argument.
 Rows: 180
 Columns: 3
 Groups: subject [30]
 $ subject             <chr> "1", "1", "1", "1", "1", "1", "10", "10", "10", "1~
 $ activityDescriptive <chr> "laying", "sitting", "standing", "walking", "walki~
 $ means               <dbl> -0.8966993, -0.9625317, -0.9867985, -0.3025518, -0~
    
dim(meanStd)
 [1] 180   3
    
head(meanStd)
 A tibble: 6 x 3
 Groups:   subject [1]
   subject activityDescriptive  means
   <chr>   <chr>                <dbl>
 1 1       laying              -0.897
 2 1       sitting             -0.963
 3 1       standing            -0.987
 4 1       walking             -0.303
 5 1       walking_downstairs  -0.264
 6 1       walking_upstairs    -0.428
    
tail(meanStd)
 A tibble: 6 x 3
 Groups:   subject [1]
   subject activityDescriptive  means
   <chr>   <chr>                <dbl>
 1 9       laying              -0.944
 2 9       sitting             -0.928
 3 9       standing            -0.951
 4 9       walking             -0.420
 5 9       walking_downstairs  -0.265
 6 9       walking_upstairs    -0.491
    
The output of this step is a set of two tibbles which have aggregated the mean of all “mean” columns and the mean of all “std” columns in the final tidy data.frame. Having demonstrated that the final tidy dataset is optimized to perform the specified calculations, I wrote the dataset back to the project folder as follows:

write.table(tidyMeanDF, "tidyMeanDF.txt", row.names = FALSE)
