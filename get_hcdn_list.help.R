#### This is a set of functions and others to run "get_hcdn_list.R"

# Load state code file (source: USGS) and preprocess it  ------------------

load_stcode <- function(
    source = c("local", "online"), 
    filepath = "~/spatial_dependence_ipeak/USGS_SOURCE/"
) {
  
  if (source == "online") {
    url = "https://www2.census.gov/geo/docs/reference/state.txt"
    st_code <- read.table(url(url), sep = "|", header = T)
  } else {
    setwd(filepath)
    st_code <- read.csv("state_cd_usgs.csv")
  }
  
  st_code$STATE <- as.character(st_code$STATE)
  cd <- st_code$STATE
  
  n <- length(cd)
  
  for (i in 1:n) {
    st <- cd[i]
    char_n <- nchar(st)
    while (char_n < 2){
      st <- paste0("0", st)
      char_n <- nchar(st)
    }
    cd[i] <- st
  }
  
  st_code$STATE <- cd
  
  return(st_code)
}


# Load HCDN2009 station list (source: USGS) and preprocess it. ------------

load_hcdn <- function(
    source = c("local", "online"),
    filepath = "~/spatial_dependence_ipeak/USGS_SOURCE/"
) {
  
  if (source == "online") {
    URL <- "https://water.usgs.gov/osw/hcdn-2009/HCDN-2009_Station_Info.xlsx"
    tables <- openxlsx::read.xlsx(URL)
    hcdn <- tables$STATION.ID
  } else {
    setwd(filepath)
    hcdn <- read.csv("hcdn2009_list.txt")
    hcdn <- hcdn$station.ID
  }
  
  n <- length(hcdn)
  
  for (i in 1:n) {
    st <- hcdn[i]
    st <- as.character(st)
    if (st == "208111310") {
      hcdn[i] <- "0208111310"
      next
    }
    n <- nchar(st)
    while (n < 8) {
      st <- paste0("0", st)
      n <- nchar(st)
    }
    hcdn[i] <- st
  }
  return(hcdn)
}


# Define function to make a table of HCDN stations with basic info ---------


hcdn_table <- function(hcdn, st_code){
  
  rst <- data.table::data.table(station_id = character(),
                                huc2 = character(),
                                huc4 = character(),
                                station_nm = character(),
                                state_cd = character(),
                                lat_dec = numeric(),
                                log_dec = numeric(),
                                drain_area = numeric(),
                                drain_area_contr = numeric(),
                                conus = numeric()
  )
  
  error_stations <-c()
  
  for (station in hcdn){
    
    site_info <- dataRetrieval::readNWISsite(station)
    station_id <- site_info$site_no
    if (is.null(station_id)) {
      error_stations[length(error_stations)+1] <- station
      next
    }
    
    huc2 <- substring(site_info$huc_cd, 1, 2)
    huc4 <- substring(site_info$huc_cd, 3, 4)
    station_nm = site_info$station_nm
    
    state_code <- site_info$state_cd
    state_cd <- st_code[st_code$STATE == state_code,]$STUSAB
    
    lat_dec <- site_info$dec_lat_va
    log_dec <- site_info$dec_long_va
    drain_area <- site_info$drain_area_va
    drain_area_contr <- site_info$contrib_drain_area_va
    
    if (as.numeric(huc2) <= 18) {
      conus <- 1
    } else {
      conus <- 0
    }
    
    rst <- data.table::rbindlist(list(rst, list(station_id,
                                                huc2,
                                                huc4,
                                                station_nm,
                                                state_cd,
                                                lat_dec,
                                                log_dec,
                                                drain_area,
                                                drain_area_contr,
                                                conus)))
  }
  
  n_err <- length(error_stations)
  
  if (n_err == 0) {
    print("Info of all 743 stations has been successfully retrieved")
  } else {
    print(sprintf("Failed to retrieve info of %i station(s) with dataRetrieval", length(error_stations)))
    print(error_stations)
  }
  return(rst)
}

# Function to make lists of HCDN station in a form of LIST object  --------

make_list_hcdn <- function(table_hcdn, conus = T) {
  if (conus == T) {
    list_hcdn_conus <-list()
    
    for (i in 1:18) {
      huc2_2dg <- help01(i)
      st_huc2 <- table_hcdn[conus==1][huc2 == huc2_2dg][[1]]
      st_huc2 <- sort(st_huc2)
      list_hcdn_conus <- append(list_hcdn_conus, list(st_huc2))
    }
    return(list_hcdn_conus)
  } else {
    list_hcdn_all <-list()
    
    for (i in 1:21) {
      huc2_2dg <- help01(i)
      st_huc2 <- table_hcdn[huc2 == huc2_2dg][[1]]
      st_huc2 <- sort(st_huc2)
      list_hcdn_all <- append(list_hcdn_all, list(st_huc2))
    }
    return(list_hcdn_all)
  }
}


# Miscellaneous functions  ------------------------------------------------

help01 <- function(x) {
  temp <- as.character(x)
  if (nchar(x) == 1) temp <- paste0("0", temp)
  return(temp)
}

help02 <- function(x1, x2){
  temp <- paste0(x1, x2)
  temp <- parse(text = temp)
  temp <- eval(temp)
  return(temp)
}


