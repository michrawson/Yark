/*****************PROJECT YARK*********************/
/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu       */
/* Michael Rawson mr4209             */
/* Yixue Wang yw1819@nyu.edu         */
/**************************************************/

/*Load UDFs*/
REGISTER UNICEF/tutorial.jar;
REGISTER UNICEF/rake.py using jython as rake;
REGISTER UNICEF/datafu-1.2.0-sources.jar
DEFINE CountEach datafu.pig.bags.CountEach();

/*Load seperate news*/
news_2013_2015 = LOAD 'UNICEF/OPSCEN_Brief_2013_2015.txt' USING PigStorage('\t') AS (story:chararray, title:charArray, source:charArray, country:charArray, combo102:chararray,entryDate:charArray);
news_2005_2014 = LOAD 'UNICEF/OPSCEN_Brief_2005_2014.txt' USING PigStorage('\t') AS (story:chararray, sourceName:chararray, title:chararray, country:chararray, combo61:chararray, eventDate:charArray, dueDate:charArray, sourceLink:charArray, entryDate:charArray, combo72:charArray, thematicArea:charArray);

/*Join, delete null and give indexes*/
clean_news_2013_2015 = FILTER news_2013_2015 BY entryDate != '';
clean_news_2005_2014 = FILTER news_2005_2014 BY eventDate != '';

/*Project news based on selected attribute*/
clean_news_2013_2015_selected = FOREACH clean_news_2013_2015 GENERATE ToDate(entryDate, 'dd-MM-yy') as date, title as title, story as story, country as country, combo102 as region;
clean_news_2005_2014_selected = FOREACH clean_news_2005_2014 GENERATE ToDate(eventDate, 'dd-MM-yy') as date, title as title, story as story, country as country, combo72 as region; 

all_news = UNION clean_news_2013_2015_selected, clean_news_2005_2014_selected;
clean_all_news = FILTER all_news BY story != '';
sorted_all_news = ORDER clean_all_news BY date asc;

/*Prepare to be used in R*/
/*R Input : sequence id, event timestamp, number of item and <list of items>*/
/*Sequence ID : Distinct Country */
/*source https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Sequence_Mining/SPADE*/

/*Extract topic and keywords using RAKE*/
ranked_id = RANK sorted_all_news; --give news id
ranked_id_grouped = GROUP ranked_id BY country;
country_id = GROUP ranked_id_grouped BY country; --give sequence id
timestamp =  FOREACH country_id GENERATE $0 as story_id, $1 as sequence_id, (date - ToDate('2000-01-01')) as event_timestamp, date as date, title as title, story as story, country as country, combo72 as region; 

extracted_topics = FOREACH timestamp GENERATE story_id as story_id, sequence_id as sequence_id, event_timestamp as event_timestamp, date as date, title as title, rake.extractKeyword(story) as topics, country as country, combo72 as region; 
counted_topics = FOREACH extract_topics GENERATE story_id as story_id, sequence_id as sequence_id, event_timestamp as event_timestamp, date as date, title as title, topics as topics, CountEach(items.(topics)) as count,country as country, region as region;

/*Dump all news*/
STORE counted_topics INTO 'UNICEF/complete_news' USING PigStorage();

/*Dump news sequence for R*/
r_input_news = FOREACH counted_topics GENERATE sequence_id as sequence_id, event_timestamp as event_timestamp, count as count,country as country, region as region;
STORE counted_topics INTO 'UNICEF/r_input_news' USING PigStorage();




