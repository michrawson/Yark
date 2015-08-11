#install required packages
install.packages("arules")
install.packages("arulesSequences")

#import required packages
library(Matrix)
library(arules)
library(arulesSequences)

#load preprocessed news
news_file <- read_baskets("UNICEF/r_input_refined", info = c("sequenceID","eventID","SIZE"))

#generate news sequence
news_sequence_file <- cspade(news_file, parameter = list(support = 0.01, maxgap=7, maxsize =1), control = list(verbose = TRUE))

#evaluate summary
summary(news_sequence_file)

#export to csv
df_news_sequence = as(news_sequence_file, "data.frame")
write.csv(df_news_sequence, file = "news_sequence_01.csv")
