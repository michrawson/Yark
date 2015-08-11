Mapreduce job creates a key for each row composed of the country code, month and year. The file is then used as input for a HIVE
job that creates a table based on the input from MR that treates the key as one field everything else as one value field. HIVE
then runs a join on a table built from the Events of Interest labels data for each country and month/year. The output is the 5 Events of interest for each country/year/month followed
by the variables for each month per row. 
