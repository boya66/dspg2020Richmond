library(data.table)
library(tidyverse)
states <- c('AK', 'AL','AR', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'HI', 'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA','MA',
           'MD', 'ME','MI', 'MN', 'MO','MS','MT', 'NC', 'ND', 'NE','NH','NJ','NM', 'NV','NY', 'OH','OK','OR','PA','RI','SC','SD',
           'TN','TX','US','UT','VA','VT','WA','WI','WV','WY')
na_info <- data.frame(state_name = character(),
                        n_row = integer(), na_value_percentage = double())
column_names <- c("GEOID", "year", "name", "state","eviction_filings","evictions", "eviction_rate" , "eviction_filing_rate")

all_counties <- data.frame()


for (state in states){
  filename <- paste('https://eviction-lab-data-downloads.s3.amazonaws.com/', state, '/counties.csv', sep = "")
  print(filename)
  mydat <- fread(filename)
  #head(mydat)
  #str(mydat)
  filtered_my_dat <- mydat %>% filter(!is.na(`evictions`) | !is.na(`eviction-rate`) |
                                        !is.na(`eviction-filings`) | !is.na(`eviction-filing-rate`)) %>%
                      select(GEOID, year, name, `parent-location`, `evictions`, `eviction-rate`, `eviction-filings`, `eviction-filing-rate`)
  print(head(filtered_my_dat))


  all_counties <- rbind(all_counties, filtered_my_dat)
  print("number of NA ")
  print(sum(is.na(mydat$`eviction-rate`)))
  print("number of rows ")
  print(nrow(mydat))
  s_name <- mydat$`parent-location`[1]
  print(s_name)
  percentage_na_value <- sum(is.na(mydat$`eviction-rate`)) *100.0 / nrow(mydat)
  new_row <- list(state_name = s_name, n_row = nrow(mydat), na_value_percentage = percentage_na_value)
  print(new_row)
  na_info <- rbind(na_info, new_row, stringsAsFactors = FALSE)
}
print(na_info)
print(head(all_counties))
write.csv(na_info, "NA_Value_summary.csv")
write.csv(all_counties, "all_counties_eviction_data.csv")
