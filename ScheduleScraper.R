############################################################################
#
# 1. Functions for extracting the prices 
# 2. database access / save data to database 


# Part of an R Project - Renviron file was created using: 

# usethis::edit_r_environ("project")


# 3. The loading of the data happens in the RShiny app and not in the cronjob!
##
#
# necesseary libraries
library(xml2)  
library(rvest)
library(stringr)
library(lubridate)

library(ggplot2)

library(RMySQL)
# 1. price extraction 


getIPhone <- function(){
  
  #product_ipad <-  "_apple-ipad-air-wi-fi-2020-2686182.html"
  #ipad <-  gsub(" ", "",paste(base_url,product_ipad))
  
  getSite_iphone <- read_html("https://www.apple.com/de/shop/buy-iphone/iphone-12-pro/6,1%22-display-256gb-graphit")
  
  getPrice <- getSite_iphone %>%
    html_nodes("span.as-price-currentprice") %>%  #span = tag name, as-price-currentprice = class name
    html_text()
  getPrice <- str_remove_all(getPrice, "[\n]") # € macht Probleme mit Codierung, daher hier rausgenommen und im str_replace_all mit Berücksichtigung
  getPrice <- gsub(" ","", getPrice)
  getPrice <- gsub(".","",getPrice, fixed=TRUE) #fixed=TRUE so that only the "." is replaced
  getPrice <- str_replace_all(getPrice, ",\\w+", "") #remove all character after "," included
  getPrice <- substr(getPrice, 1,nchar(getPrice)-1)
  getPrice_iphone <- as.integer(getPrice)
  
  
  
  return(getPrice_iphone)
}



getAirPod <- function(){
  
  getSite_airpod <- read_html("https://www.apple.com/de/shop/product/MV7N2ZM/A/airpods-mit-ladecase")
  
  getPrice <- getSite_airpod %>%
    html_nodes("span.current_price") %>%
    html_text()
  
  
  getPrice <- str_remove_all(getPrice, "[\n]") # € macht Probleme mit Codierung, daher hier rausgenommen und im str_replace_all mit Berücksichtigung
  getPrice <- gsub(" ","", getPrice)
  getPrice <- str_replace_all(getPrice, ",\\w+", "") #remove all character after "," included
  getPrice <- substr(getPrice, 1,nchar(getPrice)-1)
  getPrice_airpod <- as.integer(getPrice)
  
  return(getPrice_airpod)
  
}


getTime <- function(){
  
  
  YearMonthDate <- Sys.Date()
  Year <- year(YearMonthDate)
  inputtable <- as.data.frame(cbind(Year,YearMonthDate))
  inputtable$YearMonthDate <-  as.numeric(inputtable$YearMonthDate)
  inputtable$YearMonthDate <- format(as.Date(inputtable$YearMonthDate, origin="1970-01-01"), "%Y:%m:%d")
  
  return(inputtable)
  
  # result is a table that is then later combined with the product prices to be stored in 
  # the mysql database 
  
  
}


# 2. Database access and save

####################
table1 <- "ScheduledTracker"
####################

# credentials in the 
# usethis::edit_r_environ file

saveData <- function(data){
  
  #connect to database
  db <- dbConnect(MySQL(), dbname = Sys.getenv("databaseName1"), 
                  host = Sys.getenv("host1"),  
                  port = as.integer(Sys.getenv("port1")), 
                  user =  Sys.getenv("user1"), 
                  password = Sys.getenv("password1")) 
  

  #######################################################################################
  
  
  # construct update query by looping over the data fields
  
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')", 
    
    table1, # 
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")    
    
  )
  
  # Submit the update query and disconnect
  
  dbGetQuery(db, query)
  
  dbDisconnect(db)
  
}


ProductName <- "Apple IPhone 12 Pro 256 GB"
Price <- getIPhone()
times1 <- getTime()

row1 <- as.data.frame(cbind(ProductName, Price, times1))

saveData(row1)

ProductName <- "AirPods mit Ladecase"
Price <- getAirPod()
times2 <- getTime()

row2 <- as.data.frame(cbind(ProductName, Price, times2))

saveData(row2)
