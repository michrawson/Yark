
# coding: utf-8

# In[21]:

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


# In[22]:

#import news from pig
news = pd.read_csv('extracted_topics', sep='	', names=['CountryID', 'SequenceID', 'Timestamp','Title','Story','Keywords','Country','Region'])
news['Timestamp'] = pd.to_datetime(news['Timestamp'].str[:10], format = '%Y-%m-%d')
news['Timestamp'] = news['Timestamp'].values.astype('M8[D]')

#load news count
news_count = pd.read_csv('keyword_list.csv', sep=',', names=['ID', 'Topic', 'Count'], header=True)

#load treasury data (and percent changes)

treasury = pd.read_csv('treasury.csv', names=['Date', 'PercentChange'],header=True, parse_dates=True)
treasury['Date'] = pd.to_datetime(treasury['Date'].str[:10], format = '%Y-%m-%d')
treasury['PercentChange'] = treasury['PercentChange'].convert_objects(convert_numeric=True)
treasury = treasury.set_index(pd.DatetimeIndex(treasury['Date']))


# In[23]:

#for each topic, get the dates where it occurs and its country
def getDateCount(topic) :
    filteredNews = news[news['Keywords'].str.contains(topic)]
    dates = filteredNews['Timestamp'].tolist()
    datesCount = {}
    for date in dates :
        if date not in datesCount:
            datesCount[date] = 1
        else :
            datesCount[date] += 1
    return datesCount


# In[24]:

frequentTopics = news_count['Topic'].tolist()

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


# In[25]:

topic_avg = []

for topic in frequentTopics:
    try :
        dates = getDateCount(topic)
    except :
        print "error in parsing dates"
    topic_avg.append(getChangeAvg(dates))


# In[26]:

news_count_change = news_count
news_count_change['change'] = topic_avg


# In[27]:




# In[28]:

news_count_change.to_csv("news_topic_count.csv", index=False, sep=",")

