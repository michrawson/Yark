/*****************PROJECT YARK*********************/
/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu       */
/* Michael Rawson mr4209             */
/* Yixue Wang yw1819@nyu.edu         */
/**************************************************/

Create external table ICEWS  (ccode string,country string,year int,month string,time string,ins tinyint,reb tinyint,dpc tinyint,erv tinyint,ic tinyint,notes string,coder string,insnotes string,dpcnotes string,rebnotes string,ervnotes string,icnotes string) row format delimited fields terminated by ',' location 'hdfs://babar.es.its.nyu.edu:8020/user/bad225/project/';

select country, sum(ins), sum(reb), sum(dpc),sum(erv), sum(ic) from ICEWS group by country order by country;
