-- /*****************PROJECT YARK*********************/
-- /* Ariel Boris Dexter bad225@nyu.edu */
-- /* Kania Azrina ka1531@nyu.edu       */
-- /* Michael Rawson mr4209             */
-- /* Yixue Wang yw1819@nyu.edu         */
-- /**************************************************/

CREATE TABLE GDELT_Table (date STRING, source STRING, target STRING, cameoCODE STRING, numEvents STRING, numArts STRING, QuadClass STRING, Goldstein STRING, SourceGeoType STRING, SourceGeoLat STRING,	SourceGeoLong STRING, TargetGeoType STRING, TargetGeoLat STRING, TargetGeoLong STRING, ActionGeoType STRING, ActionGeoLat STRING, ActionGeoLong STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/finalProject_Data';

DESCRIBE GDELT_Table;

-- simple frequency analysis and get only several columns from table by Hive

INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/Desktop/temp'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT date, cameoCODE, sum(cast(numEvents as bigint)) as No_of_events
FROM GDELT_Table
GROUP BY date, cameoCODE;
