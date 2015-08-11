javac -cp $(hadoop classpath) *.java
jar -cf crisis.jar *.class
export HADOOP_CLASSPATH=crisis.jar
hadoop fs -rm -r output


