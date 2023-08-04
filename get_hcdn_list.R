#### Using source files from USGS, create HCDN stations list with basic info

# Load libraries ----------------------------------------------------------
library(openxlsx)
library(data.table)
library(dataRetrieval)



# Load source files -------------------------------------------------------
source("~/spatial_dependence_ipeak/get_hcdn_list.help.R")


# Define function to make a table of HCDN stations with basic info ---------
# Written by   : Kichul Bae
# Written on   : Jul 31, 2023
# Description  : From the USGS website (or local files), retrieve a table of HCDN2009 stations, and make a table that contains station id, huc2, huc4, station name, state name, latitude, longitude, drainage area, and whether it belongs to the conterminous United States (CONUS) or not (1 if it does)

st_code <- load_stcode("online") # Get state code
hcdn <- load_hcdn("online") # Get HCDN2009 stations list

result <- hcdn_table(hcdn, st_code) # Return HCDN stations table with basic info

saveRDS(result,"~/spatial_dependence_ipeak/hcdn_list/table_hcdn.RData")


table_hcdn <- readRDS("~/spatial_dependence_ipeak/hcdn_list/table_hcdn.RData")

list_hcdn_conus <- make_list_hcdn(table_hcdn, conus = T) # Return 704 HCDN stations list in CONUS (HUC2: 1~18)
saveRDS(list_hcdn_conus,"~/spatial_dependence_ipeak/HCDN_LIST/list_hcdn_conus.RData")

list_hcdn_all <- make_list_hcdn(table_hcdn, conus = F) # Return all 743 HCDN stations list 
saveRDS(list_hcdn_all,"~/spatial_dependence_ipeak/HCDN_LIST/list_hcdn_all.RData")












