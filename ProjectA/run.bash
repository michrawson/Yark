hadoop crisis facts output
rm -rf output
hadoop fs -get output
hadoop fs -rm -r proc 
hadoop fs -mkdir proc
hadoop fs -put output/part-r-00000 proc/processed 
