install.packages("arules")
install.packages("arulesSequences")

library(Matrix)
library(arules)
library(arulesSequences)

news <- read_baskets("r_input_news", info = c("sequenceID","eventID","SIZE"))
as(news, "data.frame")

news_sequence <- cspade(news, parameter = list(support = 0.5), control = list(verbose = TRUE))

summary(news_sequence)
as(news_sequence, "data.frame")