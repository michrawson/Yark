#install required packages
#install.packages("arules")
#install.packages("arulesSequences")
#if (!require('devtools')) install.packages('devtools')
#devtools::install_github('apache/spark@v1.4.0', subdir='R/pkg')
#install.packages("SparkR")

#Sys.setenv(SPARK_HOME="/home/kennyazrina/bin/spark")
#.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
#import required packages

#library(SparkR)
library(Matrix)
library(arules)
library(arulesSequences)

# Initialize SparkContext and SQLContext
#sc <- sparkR.init(master="local")
#sqlContext <- sparkRSQL.init(sc)

#load preprocessed news
news_file <- read_baskets("UNICEF/r_input_refined", info = c("sequenceID","eventID","SIZE"))


#generate news sequence
news_sequence_file <- cspade(news_file, parameter = list(support = 0.01, maxgap=7), control = list(verbose = TRUE))

#evaluate summary
summary(news_sequence_file)

#export to csv
df_news_sequence = as(news_sequence_file, "data.frame")
write.csv(df_news_sequence, file = "news_sequence_01.csv")

# Stop the SparkContext now
#sparkR.stop()