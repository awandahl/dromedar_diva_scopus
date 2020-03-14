## Relies on ScopusAPI.R function by Christopher Belter
## The rest is coded by Anders Wändahl aw (at) kth.se

##setwd("C:/Users/aw/R/scopus_api/Dromedar") ## my KTH-laptop at work -- set your own working directory
##setwd("~/GitHub/Dromedar")  ## my Old_HP at home -- set your own working directory

library(httr) ## needed for Scopus search
library(XML)  ## needed for Scopus search
library(readr) ## Using read_csv instead of read.csv to get rid of BOM problems
source("scopusAPI.R")  ## functions for Scopus search: https://github.com/christopherBelter/scopusAPI
source("split_csv.R") ## function to split csv-files in chunks of 250

Sys.sleep(3) ## seems like function ScopusAPI.R doesn't load properly before the rest of the code is executed

## Preprocessing of DiVA file, custom CSV with fields DOI, Scopus-ID, ISI, PMID

## Fetching CSV file from DiVA via httr/curl. Edit url, years, no of records and publication type. 
## The DiVA export default is max 9999 records, but you can override this by a factor of at least seven

## diva_url <- 'https://uu.diva-portal.org/smash/export.jsf?format=csv&addFilename=true&aq=[[]]&aqe=[]&aq2=[[{"dateIssued":{"from":"2019","to":"2020"}},{"publicationTypeCode":["review","article","conferencePaper"]}]]&onlyFullText=false&noOfRows=500&sortOrder=title_sort_asc&sortOrder2=title_sort_asc&csvType=publication&fl=PID,DOI,ISI,PMID,ScopusId,Year'
diva_url <- 'https://kth.diva-portal.org/smash/export.jsf?format=csv&addFilename=true&aq=[[]]&aqe=[]&aq2=[[{"dateIssued":{"from":"2017","to":"2018"}},{"publicationTypeCode":["bookReview","review","article","chapter"]}]]&onlyFullText=false&noOfRows=50&sortOrder=title_sort_asc&sortOrder2=title_sort_asc&csvType=publication&fl=PID,DOI,ISI,PMID,ScopusId,Year'
## diva_url <- 'https://liu.diva-portal.org/smash/export.jsf?format=csvall&addFilename=true&aq=[[]]&aqe=[]&aq2=[[{"dateIssued":{"from":"2014","to":"2014"}},{"publicationTypeCode":["review","article","conferencePaper"]}]]&onlyFullText=false&noOfRows=500&sortOrder=title_sort_asc&sortOrder2=title_sort_asc'
## diva_url <- 'https://kau.diva-portal.org/smash/export.jsf?format=csvall&addFilename=true&aq=[[]]&aqe=[]&aq2=[[{"dateIssued":{"from":"2014","to":"2014"}},{"publicationTypeCode":["review","article","conferencePaper"]}]]&onlyFullText=false&noOfRows=9999&sortOrder=title_sort_asc&sortOrder2=title_sort_asc'
## diva_url <- 'https://his.diva-portal.org/smash/export.jsf?format=csv&addFilename=true&aq=[[]]&aqe=[]&aq2=[[{"dateIssued":{"from":"2018","to":"2018"}},{"publicationTypeCode":["review","article","conferencePaper"]}]]&onlyFullText=false&noOfRows=9999&sortOrder=title_sort_asc&sortOrder2=title_sort_asc&csvType=publication&fl=PID,DOI,ISI,PMID,ScopusId,Year'
## diva_url <- 'https://sh.diva-portal.org/smash/export.jsf?format=csv&addFilename=true&aq=[[]]&aqe=[]&aq2=[[{"dateIssued":{"from":"2000","to":"2020"}},{"publicationTypeCode":["review","article","conferencePaper"]}]]&onlyFullText=false&noOfRows=9999&sortOrder=title_sort_asc&sortOrder2=title_sort_asc&csvType=publication&fl=PID,DOI,ISI,PMID,ScopusId,Year'

GET(diva_url, write_disk("export.csv", overwrite=TRUE)) ## get the records from DiVA and write to a csv on disk

## Import from DiVA: CSV with fields DOI, Scopus-ID, ISI, PMID. Hopefully the ISI could be added later as an identifier to update
df_from_diva <- read_csv('export.csv', col_types = cols())  ### read export file from DiVA, read_csv *from readr package* NOT read.csv. 'col_types = cols()' surpress noise from read_csv.
df_from_diva[['DOI']] <- tolower(df_from_diva[['DOI']]) ## change DOIs to lowercase to be safe

print('Fetching information from DiVA')
Sys.sleep(3)

## Prepare for looking for missing ScopusIds where we have DOIs in DiVA
no_eid <- df_from_diva[is.na(df_from_diva$ScopusId),]   ###  subset rows with missing ScopusId
no_eid_but_doi <- no_eid[!is.na(no_eid$DOI),]  ### subset rows with DOIs from the above dataframe
dois_no_eid <- no_eid_but_doi['DOI']   ### subset the DOIs
if(nrow(dois_no_eid) != 0) {  ## checking if there is a dataframe to work with
  write.table(dois_no_eid, 'dois_missing_eid', row.names = FALSE, col.names=FALSE) ## write table for Scopus search, row and column names.
}

