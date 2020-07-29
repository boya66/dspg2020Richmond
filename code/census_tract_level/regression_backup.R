check.package.install <- function(pkge){
  is.element(pkge, installed.packages()[,1])
}
if (!check.package.install("tidyverse")){
  install.packages("tidyverse")
}
if (!check.package.install("data.table")){
  install.packages("data.table")
}
if (!check.package.install("sqldf")){
  install.packages("sqldf")
}
if (!check.package.install("readxl")){
  install.packages("readxl")
}
if (!check.package.install("datasets.load")){
  install.packages("datasets.load")
}
if (!check.package.install("noncensus")){
  install.packages("noncensus")
}

library(tidyverse)
library(data.table)
library(sqldf)

library(USAboundaries)
state_codes
st_abbr <- state_codes$state_abbr[state_codes$state_abbr!='']
#Use this GUI to load the counties dataset from package noncensus
datasets.load::datasets.load()
#Set your destination folder here
destfold <- 'tract_data_files/'
for (st in st_abbr) {
  str <- paste0('http://eviction-lab-data-downloads.s3.amazonaws.com/',st,'/tracts.csv')
  str_dest <- paste0(destfold,'tracts_',st,'.csv')
  # print(str)
  # print(str_dest)
  tryCatch(download.file(url=str, destfile=str_dest, method="wget", quiet=TRUE))
  
}
for (st in st_abbr) {
  str <- paste0('http://eviction-lab-data-downloads.s3.amazonaws.com/',st,'/cities.csv')
  str_dest <- paste0(destfold,'cities_',st,'.csv')
  # print(str)
  # print(str_dest)
  download.file(url=str, destfile=str_dest, method="wininet", quiet=TRUE)
}
for (st in st_abbr) {
  str <- paste0('http://eviction-lab-data-downloads.s3.amazonaws.com/',st,'/cities.geojson')
  str_dest <- paste0(destfold,'cities_',st,'.geojson')
  # print(str)
  # print(str_dest)
  download.file(url=str, destfile=str_dest, method="wininet", quiet=TRUE)
}
for (st in st_abbr) {
  str <- paste0('http://eviction-lab-data-downloads.s3.amazonaws.com/',st,'/tracts.geojson')
  str_dest <- paste0(destfold,'tracts_',st,'.geojson')
  # print(str)
  # print(str_dest)
  download.file(url=str, destfile=str_dest, method="wininet", quiet=TRUE)
}

e_tract_candidates = list.files(destfold,pattern="(^tracts_).*(.csv)")
setwd(destfold)
for (tract in e_tract_candidates){
  
  # Create e_tracts, if nonexistent
  if (!exists("e_tracts")){
    e_tracts <- data.table::fread(tract, header=TRUE)
  }
  
  # Append to e_tracts, if existent
  if (exists("e_tracts")){
    tmp_e_tracts <- data.table::fread(tract, header=TRUE)
    e_tracts <- rbind(e_tracts, tmp_e_tracts)
    rm(tmp_e_tracts)
  }
  
}

write.csv(e_tracts, file = 'tract_level_er.csv')

###################
## city level info#
###################
destfold <- 'city_data_files/'
for (st in st_abbr) {
  str <- paste0('http://eviction-lab-data-downloads.s3.amazonaws.com/',st,'/cities.csv')
  str_dest <- paste0(destfold,'cities_',st,'.csv')
  # print(str)
  # print(str_dest)
  tryCatch(download.file(url=str, destfile=str_dest, method="wget", quiet=TRUE))
}

e_city_candidates = list.files(destfold,pattern="(^cities_).*(.csv)")
setwd(destfold)
for (city in e_city_candidates){
  
  # Create e_cities, if nonexistent
  if (!exists("e_cities")){
    e_cities <- data.table::fread(city, header=TRUE)
  }
  
  # Append to e_cities, if existent
  if (exists("e_cities")){
    tmp_e_cities <- data.table::fread(city, header=TRUE)
    e_cities <- rbind(e_cities, tmp_e_cities)
    rm(tmp_e_cities)
  }
  
}
write.csv(e_cities, file = 'city_level_er.csv')

e_cities <- read.csv('city_data_files/city_level_er.csv', header = T)
library(dplyr)
# library(stringr)
dat <- e_cities %>% filter(year > 2014) %>% filter(population > 10^5) %>% 
  filter(population < 10^6) %>% filter(!is.na(`eviction.rate`))
# names(dat) <- str_replace_all(names(dat),  '\.', '_')
dat <- mutate(dat, year = as.factor(year), state = parent.location)


## read in the policy data
LT_policy <- readxl::read_excel('../../data/Landlord_Tenant_Data_Policy_atlas.xlsx', sheet = 1)
Fair_Housing_Data <- readxl::read_excel('../../data/Fair_Housing_Data.xlsx', sheet=1)
DT_LT_policy <- LT_policy %>% group_by(Jurisdiction) %>% top_n(1, Valid_Through_Date)
DT_Fair_Housing_Data <- Fair_Housing_Data %>% group_by(Jurisdictions) %>% top_n(1, Valid_Through_Date)

datp <- data.frame(state = DT_LT_policy$Jurisdiction, 
                   slt_exempt_total = DT_LT_policy$SLT_EXEMPT_TOTAL)
datf <-  data.frame(state = DT_Fair_Housing_Data$Jurisdictions, 
                    fhp_exampt_total = DT_Fair_Housing_Data$FHP_ExemptHousing_TOTAL_)

test <- left_join(dat, datp, by = 'state')
test <- left_join(test, datf, by = 'state')

## regression model
lm <- lm(eviction.rate ~ poverty.rate + pct.renter.occupied + pct.af.am + 
           pct.white + median.property.value +
           median.gross.rent + slt_exempt_total + fhp_exampt_total , data = test)
summary(lm)
