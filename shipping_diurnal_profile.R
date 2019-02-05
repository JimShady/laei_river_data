## Shipping profiles
rm(list=ls())

library(tidyverse)

files <- list.files('../../Desktop/AIS_DATA_2016proc_Rfiles/', full.names = T)

for (i in 1:length(files)) {
  
  load(files[[i]])
  
  data               <-   as_tibble(data) %>%
                           select(time)
  
  data$time          <-   as.POSIXct(data$time, origin="1970-01-01")
  data$hour     <-   hour(data$time)
  data$wday     <-   wday(data$time)
  
  temp_result        <-   data %>% 
                           group_by(wday, hour) %>% 
                           summarise(records = n()) %>% 
                           ungroup()
  
  if (i ==1) { result <- temp_result} else { result <- bind_rows(result, temp_result)}
  
  rm(temp_result)
  
  print(i)
}

profile <- result %>% mutate(wday = replace(wday, wday %in% c(7,1), 'weekend')) %>%
                      mutate(wday = replace(wday, wday %in% 2:6, 'weekday')) %>%
                      group_by(wday, hour) %>%
                      summarise(records = sum(records))

write_csv(profile, 'shipping_profile.csv')
  