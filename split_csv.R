## https://stackoverflow.com/questions/39935649/r-code-to-split-big-table-into-smaller-txt-files-and-save-to-computer

split_csv <- function(infile) {
  
  infile$PID <- as.character(infile$PID) ## we want " " around the PIDs
  id    <- names(infile[2]) ## extract the name of the second column of "infile" which is the type of identifier we are making csv:s for. We insert that information in the file name later.
  size  <- 250 # DiVA-support can only manually upload 250 records at a time
  n     <- nrow(infile)  ## how many rows in infile?
  r     <- rep(1:ceiling(n/size),each=size)[1:n] ## how many parts?
  d     <- split(infile,r) ## split the infile in parts of 250

  n <- 1 # starting from no 1
  for(i in d){
    part <- get("i")
    out <- file(paste0("File_",n,"_","New_",id,"_",gsub("-","",gsub(":","",gsub(" ","_",Sys.time()))), "_",".csv"),encoding="UTF-8")
    write.csv(part, file = out, row.names=FALSE) 
    n <- n + 1
  }
  
}
