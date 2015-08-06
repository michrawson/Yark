data <- read.csv('result_small.csv',head=FALSE,sep=',')

data_scaled <- data

#scale values
for ( i in 2:ncol(data) ) { #for each col after date
	max_val <- max(data[i],na.rm=TRUE) #max of col
	min_val <- min(data[i],na.rm=TRUE) #min of col
	range_val <- max_val - min_val #range of col
	data_scaled[,i] <- (data[,i] - min_val) / range_val
}
spx_col <- 12
avg_spx_data <- c(1:(nrow(data)-60))
for( date_index in 1:(nrow(data)-60) ){
    avg_spx_data[date_index] <- mean(data_scaled[
                                       date_index:(date_index+60),spx_col], 
                                       na.rm=TRUE)
}

# cross validation/10-fold
for ( fold in 1:10 ) { #for each fold
    start <- 1
    trainingset <- data.frame(date=data_scaled[1:(nrow(data)-60),1])
    for( col in 2:(ncol(data)+1) ){
        trainingset[,col] <- 0
    }

    sampleCounter <- 1
    while( start + 183 + 60 <= length(data[,1]) ){
        counter <- 1

        #each training sample (6 months)
        for( date_val in start:(start+183-1) ){ #for each row
            for( k in 1:length(data) ){ #for each col
                trainingset[sampleCounter,counter] <- 
                        data_scaled[date_val,k]
                counter <- counter + 1
            }
        }
        trainingset[sampleCounter,counter] <- avg_spx_data[start]
        sampleCounter <- sampleCounter + 1
        start <- start + 1
    }
    formulaString <- "future ~ "
    formulaString <- formulaString + " " + colnames(data)[i] + " "
    for(i in 2:ncol(data)){
        formulaString <- formulaString + " + " + colnames(data)[i] + " "
    }
    print(formulaString)

    stocknet <- neuralnet( formulaString, trainingset, 
                           hidden = length(trainingset), 
                           linear.output = FALSE,
                           threshold = 0.1)
    stocknet

    print(trainingset)
}