## Prepare for looking for missing DOIs where we have ScopusIds in DiVA
no_doi <- df_from_diva[is.na(df_from_diva$DOI),]  ###  subset rows with missing DOIs
no_doi_but_eid <- no_doi[!is.na(no_doi$ScopusId),]  ### subset rows with ScopusIds from the above dataframe
eids_no_doi <- no_doi_but_eid['ScopusId']   ### subset the ScopusIds
if(nrow(eids_no_doi) != 0) { ## checking if there is a dataframe to work with
  write.table(eids_no_doi, 'eids_missing_doi', row.names = FALSE, col.names=FALSE )  ## write table for Scopus search, row and column names.
}

## Prepare for looking for missing PMIDs where we have DOIs in DiVA
no_pmid_doi <- df_from_diva[is.na(df_from_diva$PMID),]  ###  subset rows with missing PMIDs
no_pmid_but_doi <- no_pmid_doi[!is.na(no_pmid_doi$DOI),]  ###  subset rows with DOIs from the above dataframe
doi_no_pmid <- no_pmid_but_doi['DOI']   ### subset the DOIs
if(nrow(doi_no_pmid) != 0) { ## checking if there is a dataframe to work with
  write.table(doi_no_pmid, 'dois_missing_pmid', row.names = FALSE, col.names=FALSE)  ## write table for Scopus search, row and column names.
}

## Prepare for looking for missing DOIs where we have PMIDs in DiVA
no_doi_pmid <- df_from_diva[is.na(df_from_diva$DOI),]  ###  subset rows with missing DOIs
no_doi_but_pmid <- no_doi_pmid[!is.na(no_doi_pmid$PMID),]  ###  subset rows with PMIDs from the above dataframe
pmid_no_doi <- no_doi_but_pmid['PMID']   ### subset the PMIDs
if(nrow(pmid_no_doi) != 0) { ## checking if there is a dataframe to work with
  write.table(pmid_no_doi, 'pmids_missing_doi', row.names = FALSE, col.names=FALSE)  ## write table for Scopus search, row and column names.
}

## So let's search for the missing identifiers in the Scopus API

## looking for missing ScopusIds where we have DOIs in DiVA. Easy to forget what we are doing.
print('Searching for missing ScopusIds where we have a DOIs in DiVA')
Sys.sleep(2)

if(file.exists('dois_missing_eid')) { ## checking if there is a file to work with
  theXML_eid <- searchByID(theIDs = "dois_missing_eid", idtype = "doi", outfile = "test.xml") ## Search for DOIs where ScopusIds are missing
  result_eid_for_dois <- extractXML(theXML_eid) ## extract the XML to a dataframe
}

## looking for missing DOIs where we have ScopusIDs in DiVA. Easy to forget what we are doing.
print('Searching for missing DOIs where we have ScopusIds in DiVA')
Sys.sleep(2)

if(file.exists('eids_missing_doi')) { ## checking if there is a file to work with
  theXML_doi <- searchByID(theIDs = "eids_missing_doi", idtype = "eid", outfile = "test.xml") ## Search for ScopusIds where DOIs are missing
  result_doi_for_eids <- extractXML(theXML_doi) ## extract the XML to a dataframe
  result_doi_for_eids[['doi']] <- tolower(result_doi_for_eids[['doi']]) ## change DOIs to lowercase to be safe
}

## looking for missing PMIDs where we have DOIs in DiVA. Easy to forget what we are doing.
print('Searching for missing PMIDs where we have a DOIs in DiVA')
Sys.sleep(2)

if(file.exists('dois_missing_pmid')) { ## checking if there is a file to work with
  theXML_pmid_doi <- searchByID(theIDs = "dois_missing_pmid", idtype = "doi", outfile = "test.xml") ## Search for PMIDs where DOIs are missing
  result_pmid_for_dois <- extractXML(theXML_pmid_doi) ## extract the XML to a dataframe
}

## looking for missing DOIs where we have PMIDs in DiVA. Easy to forget what we are doing.
print('Searching for missing DOIs where we have a PMIDs in DiVA')
Sys.sleep(2)

if(file.exists('pmids_missing_doi')) { ## checking if there is a file to work with
  theXML_doi_pmid <- searchByID(theIDs = "pmids_missing_doi", idtype = "pmid", outfile = "test.xml") ## Search for PMIDs where DOIs are missing
  result_doi_for_pmids <- extractXML(theXML_doi_pmid) ## extract the XML to a dataframe
  result_doi_for_pmids[['doi']] <- tolower(result_doi_for_pmids[['doi']]) ## change DOIs to lowercase to be safe
}

## Merge output file from Scopus search with the original file from DiVA. We want to have the DiVA PIDs along with the new identifiers
## Producing files for uploading new stuff to DiVA

