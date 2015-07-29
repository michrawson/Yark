data <- read.csv('result.csv',head=FALSE,sep=',')

data_scaled <- data

for ( i in 1:length(data) ) {
        max_val <- max(data[i],na.rm=TRUE)
        min_val <- min(data[i],na.rm=TRUE)
        range_val <- max_val - min_val
        for ( j in 1:length(data[i]) ) {
                data_scaled[i][j] <- (data[i][j] - min_val) / range_val
        }
}

# cross validation/10-fold
for ( i in 1:10 ) {
        #
}

#data_scaled
#summary(data)
#summary(data_scaled)

