ptm <- proc.time()

library("neuralnet")
data <- read.csv('result_small.csv',head=FALSE,sep=',', na.strings=c('0') )
spx_col <- 12
two_month <- 60
one_month <- 30
half_year <- 183
sample_day_count <- half_year
sample_size <- 0

for(i in 1:ncol(data)){
    for(j in 1:nrow(data)){
        if( is.na(data[j,i]) ){
            data[j,i] <- 0
        }
    }
}

data_scaled <- data

if(TRUE){ #fast mode for debugging
sample_day_count <- one_month
sample_size <- 5
}

#scale values
for ( i in 2:ncol(data) ) { #for each col after date
	max_val <- max(data[i],na.rm=TRUE) #max of col
	min_val <- min(data[i],na.rm=TRUE) #min of col
	range_val <- max_val - min_val #range of col
	data_scaled[,i] <- (data[,i] - min_val) / range_val
}

avg_spx_data <- c(1:(nrow(data)-two_month))
for( date_index in 1:(nrow(data)-two_month) ){
    avg_spx_data[date_index] <- mean(data_scaled[
                               date_index:(date_index+two_month),spx_col], 
                                       na.rm=TRUE)
}

# cross validation/10-fold
for ( fold in 1:10 ) { #for each fold
    ptm2 <- proc.time()
    if( sample_size>0 ){
        trainingset <- 
            data.frame(date=data_scaled[1:(sample_size),1])
    } else {
        trainingset <- 
            data.frame(date=data_scaled[1:(nrow(data)-two_month),1])
    }
    for( col in 2:(ncol(data)+1) ){
        trainingset[,col] <- 0
    }

    start <- 1
    sampleCounter <- 1
    #for each sample
    while( start + sample_day_count + two_month <= nrow(data) ){
        ptm3 <- proc.time()
        counter <- 1

        #each training sample 
        for( date_val in start:(start+sample_day_count-1) ){ #for each row
            for( k in 1:ncol(data) ){ #for each col
                trainingset[sampleCounter,counter] <- 
                        data_scaled[date_val,k]
                counter <- counter + 1
            }
        }
        trainingset[sampleCounter,counter] <- avg_spx_data[start]
        print(trainingset[sampleCounter,])
        print(sampleCounter)

        sampleCounter <- sampleCounter + 1
        start <- start + 1
 
        print('Sample time')
        print(proc.time() - ptm3)
        if( sample_size>0 && sampleCounter >=sample_size ){
            break
        }
    }
    colnames(trainingset) <- c(
                        colnames(trainingset)[1:(ncol(trainingset)-1)],
                               'future')

    stocknet <- neuralnet(
                 as.formula(paste('future', 
                              paste(colnames(trainingset)[1:
                                    (length(colnames(trainingset))-1)], 
                                    collapse=" + "), 
                              sep=" ~ ")),
                          trainingset, 
                           hidden = length(trainingset), 
    #                       linear.output = FALSE,
                           threshold = 0.1)
    print(stocknet)

    print(trainingset)

    print('Fold time')
    print(proc.time() - ptm2)
}

print('Total time')
print(proc.time() - ptm)

