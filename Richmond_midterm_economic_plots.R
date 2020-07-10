# ---
# title: "Richmond ACS Economic Data for Midterm Presentation
# author: "Dylan Glover"
# date: "July 10, 2020"
# ---

# Check packages referenced below are installed; if not, install them.

check.package.install <- function(pkge){
  is.element(pkge, installed.packages()[,1])
}

if (!check.package.install("tidycensus")){
  install.packages("tidycensus")
}

if (!check.package.install("tidyverse")){
  install.packages("tidyverse")
}

if (!check.package.install("stringr")){
  install.packages("stringr")
}

if (!check.package.install("ggplot2")){
  install.packages("ggplot2")
}

if (!check.package.install("gridExtra")){
  install.packages("gridExtra")
}

#Load Libraries

library(tidycensus)
library(tidyverse)
library (stringr)
library(ggplot2)

library(gridExtra)

# Candidate variable tables for describing employment, poverty, and educational attainment
  # B23025 
    #(001-007, 
    #EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER, 
    #Universe: EMPLOYMENT STATUS FOR THE POPULATION 16 YEARS AND OVER), 
  # B17020 
    #(001-009, 
    #POVERTY STATUS IN THE PAST 12 MONTHS BY AGE, 
    #Universe: Population For Whom Poverty Status Is Determined), 
  # B17003 
    #(001-012, 
    #POVERTY STATUS IN THE PAST 12 MONTHS OF INDIVIDUALS BY SEX BY EDUCATIONAL ATTAINMENT, 
    #Universe: Population 25 Years And Over For Whom Poverty Status Is Determined), 
  # B15003 
    #(001-025, 
    #EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER, 
    #Universe: Population 25 Years And Over), 

# Create a vector of variables to pull

