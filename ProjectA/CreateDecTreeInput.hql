create database crisis;
use crisis;

Create external table myvars  (ID string, vals string) row format delimited fields terminated by '\t'  location 'hdfs://babar.es.its.nyu.edu:8020/user/bad225/proc/';

Create external table labels (ccode string,country string,year string,month string,time string,ins string,reb string,dpc string,erv string,ic string,notes string,coder string,insnotes string,dpcnotes string,rebnotes string,ervnotes string,icnotes string) row format delimited fields terminated by ',' location 'hdfs://babar.es.its.nyu.edu:8020/user/bad225/labels/';

select labels.ins,  labels.reb   ,labels.dpc  , labels.erv ,concat(labels.ic,",") , myvars.vals  from myvars inner join labels  where myvars.ID = concat (labels.ccode,"_",labels.year,"_",month)               

