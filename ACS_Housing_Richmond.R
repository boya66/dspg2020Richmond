#RICHMOND HOUSING

setwd("~/dspg2020Richmond")

library(tidycensus)
library(tidyverse)
library (stringr)
library(ggplot2)
library(olsrr)
library(stats)
library(psych)


#show available variables in a particular ACS survey
acs5<-load_variables(2009, "acs5", cache=T)
View(acs5)

acs5_subject <- load_variables(2018, "acs5/subject", cache=T)
View(acs5_subject)

acs5_profile<- load_variables(2018, "acs5/profile", cache=T)
View(acs5_profile)

#FUNCTIONS:

# 1. "acs_tables" calls "get_acs" (from tidycensus) on a vector of table names. It returns a dataframe of 
# all the tables bound together.  The function requires a vector of table names, 
# a census API key, and a geographical unit.  The user can add other parameters as well.

acs_tables<-function(tables,key,geography,...){
  acs_data<-NULL
  for(i in 1:length(tables)){
    data<-get_acs(geography = geography,
                  table = tables[i],
                  key = key,
                  show_call = T,
                  cache_table=T,
                  ...
    )
    acs_data<-rbind(acs_data,data.frame(data))
  }
  return(acs_data)
}

# 2. "acs_wide" cleans the data returned from a census API call.  More specifically, 
# it separates the variable column into separate variables, and it separates "NAME" into 
# different columns with pre-defined column names (NAME_col_names). The function also
# drops the "margin of error" column.

acs_wide<-function(data,NAME_col_names){
  data%>%
    select (-moe)%>%
    pivot_wider(names_from = variable,values_from=estimate)%>%
    separate(NAME, into=NAME_col_names, sep = ", ")
}


#3. acs_years retrieves individual variables (or a list of variables) across a series of years.
acs_years<-function(years,key,geography,...){
  acs_data<-NULL
  for(i in 1:length(years)){
    acs<-get_acs(geography = geography,
                 #variables = vars,
                 key = key,
                 year=years[i],
                 output = "wide",
                 show_call = T,
                 geometry = F,
                 ...)
    acs_data<-(rbind(acs_data,data.frame(acs)))
  }
  acs_data<-cbind(acs_data,year=rep((years),each=length(unique(acs_data$GEOID))))
  return(acs_data)
}


#4. "acs_years_tables" uses two previously defined functions (acs_tables and acs_wide) to return multiple 
# variable tables across multiple years in one single tibble.  A couple of notes: the way that 
# get_acs handles variables before 2013 varies, so this function only works for 2013 and after.
# For variable tables before 2013, use acs_tables to pull individual sets of tables.  Also, I have 
# not included "geometry" in the function.  If the user includes geometry, he/she may need 
# to modify the call to acs_wide.


acs_years_tables<-function(tables,years,key,geography,NAME_col_names,...){
  acs_data<-NULL
  for (j in 1:length(years)){
    acs<-acs_tables(tables=tables,year=years[j],key=key,geography = geography,...)
    year<-rep(years[j],times=length(acs$GEOID))
    acs_years2<-cbind(year,data.frame(acs))
    acs_data<-(rbind(acs_data,acs_years2))
  }
  acs_data<-acs_wide(acs_data,NAME_col_names = NAME_col_names)
  return(acs_data)
}


#NATIONAL DATA (CITIES FROM EVICTION LAB RANKING)

tables<-c("S2501","S2502","S2503","S2506","S2507","B19013")
years<-2018
colnames=c("City","State")

#Note: the following code, which I have commented out, pulls the the variable tables listed above
#for all cities in the US.(For the variable names, see "acs_subject" above.)  It takes a long time to run -- around 30mins.  

#acs_national_housing<-acs_tables(geography = "place",
                             #tables = tables,
                             #key = .key,
                             #year=years)

#This code includes all cities in the US
acs_housing_wide<-acs_wide(acs_national_housing,colnames)

#The following 100 cities are taken from eviction lab's rankings of cities with the highest eviction rates.
cities<-c("4550875","5167000","5135000","5156000","2836000","5157000","3728000","4516000","2684000","5116000",
          "4075000","4839148","1825000","1836003","5182000","3775000","3722920","5365625","2205000","4055000",
          "3712000","0980000","3731400","3901000","0477000","3921000","0151000","3251800","0937000","3977000",
          "2036000","4513330","0804000","1235000","3271400","2622000","3719000","1304000","0908000","1369000",
          "4748000","2148006","0649270","1919000","3502000","3915000","1245975","0877290","2146027","4827000",
          "1765000","3918000","3916000","2079000","4847892","4804000","3254600","2071000","2270000","5553000",
          "1738570","1258050","2935000","0816000","2938000","4817000","3774440","4865000","0952000","4715160",
          "2965000","3137000","1276600","1232000","4459000","3755000","1245060","0150000","1271000","4801000",
          "4260000","3240000","4052500","1224000","1759000","2250115","4752006","4224000","1912000","4009050",
          "1921000","3231900","0883835","0843000","2646000","4829000","1253000","1270600","1263000","1238250"
          )

