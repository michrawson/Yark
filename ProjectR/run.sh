/*****************PROJECT YARK*********************/
/* Ariel Boris Dexter bad225@nyu.edu */
/* Kania Azrina ka1531@nyu.edu       */
/* Michael Rawson mr4209             */
/* Yixue Wang yw1819@nyu.edu         */
/**************************************************/

set -x

rm -fr master_table
rm -f pig_udf/CustomDateConvert.class CustomDateConvert.jar pig_*.log

cd pig_udf
STATUS=$?
if [[ ${STATUS} -ne 0 ]]; then
	echo 'Failure:'
        exit $STATUS
fi

javac -cp ".:$PIG_HOME/lib/hadoop1-runtime/*:$PIG_HOME/lib/*:$PIG_HOME/*" CustomDateConvert.java 
STATUS=$?
if [[ ${STATUS} -ne 0 ]]; then
	echo 'Failure:'
	exit $STATUS
fi

cd ..
jar cf pig_udf.jar pig_udf
STATUS=$?
if [[ ${STATUS} -ne 0 ]]; then
	echo 'Failure:'
        exit $STATUS
fi

java -cp ".:$PIG_HOME/lib/hadoop1-runtime/*:$PIG_HOME/lib/*:$PIG_HOME/*" org.apache.pig.Main -x local preprocess.pig
STATUS=$?
if [[ ${STATUS} -ne 0 ]]; then
	echo 'Failure:'
        exit $STATUS
fi

