library(tidyverse)
library(janitor)
library(stringr)



# read data -----------------------------------------------------------
disasters <- read_csv(here::here("3_extra_practice_open_ended_cleaning_task/raw_data/disasters_with_errors.csv"))


# first look at data ------------------------------------------------------
glimpse(disasters)
summary(disasters)

disasters_na <- disasters %>% 
  summarise(across(.fns = ~sum(is.na(.x))))


# janitor pacjage: clean_names() and remove_empty rows and cols -------
disasters_janitor_clean <- disasters %>% 
  clean_names() %>% 
  remove_empty(c("rows", "cols"))


# outliers ----------------------------------------------------------
  # Function that allow to know the value of IRQ (Inter-Quartile Range) and 
  # calculate the values of outliers. Was used one function for each variable, 
  # it was not th ebest approach because just with one function it will be
  # to do what it is expected but for impossiblity to change the variable name 
  # in the arguments of function, for now...

outliers <- function(data_frame){
  
  first_quartil <- quantile(data_frame$total_deaths, probs = 0.25, na.rm = TRUE)
  third_quartil <- quantile(data_frame$total_deaths, probs = 0.75, na.rm = TRUE)
  
  irq             <- third_quartil - first_quartil
  bottom_outliers <- first_quartil - (1.5 * irq)
  top_outliers    <- third_quartil + (1.5 * irq)


  return(list(irq             = irq,
              bottom_outliers = bottom_outliers,
              top_outliers    = top_outliers))
}
outliers_total_deaths <- outliers(disasters_janitor_clean)



outliers <- function(data_frame){
  first_quartil <- quantile(data_frame$affected, probs = 0.25, na.rm = TRUE)
  third_quartil <- quantile(data_frame$affected, probs = 0.75, na.rm = TRUE)
  
  irq             <- third_quartil - first_quartil
  bottom_outliers <- first_quartil - (1.5 * irq)
  top_outliers    <- third_quartil + (1.5 * irq)
  
  
  return(list(irq             = irq,
              bottom_outliers = bottom_outliers,
              top_outliers    = top_outliers))
}
outliers_affected <- outliers(disasters_janitor_clean)

outliers <- function(data_frame){
  
  first_quartil <- quantile(data_frame$injured, probs = 0.25, na.rm = TRUE)
  third_quartil <- quantile(data_frame$injured, probs = 0.75, na.rm = TRUE)
  
  irq             <- third_quartil - first_quartil
  bottom_outliers <- first_quartil - (1.5 * irq)
  top_outliers    <- third_quartil + (1.5 * irq)
  
  
  return(list(irq              = irq,
              bottom_outliers  = bottom_outliers,
              top_outliers     = top_outliers))
}
outliers_injured <- outliers(disasters_janitor_clean)


outliers <- function(data_frame){
  
  first_quartil <- quantile(data_frame$homeless, probs = 0.25, na.rm = TRUE)
  third_quartil <- quantile(data_frame$homeless, probs = 0.75, na.rm = TRUE)
  
  irq             <- third_quartil - first_quartil
  bottom_outliers <- first_quartil - (1.5 * irq)
  top_outliers    <- third_quartil + (1.5 * irq)
  
  
  return(list(irq             = irq,
              bottom_outliers = bottom_outliers,
              top_outliers    = top_outliers))
}
outliers_homeless <- outliers(disasters_janitor_clean)


outliers <- function(data_frame){
  
  first_quartil <- quantile(data_frame$total_affected, probs = 0.25, na.rm = TRUE)
  third_quartil <- quantile(data_frame$total_affected, probs = 0.75, na.rm = TRUE)
  
  irq             <- third_quartil - first_quartil
  bottom_outliers <- first_quartil - (1.5 * irq)
  top_outliers    <- third_quartil + (1.5 * irq)
  
  
  return(list(irq             = irq,
              bottom_outliers = bottom_outliers,
              top_outliers    = top_outliers))
}
outliers_total_affected <- outliers(disasters_janitor_clean)


outliers <- function(data_frame){
  
  first_quartil <- quantile(data_frame$total_damage, probs = 0.25, na.rm = TRUE)
  third_quartil <- quantile(data_frame$total_damage, probs = 0.75, na.rm = TRUE)
  
  irq             <- third_quartil - first_quartil
  bottom_outliers <- first_quartil - (1.5 * irq)
  top_outliers    <- third_quartil + (1.5 * irq)
  
  
  return(list(irq             = irq,
              bottom_outliers = bottom_outliers,
              top_outliers    = top_outliers))
}
outliers_total_damage <- outliers(disasters_janitor_clean)


disasters_outliers <- disasters_janitor_clean %>% 
  mutate(total_deaths = if_else(
             between(total_deaths, 0, outliers_total_deaths$top_outliers),
             total_deaths,
             NA_real_),
         affected = if_else(
           between(affected, 1, outliers_affected$top_outliers),
           affected,
           NA_real_),
         injured = if_else(
           between(injured, 1, outliers_injured$top_outliers),
           injured,
           NA_real_),
         homeless = if_else(
           between(homeless, 1, outliers_homeless$top_outliers),
           homeless,
           NA_real_),
         total_affected = if_else(
           between(homeless, 1, outliers_total_affected$top_outliers),
           homeless,
           NA_real_),
         total_damage = if_else(
           between(total_damage, 1, outliers_total_damage$top_outliers),
           total_damage,
           NA_real_)
         )      

## Some of the data might be the wrong type --------------------------------
disaster_wrong_type <- disasters_outliers %>% 
  mutate(country_name = if_else(str_detect(iso, "CIV|REU"),
                                NA_character_, 
                                country_name))


## Be aware that ISO values for countries should always be three ch --------
  # Created a new column to see if TRUE there are iso names with most of 3 
  # characteres
disaster_iso_recode <- disaster_wrong_type %>% 
  mutate(new_iso =  (nchar(iso) < 3) | (nchar(iso) > 3))

 # There are 5 observations were the value of iso is higher that 3 characteres, 
 # all of this values are from China. This way, this values were recoded.
disaster_iso_recode <- disaster_iso_recode %>% 
  select(-new_iso) %>% 
  mutate(iso = recode(iso, 
         "CHINA" = "CHN"))



# drop_na -----------------------------------------------------------------
disaster_drop_na <- disaster_iso_recode %>% 
  drop_na()


# clean data --------------------------------------------------------------
disaster_clean <- disaster_drop_na



# write_csv file ----------------------------------------------------------
disaster_clean %>% 
  write.csv("3_extra_practice_open_ended_cleaning_task/clean_data/disaster_clean.csv")


         
                              

         
         
         

         
         
         
  


