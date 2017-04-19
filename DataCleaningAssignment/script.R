#read the files directory as list of files
files <- list.files(path = "C:/Users/DileepReddyM/Desktop/Datasets", full.names = TRUE)

#Create a empty data frame to hold appended data
dat <- NULL

#Run loop for appending the files
for (i in 1:13) {
    dat <- rbind(dat, read.csv(files[i]))
}

#Delete columns by setting to NULL
AllNICrimeData <- dat
AllNICrimeData$Crime.ID <- NULL
AllNICrimeData$Reported.by <- NULL
AllNICrimeData$Falls.within <- NULL
AllNICrimeData$LSOA.code <- NULL
AllNICrimeData$LSOA.name <- NULL


#Load the Spost Code file. Set the blanks as NA
data1 <- read.csv("C:/Users/DileepReddyM/Desktop/NIPostcodes.csv", header = FALSE, na.strings = c(""))

head(data1)
colnames(data1) <- c('OrganisationName', 'Sub-buildingName', 'BuildingName', 'Number', 'PrimaryThorfare',
                     'Alt Thorfar', 'Secondary Thorfare', 'Locality',
                     'Townland', 'Town', 'County', 'Postcode', 'x-coordinates', 'y-coordinates', 'PrimaryKey')


#Change the order of columns
data1 <- data1[, c(15, 1:14)]

# Relpace the "On or near" by blank
AllNICrimeData$Location <- gsub("On or near", "", as.character(AllNICrimeData$Location))

#Empty spaces are replaced with No location 
AllNICrimeData$Location <- gsub("^$", "No Location", as.character(AllNICrimeData$Location))


#Group_By....Summarising data

AllNICrimeData_summery <- group_by(AllNICrimeData, Location)
head(AllNICrimeData_summery)
library(reshape2)
AllNICrimeData_summery_final <- dcast(AllNICrimeData_summery, Location ~ Crime.type)
#table of crimetype
#table(AllNICrimeData$Crime.type, useNA = 'always')
#table of crime location
#table(AllNICrimeData$Location, useNA = 'always')
library("dplyr")
# Summary <- AllNICrimeData %>% group_by(Location) %>% summarise(CrimeCount = sum(!is.na(Location)))

#remove duplicate of location
#AllNICrimeData <- AllNICrimeData[!duplicated(AllNICrimeData$Location),]

#Changed the location values to upper case.
AllNICrimeData_summery_final$Location <- toupper(AllNICrimeData_summery_final$Location)

#Trimmed the empty space existed in Location.
AllNICrimeData_summery_final$Location <- trimws(AllNICrimeData_summery_final$Location, which = "left")

#Join dataset 
Data_fin <- merge(AllNICrimeData_summery_final, data1[, c('PrimaryThorfare', 'Town', 'County', 'Postcode')],
                  by.x = 'Location', by.y = 'PrimaryThorfare')
#Removed the duplicate values.
Data_fin <- Data_fin[!duplicated(AllNICrimeData),]

#Wrote a resultant data into csv.
write.csv(Data_fin[, c(1, 16:18, 2:15)], file = "FinalNICrimeData.csv", row.names = FALSE)
