#### Retrieve instantaneous peak values from NWIS for HCDN stations


# Load libraries ----------------------------------------------------------
library(parallel)
library(doParallel)
library(dataRetrieval)
library(tidyverse)
library(data.table)
# Source files ------------------------------------------------------------
setwd("~/spatial_dependence_ipeak")

source("get_peak_streamflow_data.help.R")

setwd("~/spatial_dependence_ipeak")

# Retrieve data -----------------------------------------------------------
# Written by   : Kichul Bae
# Written on   : Jul 31, 2023
# description  : Retrieve annual(water year) instantaneous peak streamflow data from 1856 to designated year for HCDN stations, and save them to each HUC2 regions


cl <- makeCluster(18) 
registerDoParallel(cl)


getpk_hcdn_prll <- function(huc2, end_year){
  library(dataRetrieval)
  setwd("~/spatial_dependence_ipeak")
  source("get_peak_streamflow_data.help.R")
  rst <- getpk_hcdn(huc2, end_year)
  return(rst)
}

end_year <- 2022

results <- c(parLapply(cl, c(1:18), end_year, fun=getpk_hcdn_prll))

setwd("~/spatial_dependence_ipeak/HCDN_PEAK/")
saveRDS(results, file="hcdn_ipeak.RData")

