# dromedar_diva_scopus
dromedar_diva_scopus is an R-script for getting publication data from DiVA, extracting missing identifiers (DOIs, ScopusIds and PMIDs), looking for these missing identifiers in Scopus, and finally getting csv-files in return (limited to 250 rows) for manual upload to the DiVA database. The code is ugly and I don't promise it will do you anything good, you have the sole responsibility for whatever will happen when you run the code, and also for the faultlessness of the output files. If you understand this, please go ahead!

- You obviously need to have a subscription to the Scopus database and have a network connection that belongs to your institution.
- Install libraries httr, xml and readr
- Put files dromedar_diva_scopus.R, scopusAPI.R and split_csv.R in the same directory
- Edit the "diva_url" parameter to your liking. This url is initially made by doing a "create feed"/"utsökning" in the DiVA web interface. You should probably change the beginning of the url to your institution, change the years and number of publications you want. You can retrieve a maximum of 9999 publications which in many cases means that you have to limit your search to one year at a time if you have a fairly large production of publications.
- Insert your Scopus API key at line 9 and 52 in scopusAPI.R (replace the text API_KEY_HERE).
- Run Dromedar_diva_scopus.R
- You will see that the program fetches a csv-file from DiVA (according to your settings), then it will search the Scopus API (which may take some time), and finally the search results from Scopus are merged with what you have in the csv you just downloaded.
- In the best of worlds you will find up to 4 csv-files in the directory. They look like: file2_20200310_165056_.csv The number of files is depending on your initial data and what is missing. The files contain one column for the PID of your publication and another containing the new identifier you are missing (but just have retrieved). Each file is limited to 250 records, since this is the maximum number that can be safely inserted manually in the DiVA database. In order to prevent confusion I think it is a good habit to move these files out of the directory before you make another run.
- Good luck!
