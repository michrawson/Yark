/*****************PROJECT YARK*********************/
/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu       */
/* Michael Rawson mr4209             */
/* Yixue Wang yw1819@nyu.edu         */
/**************************************************/

REGISTER pig_udf.jar;
ALL_DATES = load 'ALL_DATES.csv' using PigStorage(',') as (date:chararray);
CPI = load 'CPI_CHNG.csv' using PigStorage(',') as (date:chararray, price:chararray);
GDP = load 'GDP_CQOQ.csv' using PigStorage(',') as (date:chararray, price:chararray);
GDELT = load 'GDELT.txt' using PigStorage('\t');
GDELT = foreach GDELT generate $0 as date, $1 .. $17;
SPX = load 'SPX.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5COND = load 'S5COND.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5CONS = load 'S5CONS.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5ENRS = load 'S5ENRS.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5FINL = load 'S5FINL.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5HLTH = load 'S5HLTH.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5INDU = load 'S5INDU.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5INFT = load 'S5INFT.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5MATR = load 'S5MATR.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5TELS = load 'S5TELS.csv' using PigStorage(',') as (date:chararray, price:chararray);
S5UTIL = load 'S5UTIL.csv' using PigStorage(',') as (date:chararray, price:chararray);
mt = join ALL_DATES by date left, S5COND by date using 'replicated';
mt = foreach mt generate $0 as date, S5COND::price;
mt = join mt by date left, S5CONS by date using 'replicated';
mt = foreach mt generate $0 as date, $1, S5CONS::price;
mt = join mt by date left, S5ENRS by date using 'replicated';
mt = foreach mt generate $0 as date, $1, $2, S5ENRS::price;
mt = join mt by date left, S5FINL by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $3, S5FINL::price;
mt = join mt by date left, S5HLTH by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $4, S5HLTH::price;
mt = join mt by date left, S5INDU by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $5, S5INDU::price;
mt = join mt by date left, S5INFT by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $6, S5INFT::price;
mt = join mt by date left, S5MATR by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $7, S5MATR::price;
mt = join mt by date left, S5TELS by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $8, S5TELS::price;
mt = join mt by date left, S5UTIL by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $9, S5UTIL::price;
mt = join mt by date left, SPX by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $10, SPX::price;
mt = join mt by date left, GDP by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $11, GDP::price;
mt = join mt by date left, CPI by date using 'replicated';
mt = foreach mt generate $0 as date, $1 .. $12, CPI::price;
mt = foreach mt generate pig_udf.CustomDateConvert($0) as date, $1 .. $13;
store mt into 'master_table' using PigStorage(',');

