CREATE TABLE GDELT_Table (date STRING, source STRING, target STRING, cameoCODE STRING, numEvents BIGINT, numArts BIGINT, QuadClass BIGINT, Goldstein STRING, SourceGeoType STRING, SourceGeoLat STRING,	SourceGeoLong STRING, TargetGeoType STRING, TargetGeoLat STRING, TargetGeoLong STRING, ActionGeoType STRING, ActionGeoLat STRING, ActionGeoLong STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/finalProject_Data';

DESCRIBE GDELT_Table;

-- preprocessing the data and only pretrive the code column for following analysis
SELECT cameoCODE FROM GDELT_Table; 

-- simple frequency analysis by Hive
INSERT OVERWRITE LOCAL DIRECTORY '/home/lvermeer/temp' SELECT count(cameoCODE) FROM GDELT_Table 
GROUP BY cameoCODE;