vars<-c(
  tot_emp_status_16yrs_and_over_B23025_= "B23025_001", 
  emp_status_16yrs_and_over_labor_force_B23025_ = "B23025_002", 
  emp_status_16yrs_and_over_civ_labor_force_B23025_ = "B23025_003",
  emp_status_16yrs_and_over_employed_B23025_ = "B23025_004", 
  emp_status_16yrs_and_over_unemployed_B23025_ = "B23025_005", 
  emp_status_16yrs_and_over_armed_forces_B23025_ = "B23025_006", 
  emp_status_16yrs_and_over_not_in_labor_force_B23025_ = "B23025_007", 
  tot_pov_sts_12mths_age_B17020_ = "B17020_001", 
  tot_income_12mths_blw_pov_lvl_B17020_ = "B17020_002",
  income_12mths_blw_pov_lvl_under6yrs_B17020_ = "B17020_003", 
  income_12mths_blw_pov_lvl_6to11yrs_B17020_ = "B17020_004",
  income_12mths_blw_pov_lvl_12to17yrs_B17020_ = "B17020_005",
  income_12mths_blw_pov_lvl_18to59yrs_B17020_ = "B17020_006",
  income_12mths_blw_pov_lvl_60to74yrs_B17020_ = "B17020_007", 
  income_12mths_blw_pov_lvl_75to84yrs_B17020_ = "B17020_008",
  income_12mths_blw_pov_lvl_85upyrs_B17020_ = "B17020_009",
  tot_pov_sts_indiv_sex_edu_B17003_ = "B17003_001", 
  tot_income_blw_pov_pov_sts_indiv_sex_edu_B17003_ = "B17003_002", 
  income_blw_pov_male_pov_sts_indiv_sex_edu_B17003_ = "B17003_003", 
  income_blw_pov_male_no_hs_pov_sts_indiv_sex_edu_B17003_ = "B17003_004", 
  income_blw_pov_male_hs_pov_sts_indiv_sex_edu_B17003_ = "B17003_005", 
  income_blw_pov_male_assoc_pov_sts_indiv_sex_edu_B17003_ = "B17003_006", 
  income_blw_pov_male_bach_pov_sts_indiv_sex_edu_B17003_ = "B17003_007",
  income_blw_pov_female_pov_sts_indiv_sex_edu_B17003_ = "B17003_008", 
  income_blw_pov_female_no_hs_pov_sts_indiv_sex_edu_B17003_ = "B17003_009", 
  income_blw_pov_female_hs_pov_sts_indiv_sex_edu_B17003_ = "B17003_010", 
  income_blw_pov_female_assoc_pov_sts_indiv_sex_edu_B17003_ = "B17003_011", 
  income_blw_pov_female_bach_pov_sts_indiv_sex_edu_B17003_ = "B17003_012",
  tot_edu_attain_25yrs_and_up_B15003_= "B15003_001", 
  tot_edu_attain_25yrs_and_up_no_school_B15003_= "B15003_002", 
  tot_edu_attain_25yrs_and_nursery_B15003_= "B15003_003", 
  tot_edu_attain_25yrs_and_up_kindergarten_B15003_= "B15003_004", 
  tot_edu_attain_25yrs_and_up_1stgrade_B15003_= "B15003_005", 
  tot_edu_attain_25yrs_and_up_2ndgrade_B15003_= "B15003_006", 
  tot_edu_attain_25yrs_and_up_3rdgrade_B15003_= "B15003_007", 
  tot_edu_attain_25yrs_and_up_4thgrade_B15003_= "B15003_008", 
  tot_edu_attain_25yrs_and_up_5thgrade_B15003_= "B15003_009", 
  tot_edu_attain_25yrs_and_up_6thgrade_B15003_= "B15003_010",
  tot_edu_attain_25yrs_and_up_7thgrade_B15003_= "B15003_011", 
  tot_edu_attain_25yrs_and_up_8thgrade_B15003_= "B15003_012", 
  tot_edu_attain_25yrs_and_up_9thgrade_B15003_= "B15003_013", 
  tot_edu_attain_25yrs_and_up_10thgrade_B15003_= "B15003_014", 
  tot_edu_attain_25yrs_and_up_11thgrade_B15003_= "B15003_015", 
  tot_edu_attain_25yrs_and_up_12thgrade_B15003_ = "B15003_016", 
  tot_edu_attain_25yrs_and_up_HS_diploma_B15003_ = "B15003_017", 
  tot_edu_attain_25yrs_and_up_GED_B15003_ = "B15003_018", 
  tot_edu_attain_25yrs_and_up_somecollege_freshman_B15003_ = "B15003_019", 
  tot_edu_attain_25yrs_and_up_somecollege_abovefreshman_B15003_ = "B15003_020", 
  tot_edu_attain_25yrs_and_up_assoc_B15003_= "B15003_021",
  tot_edu_attain_25yrs_and_up_bach_B15003_= "B15003_022", 
  tot_edu_attain_25yrs_and_up_masters_B15003_ = "B15003_023", 
  tot_edu_attain_25yrs_and_up_prof_degree_B15003_ = "B15003_024", 
  tot_edu_attain_25yrs_and_up_doctorate_B15003_ = "B15003_025")

# "get_acs" creates a census api call using the vector of variables specified above

#Apply for census api and set 'yourkey' string to your API key
yourkey <- ''

acs<-get_acs(geography = "tract",
             state="VA",
             county = "Richmond city",
             variables = vars,
             survey = "acs5",
             key = yourkey,
             output = "wide",
             show_call = T,
             geometry = T,
             keep_geo_vars = T)

#Separate the NAME column into Census_tract, County, and State
colnames=c("Census_tract","County","State")
acs<-separate(acs,NAME.y, into=colnames, sep = ", ")

# Create measures based on ACS variables
acs$perc_16yrs_and_over_in_labor_force <- 
  round((acs$emp_status_16yrs_and_over_labor_force_B23025_E / acs$tot_emp_status_16yrs_and_over_B23025_E)*100,2)
acs$perc_16yrs_and_over_unemployed <- 
  round((acs$emp_status_16yrs_and_over_unemployed_B23025_E / acs$tot_emp_status_16yrs_and_over_B23025_E)*100,2)
