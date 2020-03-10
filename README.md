# Dromedar_diva_scopus
An R-script for getting publication data from DiVA, extracting missing identifiers (DOI, ScopusId, PMID), looking for these missing identifiers in Scopus, and finally returning csv-files (limited to 250 rows) for manual upload to the DiVA database.

- Install libraries httr, xml and readr
- Put files Dromedar_diva_scopus.R, scopusAPI.R and split_csv.R in the same directory
- Edit the "diva_url" parameter to your liking. This url is made by doing a "create feed"/"utsökning" in the DiVA web interface. You should probably change the beginning of the url to your institution, change the years and number of publications you want. You can retrieve a maximum of 9999 publications, which in many cases means that you have to limit your search to one year only.
- Insert your Scopus API key at line 9 and 52 in scopusAPI.R
- Run Dromedar_diva_scopus.R
- You will see that the program fetches a cvs-file from DiVA (according to your settings), then it will search in the Scopus API (which may take some time), and finally the search results from Scopus are merged with what you have in the csv you just downloaded.
- In the best of worlds you will find up to 4 csv-files in the directory. They look like: file2_20200310_165056_.csv These files are limited to 250 records because that is the maximum number that can be safely inserted manually in the DiVA database.
In order to prevent confusion I think it is a good habit to move these files out of the directory before you make another run. 
