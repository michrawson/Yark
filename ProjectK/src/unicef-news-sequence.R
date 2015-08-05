#install required packages
install.packages("arules")
install.packages("arulesSequences")

#import required packages
library(Matrix)
library(arules)
library(arulesSequences)

#load preprocessed news
news <- read_baskets("r_input_news", info = c("sequenceID","eventID","SIZE"))

#generate news sequence
news_sequence <- cspade(news, parameter = list(support = 0.5), control = list(verbose = TRUE))

#evaluate summary
summary(news_sequence)

#export to csv
df_news_sequence = as(news_sequence, "data.frame")
write.csv(df_news_sequence, file = "news_sequence.csv")