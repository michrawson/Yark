/**************************/
CSCI GA 3033-001
Yixue Wang yw1819@nyu.edu
Final Project
/**************************/


/****** Code Drop 1 *******/
Description :
Preprocess the data and load it into Hive Table 

File has already been updated. (See /src/Hive_preprocessing_GDELT.hql for details)


/****** Code Drop 2 *******/
Description :

Cleaned the data and calculate the frequency of every event code. Sort by frequency. Also provide the data of the most frequent event code (top 20)
Filenames : 
Code : /src/Hive_preprocessing_GDELT.hql src/frequency_GDELT.hql
Data: /data/sample_value_afterpreprocessing.csv
/data/top20_cameo_code.csv

/****** Code Drop 3 *******/
Description :

By using python and spark, mined the frequent pattern based on everyday’s news event code. 

Code : /src/frequentpatternmining.ipynb

/****** Final Code Drop *******/

Description:

Using d3.js to visualize the most frequent pattern based on everyday’s news event code.
Also create a decision tree model for Ariel’s data

Code: /vis
/src/decisionTree.py