acs$perc_of_pov_sts_known_recent_annual_income_blw_pov_lvl <- 
  round((acs$tot_income_12mths_blw_pov_lvl_B17020_E / acs$tot_pov_sts_12mths_age_B17020_E)*100,2)
acs$percw_HS_diploma <-  
  round((acs$tot_edu_attain_25yrs_and_up_HS_diploma_B15003_E / acs$tot_edu_attain_25yrs_and_up_B15003_E)*100,2)
acs$per_below_HS_diploma <- 
  round(((acs$tot_edu_attain_25yrs_and_up_B15003_E - 
            (acs$tot_edu_attain_25yrs_and_up_assoc_B15003_E + 
            acs$tot_edu_attain_25yrs_and_up_GED_B15003_E +
            acs$tot_edu_attain_25yrs_and_up_somecollege_abovefreshman_B15003_E +
            acs$tot_edu_attain_25yrs_and_up_somecollege_freshman_B15003_E +
            acs$tot_edu_attain_25yrs_and_up_HS_diploma_B15003_E +
            acs$tot_edu_attain_25yrs_and_up_bach_B15003_E + 
            acs$tot_edu_attain_25yrs_and_up_masters_B15003_E + 
            acs$tot_edu_attain_25yrs_and_up_doctorate_B15003_E))/ acs$tot_edu_attain_25yrs_and_up_B15003_E)*100,2)

acs$per_bach_and_up <- 
  round(((acs$tot_edu_attain_25yrs_and_up_bach_B15003_E + 
            acs$tot_edu_attain_25yrs_and_up_masters_B15003_E + 
            acs$tot_edu_attain_25yrs_and_up_doctorate_B15003_E)/acs$tot_pov_sts_12mths_age_B17020_E )*100,2)

#Heatmaps using measures of variables from ACS tables:

# B23025 - Percentage of Population with Employment status == Unemployed
  plot1 <- ggplot(acs, aes(fill = perc_16yrs_and_over_unemployed)) +
    geom_sf() +
    coord_sf(crs = 26914)+
    labs(title="Richmond city",subtitle="Percentage of the Population aged 16+ Unemployed") +  theme_tufte() + 
    theme(legend.title = element_blank(), plot.title = element_blank(), plot.subtitle = element_text(color="black", size=9)) +
    scale_fill_viridis_c()

# B17020 - Percentage of population with annual income in previous 12 months below poverty level
  plot2 <- ggplot(acs, aes(fill = perc_of_pov_sts_known_recent_annual_income_blw_pov_lvl)) +
    geom_sf() +
    coord_sf(crs = 26914)+
    labs(title="Richmond city",subtitle="Percentage of the Population with Income Below Poverty Level") +  theme_tufte() + 
    theme(legend.title = element_blank(), plot.title = element_blank(), plot.subtitle = element_text(color="black", size=9)) +
    scale_fill_viridis_c()

# B15003 - Percentage of population at various levels of educational attainment

  plot3 <- ggplot(acs, aes(fill = per_below_HS_diploma), size=0.5) +
    geom_sf() +
    coord_sf(crs = 26914)+
    labs(title="Richmond city",subtitle="Percentage of the Population aged 25+ with Highest Degree Below HS Diploma or GED") +  theme_tufte() + 
    theme(legend.title = element_blank(), plot.title = element_blank(), plot.subtitle = element_text(color="black", size=9)) + 
    scale_fill_viridis_c()

  plot4 <- ggplot(acs, aes(fill = per_bach_and_up), size=0.5) +
    geom_sf() +
    coord_sf(crs = 26914)+
    labs(title="Richmond city",subtitle="Percentage of the Population aged 25+ with Bachelors degree or Higher as Highest Degree") +  theme_tufte() + 
    theme(legend.title = element_blank(), plot.title = element_blank(), plot.subtitle = element_text(color="black", size=9, hjust = 0)) + 
    scale_fill_viridis_c()

grid.arrange(plot1, plot2, plot3, plot4, ncol=2)