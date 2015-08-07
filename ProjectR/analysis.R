ptm <- proc.time()

library("neuralnet")

#import data
data_time_series <- read.csv('result_small.csv',head=FALSE,
                             sep=',', na.strings=c('0') )
#setup constants
spx_col <- 12
two_month <- 60
one_month <- 30
half_year <- 183
sample_day_count <- half_year
sample_size <- 0

#remove NAs
for(i in 1:ncol(data_time_series)){
    for(j in 1:nrow(data_time_series)){
        if( is.na(data_time_series[j,i]) ){
            data_time_series[j,i] <- 0
        }
    }
}
print('Cleaned NA')

data_scaled <- data_time_series

if(TRUE){ #fast mode for debugging
sample_size <- 10
}

#scale values
for ( i in 2:ncol(data_scaled) ) { #for each col after date
	max_val <- max(data_scaled[i],na.rm=TRUE) #max of col
	min_val <- min(data_scaled[i],na.rm=TRUE) #min of col
	range_val <- max_val - min_val #range of col
	data_scaled[,i] <- (data_scaled[,i] - min_val) / range_val
}
print('Scaled data')

#calculate spx 2 month averages
avg_spx_data <- c(1:(nrow(data_scaled)-two_month))
for( date_index in 1:(nrow(data_scaled)-two_month) ){
    avg_spx_data[date_index] <- mean(data_scaled[
                               date_index:(date_index+two_month),spx_col], 
                                       na.rm=TRUE)
}
print('Calculated outputs')

reserve_count <- floor(0.1*nrow(data_scaled))
random_start <- sample( sample_day_count, 1, replace=F)
print(paste('random sample: ',random_start))

#setup training set data frame
ptm2 <- proc.time()
trainingset <- 
    data.frame(date=c(1:sample_size))
for( col in 2:((ncol(data_scaled)*sample_day_count)+1) ){
    trainingset[,col] <- 0
}

current_date_index <- random_start
sampleCounter <- 1
#for each sample, add to training set
while( current_date_index + sample_day_count + two_month <= 
            nrow(data_scaled)){ #stop when we've run out of dates
    ptm3 <- proc.time()
    col_counter <- 1

    #setup each training sample 
    for( date_val in current_date_index: #for each row
                (current_date_index+sample_day_count-1) ){
        for( k in 1:ncol(data_scaled) ){ #for each col
            #copy each column
            trainingset[sampleCounter,col_counter] <- 
                    data_scaled[date_val,k]
            col_counter <- col_counter + 1
        }
    }
    #copy future average column
    trainingset[sampleCounter,col_counter] <- 
        avg_spx_data[current_date_index+sample_day_count]
    print(sampleCounter)
    print(length(trainingset[sampleCounter,]))
    print(paste('Sample: ', sampleCounter))

    sampleCounter <- sampleCounter + 1
    current_date_index <- current_date_index + sample_day_count

    print('Sample time')
    print(proc.time() - ptm3)
    if( sample_size>0 && sampleCounter > sample_size ){
        print('reached max samples')
        break
    }
    print(paste(current_date_index, 
            current_date_index + sample_day_count + two_month, 
            nrow(data_scaled), sep=' '))
}
colnames(trainingset) <- c(
                    colnames(trainingset)[1:(ncol(trainingset)-1)],
                           'future')

#convert dates to seconds since 1960-01-01 00:00:00
trainingset_scaled_dates<- data.frame(date=round(
    (floor(trainingset[1]/100/100)-1960)*365.25*24*60 #year component
  + ((floor(trainingset[1]/100)%%100)-1)/12*365.25*24*60 #month component
  + (trainingset[1]%%100)*24*60 #day component
  ), trainingset[2:ncol(trainingset)])
#scale dates
max_val <- max(trainingset_scaled_dates[1],na.rm=TRUE) #max of col
min_val <- min(trainingset_scaled_dates[1],na.rm=TRUE) #min of col
range_val <- max_val - min_val #range of col
trainingset_scaled_dates[1] <- 
            (trainingset_scaled_dates[1] - min_val) / range_val

print('Setup trainingset time')
print(proc.time() - ptm2)

stocknet <- c(1:10)
# cross validation/10-fold
for ( ignore_fold in 0:9 ) { #for each fold
    reserve_date_index <- random_start + (sample_day_count*ignore_fold)
    reserve_date <- trainingset_scaled_dates[reserve_date_index,1]

    #trainingsubset ignoring fold
    trainingsubset <- subset(trainingset_scaled_dates, date!=reserve_date)

    print('Creating Neural Net')
    ptm4 <- proc.time()
    #create neural net
    temp_net <- neuralnet(
                 as.formula(paste('future', 
                              paste(colnames(trainingset_scaled_dates)[1:
                                    (ncol(trainingset)-1)], 
                                    collapse=" + "), 
                              sep=" ~ ")),
                          trainingset_scaled_dates, 
                          hidden = nrow(trainingset_scaled_dates), 
                         threshold = 0.1, lifesign='full')
 
    print('neural network creation time:')
    print(proc.time() - ptm4)

    print(temp_net)
    plot(temp_net)
    stocknet[ignore_fold+1] <- temp_net

    ignored_sample <- subset(trainingset_scaled_dates, date=reserve_date)

    ptm5 <- proc.time()

    validation_result <- compute(temp_net, ignored_sample)
    print(validation_result)
    print('computer validation set time:')
    print(proc.time() - ptm5)
}
print('Total time')
print(proc.time() - ptm)

