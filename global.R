library(dplyr)
library(lubridate)
library(rgdal)
library(ggplot2)


#Preprocess the data
wbill <- read.csv("./data/billing/bill_sample_complete.csv")
# Load SHP
com_plan <- readOGR(
    paste0("./data/shp/community_plan_sd"),
    layer = "community_plan_sd")

bc <- wbill %>%
    mutate(billing_frequency = toupper(billing_frequency),
           loc_in_city = toupper(loc_in_city)) %>%
    mutate(bill_post_date = mdy(bill_date_posting_date),
           meter_read_date = mdy(meter_read_date)) %>%
    # Remove rows that are not bi-monthly since that will skew the data:
    filter(billing_frequency == 'B') %>%
    # Remove rows that are not in a city
    filter(loc_in_city == 'IN') %>%
    # Include single households only
    #filter(num_units_persons == 0) %>%
    select(
        id,
        cpcode,
        cpname,
        water_cons = water_consumption,
        sewer_cons = sewer_consumption
        #water_base_chg = water_service_charge_base_fee,
        #water_commodity_chg = water_commodity_charge,
        #sewer_base_chg = sewer_service_charge_base_fee,
        #sewer_commodity_chg = sewer_commodity_charge
    )

# com_plan has duplicates.  lets add all their stats.

cp_areas <- group_by(com_plan@data, cpcode) %>%
    summarise(acr_total = sum(acreage))

cpds <- right_join(com_plan@data, cp_areas, by = 'cpcode') %>%
    select(cpcode, cpname, acr_total) %>%
    distinct()



getCPDList <- function(inputList = TRUE) {
  cpds <- select(bc, cpname, cpcode) %>%
      arrange(cpname)
  cpds <- unique(cpds)

  if (inputList == TRUE)
     setNames(cpds$cpcode, cpds$cpname)

}

getVarList <- function() {
    vars <- select(bc, -id, -cpcode, -cpname)
    vars <- names(vars)
    setNames(vars, vars)
}

