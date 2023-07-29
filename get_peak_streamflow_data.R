#### Retrieve instantaneous peak values from NWIS for HCDN stations


# Load libraries ----------------------------------------------------------
library(dataRetrieval)
library(tidyverse)
library(parallel)
library(doParallel)

# Source files ------------------------------------------------------------
setwd("~/spatial_dependence_ipeak")

source("get_peak_streamflow_data.help.R")

setwd("~/spatial_dependence_ipeak")

# Retrieve data -----------------------------------------------------------

cl <- makeCluster(18) 
registerDoParallel(cl)


getpk_hcdn_prll <- function(huc2, endyear){
  library(dataRetrieval)
  setwd("~/spatial_dependence_ipeak")
  source("get_peak_streamflow_data.help.R")
  rst <- getpk_hcdn(huc2, endyear)
  return(rst)
}

results <- c(parLapply(cl, c(1:18), 2022, fun=getpk_hcdn_prll))

setwd("~/spatial_dependence_ipeak/HCDN_PEAK/")
saveRDS(results, file="hcdn_ipeak.RData")








