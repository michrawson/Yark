
# coding: utf-8

# In[181]:

#*****************PROJECT YARK*********************/
#* Ariel Boris Dexter bad225@nyu.edu */
#* Kania Azrina ka1531@nyu.edu       */
#* Michael Rawson mr4209             */
#* Yixue Wang yw1819@nyu.edu         */
#**************************************************/


#import required packages
import sys
import datetime
import csv
import math
import pandas as pd 
import numpy as np 
from scipy import stats 
import statsmodels.formula.api as sm
import matplotlib.pyplot as plt
from statsmodels.sandbox.regression.predstd import wls_prediction_std
from mpltools import style
from mpltools import layout
from pandas.tools.plotting import autocorrelation_plot
import json


# In[182]:

#import news from pig
news = pd.read_csv('../data/extracted_topics_refined', sep='	', names=['CountryID', 'SequenceID', 'Timestamp',
                                                          'Title','Story','Keywords','Country','Region', 'Count'],header=True)
news['Timestamp'] = pd.to_datetime(news['Timestamp'].str[:10], format = '%Y-%m-%d')
news['Timestamp'] = news['Timestamp'].values.astype('M8[D]')

#load news count
news_count = pd.read_csv('../data/keyword_list.csv', sep=',', names=['ID', 'Topic', 'Count'])

#load treasury data (and percent changes)
treasury = pd.read_csv('../data/treasury.csv', names=['Date', 'PercentChange'],header=True, parse_dates=True)
treasury['Date'] = pd.to_datetime(treasury['Date'].str[:10], format = '%Y-%m-%d')
treasury['PercentChange'] = treasury['PercentChange'].convert_objects(convert_numeric=True)
treasury = treasury.set_index(pd.DatetimeIndex(treasury['Date']))


# In[183]:

treasury.head()


# In[184]:

news.head()


# In[185]:

frequentTopics = news['Keywords'].tolist()


#for each topic, get the dates where it occurs and its country
def getDateCount(topic) :
    filteredNews = news[news['Keywords'].split(" ").contains(topic)]
    dates = filteredNews['Timestamp'].tolist()
    datesCount = {}
    for date in dates :
        if date not in datesCount:
            datesCount[date] = 1
        else :
            datesCount[date] += 1
    return datesCount


# In[186]:

def getChangeAvg(dates):
    valueList = []
    for date in dates :
        newDate = date.strftime('%Y-%m-%d')
        indexList = treasury[treasury['Date']== newDate].index.tolist()
        newTre = treasury.loc[indexList]
        newlist = newTre['PercentChange'].tolist()
        if (len(newlist)!=0):
            valueList.append(newlist[0])
    return np.nanmean(valueList)


# In[192]:

topic_avg = []

#for each topic, get the average percent changes
for topic in frequentTopics[:5] :
    avg = 0
    try :
        dates = getDateCount(topic)
        avg = getChangeAvg(dates)
    except :
        print "error in parsing dates"
        avg = 0
        
    topic_avg.append(avg)


# In[191]:

print topic_avg


# In[188]:

#store to csv
#news_count_change = news_count[:5]
#news_count_change['Changes'] = topic_avg
#ews_count_change = news_count_change[1:]
#news_count_change.to_csv('../data/keyword_list_count.csv',index=False)


# In[ ]:



