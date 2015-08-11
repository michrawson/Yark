/*****************PROJECT YARK*********************/
/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu       */
/* Michael Rawson mr4209             */
/* Yixue Wang yw1819@nyu.edu         */
/**************************************************/

/*Load UDFs*/
REGISTER UNICEF/tutorial.jar;
REGISTER UNICEF/rake_enhanced.py using jython as rake_enhanced;
REGISTER UNICEF/rake.py using jython as rake;

/*Load seperate news*/
news_2013_2015 = LOAD 'UNICEF/OPSCEN_Brief_2013_2015.txt' USING PigStorage('\t') AS 
	(story:chararray, title:charArray, source:charArray, country:charArray, combo102:chararray,entryDate:charArray);
news_2005_2014 = LOAD 'UNICEF/OPSCEN_Brief_2005_2014.txt' USING PigStorage('\t') AS 
	(story:chararray, sourceName:chararray, title:chararray, country:chararray, 
	combo61:chararray, eventDate:charArray, dueDate:charArray, sourceLink:charArray, entryDate:charArray, combo72:charArray, 
	thematicArea:charArray);

/*Join and delete abnormal data */
clean_news_2013_2015 = FILTER news_2013_2015 BY entryDate != '';
clean_news_2005_2014 = FILTER news_2005_2014 BY eventDate != '';

clean_news_2013_2015_2 = FILTER clean_news_2013_2015 BY (entryDate matches '.*/.*/.*');
clean_news_2005_2014_2 = FILTER clean_news_2005_2014 BY (eventDate matches '.*-.*-.*');

clean_news_2013_2015_3 = FILTER clean_news_2013_2015_2 BY NOT(entryDate matches '.*:.*');
clean_news_2005_2014_3 = FILTER clean_news_2005_2014_2 BY NOT(eventDate matches '.*:.*');

clean_news_2005_2014_4 = FILTER clean_news_2005_2014_3 BY NOT(eventDate matches '.*-.*-.*-.*');

/*Project news based on selected attribute*/
clean_news_2013_2015_selected = FOREACH clean_news_2013_2015_3 GENERATE ToDate(entryDate, 'MM/dd/yy') as 
	date, title as title, story as story, country as country, combo102 as region;
clean_news_2005_2014_selected = FOREACH clean_news_2005_2014_4 GENERATE ToDate(eventDate, 'dd-MMM-yy') as 
	date, title as title, story as story, country as country, combo72 as region; 

all_news = UNION clean_news_2013_2015_selected, clean_news_2005_2014_selected;
clean_all_news = FILTER all_news BY story != '';


/*Prepare to be used in R*/
/*R Input : sequence id, event timestamp, number of item and <list of items>*/
/*Sequence ID : Distinct Country */
/*source https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Sequence_Mining/SPADE*/

grouped_clean_all_news = GROUP clean_all_news BY country;
ranked_id_country = RANK grouped_clean_all_news; --give sequence id
flatten_country = FOREACH ranked_id_country GENERATE rank_grouped_clean_all_news AS 
	sequence_id, FLATTEN(clean_all_news) AS (date, title, story, country, region);

timestamp =  FOREACH flatten_country GENERATE sequence_id, DaysBetween(date,ToDate('2000-01-01')) AS 
	daysbetween, date, title, story, country, region; 
grouped_timestamp = GROUP timestamp BY daysbetween;
sorted_ranked_time = ORDER grouped_timestamp BY group;
flatten_time = FOREACH sorted_ranked_time GENERATE group AS event_timestamp, FLATTEN(timestamp) AS 
	(sequence_id, daysbetween, date, title, story, country, region);
flatten_time_2 = FILTER flatten_time BY NOT (story matches '.*�.*');

/*Extract topic and keywords using RAKE*/
extracted_topics = FOREACH flatten_time_2 GENERATE 
	sequence_id, event_timestamp, date, title, story, rake_enhanced.extractKeyword(story) AS 
	topics, country, region; 
counted_topics = FOREACH extracted_topics GENERATE sequence_id, event_timestamp, date, title, story, topics, COUNT(topics.keyword) 
	AS count, country, region;
counted_topics_cleaned = FILTER counted_topics BY event_timestamp > 0 ;

/*Dump all news*/
STORE counted_topics_cleaned INTO 'UNICEF/extracted_topics' USING PigStorage();

/*Dump news sequence for R*/
r_input_news = FOREACH counted_topics_cleaned GENERATE sequence_id, event_timestamp, count, topics.keyword AS keyword_list;
sorted_r_input_news = ORDER r_input_news BY sequence_id,event_timestamp;
STORE sorted_r_input_news INTO 'UNICEF/r_input_news' USING PigStorage();