
# table name of database
table1 <- "ScheduledTracker"

loadData <- function(){
  
  # connect to the database
  db <- dbConnect(MySQL(), dbname = Sys.getenv("databaseName1"), 
                  host = Sys.getenv("host1"),  
                  port = as.integer(Sys.getenv("port1")), 
                  user =  Sys.getenv("user1"), 
                  password = Sys.getenv("password1")) 
  
  # construct the fetching query 
  
  query <- sprintf("SELECT * FROM %s", table1)
  
  # Submit the fetch query and disconnect
  
  data <- dbGetQuery(db, query)
  
  dbDisconnect(db)
  
  
  return(data)
  
}


plotAirPods <- function(input){
  
  
  input1 <- input[which(input[,"ProductName"] == "AirPods mit Ladecase"),]
  #prepare data
  ggplot(data = input1, aes(x = YearMonthDate, y = Price, group = 1)) + geom_line()
  
  
}

plotIPhone <- function(input){
  
  input1 <- input[which(input[,"ProductName"] == "Apple IPhone 12 Pro 256 GB"),]
  
  ggplot(data = input1, aes(x = YearMonthDate, y = Price, group = 1)) + geom_line()
  
}