## Merging file from DiVA with search result from Scopus based on DOI, called "DOI" in DiVA and "doi" in Scopus.
## We are looking for the missing ScopusIds in DiVA. And this is based on where we have a DOI in DiVA. Easy to forget.
if(exists('result_eid_for_dois')) { ## checking if there is a dataframe to work with
  new_eids <- merge(df_from_diva, result_eid_for_dois, by.x="DOI", by.y="doi") ## Merge file from DiVA with search results from Scopus
  new_eids <- new_eids[, c('PID','scopusID')] ## subset the columns we need
  new_eids <- new_eids[!is.na(new_eids$scopusID),]  ##  subset rows with a 'scopusID' i.e. remove all NAs
  names(new_eids)[names(new_eids) == "scopusID"] <- "ScopusId" ## rename the column 'scopusID' to what it is called in DiVA ('ScopusId')
  ## write.csv(new_eids, file='export_files/new_eids_for_dois_in_diva.csv', row.names=FALSE) ## save a CSV file that easily could be imported to DiVA
  split_csv(new_eids) ## using function csv_split.R instead of above. We want files with a maximum of 250 records. If you want a single file, use the line above
  
}

## Merging file from DiVA with search result from Scopus based on DOI, called "DOI" in DiVA and "doi" in Scopus.
## We are looking for the missing PMIDs in DiVA. And this is based on where we have a DOI in DiVA. Easy to forget.
if(exists('result_pmid_for_dois')) { ## checking if there is a dataframe to work with
  new_pmids <- merge(df_from_diva, result_pmid_for_dois, by.x="DOI", by.y="doi") ## Merge file from DiVA with search results from Scopus
  new_pmids <- new_pmids[, c('PID','pmid')] ## subset the columns we need
  new_pmids <- new_pmids[!is.na(new_pmids$pmid),]  ##  subset rows with a 'pmid' i.e. remove all NAs
  names(new_pmids)[names(new_pmids) == "pmid"] <- "PMID" ## rename the column 'pmid' to what it is called in DiVA ('PMID')
  ## write.csv(new_pmids, file='export_files/new_pmids_for_dois_in_diva.csv', row.names=FALSE) ## save a CSV file that easily could be imported to DiVA
  split_csv(new_pmids) ## using function csv_split.R instead of above. We want files with a maximum of 250 records. If you want a single file, use the line above
  
}

## Merging file from DiVA with search result from Scopus based on ScopusID, called "ScopusId" in DiVA and "scopusID" in Scopus.
## We are looking for the DOIs in DiVA. And this is based on where we have an ScopusId in DiVA. Easy to forget.
if(exists('result_doi_for_eids')) { ## checking if there is a dataframe to work with
  new_dois <- merge(df_from_diva, result_doi_for_eids, by.x="ScopusId", by.y="scopusID") ## Merge file from DiVA with search results from Scopus
  new_dois <- new_dois[, c('PID','doi')] ## subset the columns we need
  new_dois <- new_dois[!is.na(new_dois$doi),]  ##  subset rows with a 'doi' i.e. remove all NAs
  names(new_dois)[names(new_dois) == "doi"] <- "DOI" ## rename the column 'doi' to what it is called in DiVA ('DOI')
  ## write.csv(new_dois, file='export_files/new_dois_for_eids_in_diva.csv', row.names=FALSE) ## save a CSV file that easily could be imported to DiVA
  split_csv(new_dois) ## using function csv_split.R instead of above. We want files with a maximum of 250 records. If you want a single file, use the line above
  
}

## Merging file from DiVA with search result from Scopus based on DOI, called "DOI" in DiVA and "doi" in Scopus.
## We are looking for the missing DOIs in DiVA. And this is based on where we have a PMID in DiVA. Easy to forget.
if(exists('result_doi_for_pmids')) { ## checking if there is a dataframe to work with
  new_dois_pmid <- merge(df_from_diva, result_doi_for_pmids, by.x="PMID", by.y="pmid") ## Merge file from DiVA with search results from Scopus
  new_dois_pmid <- new_dois_pmid[, c('PID','doi')] ## subset the columns we need
  new_dois_pmid <- new_dois_pmid[!is.na(new_dois_pmid$doi),]  ##  subset rows with a 'doi' i.e. remove all NAs
  names(new_dois_pmid)[names(new_dois_pmid) == "doi"] <- "DOI" ## rename the column 'doi' to what it is called in DiVA ('DOI')
  ##  write.csv(new_dois_pmid, file='export_files/new_dois_for_pmids_in_diva.csv', row.names=FALSE) ## save a CSV file that easily could be imported to DiVA
  split_csv(new_dois_pmid) ## using function csv_split.R instead of above. We want files with a maximum of 250 records. If you want a single file, use the line above
}

## You may see some errors when running this code. Some of them may indicate that there is something wrong in your data (i.e. DiVA).
## And some of errors are due to bad coding by me. I know that this code could be much much smaller and more beautiful if I had refactored, 
## or if I had used Tidyverse or whatever. A complete rewrite is not likely to happen, though. If it ain't broke, don't fix it!