#Restrict data to the 100 cities listed above
acs_housing_100<-acs_housing_wide%>%
  filter(GEOID%in%cities)

#Clean data and add relevant variables
acs_housing_100<-acs_housing_100%>%
  #Household size
  mutate("1"=S2501_C02_002)%>%
  mutate("2"=S2501_C02_003)%>%
  mutate("3"=S2501_C02_004)%>%
  mutate("4+"=S2501_C02_005)%>%
  mutate(HouseholdsWithChildren=S2501_C02_032)%>%
  #Race of householder
  mutate(White=S2502_C02_002)%>%
  mutate(AfAm=S2502_C02_003)%>%
  mutate(NativeAm=S2502_C02_004)%>%
  mutate(Asian=S2502_C02_005)%>%
  mutate(Hispanic=S2502_C02_009)%>%
  #Level of education of householder
  mutate(Less_than_HS=S2502_C02_018)%>%
  mutate(HSdegree=S2502_C02_019)%>%
  mutate(Associate=S2502_C02_020)%>%
  mutate(Bacc_or_greater=S2502_C02_021)%>%
  #Income and housing costs
  mutate(MedianIncomeYearly=(S2503_C01_013))%>%
  mutate(MedianHousingCostMonthly=S2503_C01_024)%>%
  mutate(HousingCostProportion=(S2503_C01_024)/((S2503_C01_013)/12))%>%
  mutate(MedianMortgage=S2506_C01_039)%>%
  mutate(MedianRealEstateTaxes=S2506_C01_065)
  
#Reduce table to just those variables used for plotting
HousingReduced<-acs_housing_100%>%
  select(1:3,917:935)%>%
  mutate(MedianMonthlyIncome=MedianIncomeYearly/12)


#PLOTTING

#Household Size
data_long_size<-pivot_longer(HousingReduced,
                        cols=c("1","2","3", "4+"),
                        names_to="People in Household")
highlightdf<-data_long_size%>%
  filter(City=="Richmond city")
highlightdf$City<-rep("Richmond",times=nrow(highlightdf))

p<-ggplot(data=data_long_size,mapping=aes(x=as.factor(`People in Household`), y=value, fill=`People in Household`))
p<-p+geom_violin()
p<-p+geom_point(data=highlightdf)
p<-p+labs(x="Household Size",y="Percentage of Households",title = "Household Size",subtitle="Cities with the 100 highest eviction rates (dot=Richmond)")
p<-p+theme(legend.position="none")
p

#Race
data_long_race<-pivot_longer(HousingReduced,
                        cols=c("White","AfAm","Hispanic"),
                        names_to="Race of Householder")

highlightdf2<-data_long_race%>%
  filter(City=="Richmond city")
highlightdf2$City<-rep("Richmond",times=nrow(highlightdf2))

p<-ggplot(data=data_long_race,mapping=aes(x=as.factor(`Race of Householder`), y=value, fill=`Race of Householder`))
p<-p+geom_violin()
p<-p+geom_point(data=highlightdf2)
p<-p+labs(x="Race",y="Percentage",title = "Race of Householder",subtitle="Cities with the 100 highest eviction rates (dot=Richmond)")
p<-p+theme(legend.position="none")
p

#Education
data_long_education<-pivot_longer(HousingReduced,
                             cols=c("Less_than_HS","HSdegree","Associate", "Bacc_or_greater"),
                             names_to="Education of Householder")

highlightdf3<-data_long_education%>%
  filter(City=="Richmond city")
highlightdf3$City<-rep("Richmond",times=nrow(highlightdf3))

p<-ggplot(data=data_long_education,mapping=aes(x=as.factor(`Education of Householder`), y=value, fill=`Education of Householder`))
p<-p+geom_violin()
p<-p+geom_point(data=highlightdf3)
p<-p+labs(x="Highest Education Level",y="Percentage",title = "Education Level of Householder",subtitle="Cities with the 100 highest eviction rates (dot=Richmond)")
p<-p+theme(legend.position="none")
p


#Housing Cost as a Proportion of Income
data_long_income<-pivot_longer(HousingReduced,
                                  cols=c("HousingCostProportion"),
                                  names_to="Housing Cost")

highlightdf4<-data_long_income%>%
  filter(City=="Richmond city")
highlightdf4$City<-rep("Richmond",times=nrow(highlightdf4))

p<-ggplot(data=data_long_income,mapping=aes(x=as.factor(`Housing Cost`), y=value, fill=`Housing Cost`))
p<-p+geom_violin()
p<-p+geom_point(data=highlightdf4)
p<-p+labs(x="",y="Proportion",title = "Housing Cost as a Proportion of Income",subtitle="Cities with the 100 highest eviction rates (dot=Richmond)")
p<-p+theme(legend.position="none")
p



