-- summarize all cameocode for all the years from 1970 to 2014

insert overwrite local directory '/home/cloudera/Desktop/frequency_all'
row format delimited fields terminated by ','
select cameocode, sum(cast(numevents as bigint)) as sum
from gdelt_table2
group by cameocode
sort by sum DESC;
