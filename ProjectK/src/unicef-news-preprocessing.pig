/*****************PROJECT YARK*********************/
/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu */
/* Michael Rawson mr4209@nyu.edu */
/* Yixue Wang yw1819@nyu.edu */
/**************************************************/

/*Load UDF*/
REGISTER UNICEF/tutorial.jar;

/*Load seperate news*/
news_2013_2015 = LOAD 'UNICEF/OPSCEN_Brief_2013_2015.txt' USING PigStorage('\t') AS (story:chararray, title:charArray, source:charArray, country:charArray, combo102:chararray,entryDate:charArray);
news_2005_2014 = LOAD 'UNICEF/OPSCEN_Brief_2005_2014.txt' USING PigStorage('\t') AS (story:chararray, sourceName:chararray, title:chararray, country:chararray, combo61:chararray, eventDate:charArray, dueDate:charArray, sourceLink:charArray, entryDate:charArray, combo72:charArray, thematicArea:charArray);

/*Project news based on selected attribute*/
news_2013_2015_selected = FOREACH news_2013_2015 GENERATE entryDate as date, title as title, story as story, country as country, combo102 as region;
news_2005_2014_selected = FOREACH news_2005_2014 GENERATE eventDate as date, title as title, story as story, country as country, combo72 as region; 

/*Join, delete null and give indexes*/
all_news = UNION news_2005_2014_selected, news_2013_2015_selected;
clean_all_news = FILTER all_news BY date != '';

/*Prepare to be used in R*/
/*R Input : sequence id, event timestamp, number of item and <list of items>*/
/*source https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Sequence_Mining/SPADE*/



