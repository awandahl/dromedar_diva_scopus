## https://stackoverflow.com/questions/39935649/r-code-to-split-big-table-into-smaller-txt-files-and-save-to-computer

##infile <- new_eids
split_csv <- function(infile) {
  
  infile$PID <- as.character(infile$PID) ## we want " " around the PIDs
  size <- 250 # DiVA can only handle 250 records at a time
  n     <- nrow(infile)  ## how many rows in infile?
  r     <- rep(1:ceiling(n/size),each=size)[1:n] ## how many parts?
  d     <- split(infile,r) ## split the infile in parts of 250
  
  n <- 1 # starting from no 1
  for(i in d){
    part <- get("i")
    out <- file(paste0("file",n,"_",gsub("-","",gsub(":","",gsub(" ","_",Sys.time()))), "_",".csv"),encoding="UTF-8")
    write.csv(part, file = out, row.names=FALSE) 
    n <- n + 1
  }
  
}