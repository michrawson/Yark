library("neuralnet")

valid_dates <- function( dates ){
    for( i in 1:length(dates) ){
        if( !(dates[i]<=20151231 && dates[i]>=19900101) ){
            return(FALSE)
        }
    }
    return(TRUE)
}

valid_inputs <- function( inputs ){
    for( i in 1:length(inputs) ){
        if( !(inputs[i]<=1 && inputs[i]>=0) ){
            return(FALSE)
        }
    }
    return(TRUE)
}

ptm <- proc.time()

#import data
data_time_series <- read.csv('result_small.csv',head=FALSE,
                             sep=',', na.strings=c('0') )
#setup constants
spx_col <- 12
two_month <- 60
one_month <- 30
half_year <- 183
sample_day_count <- half_year

#remove NAs
for(i in 1:ncol(data_time_series)){
    for(j in 1:nrow(data_time_series)){
        if( is.na(data_time_series[j,i]) ){
            data_time_series[j,i] <- 0
        }
    }
}
print('Cleaned NA')

stopifnot(valid_dates(data_time_series[[1]]))

data_scaled <- data_time_series

#scale values
for ( i in 2:ncol(data_scaled) ) { #for each col after date
	max_val <- max(data_scaled[i],na.rm=TRUE) #max of col
	min_val <- min(data_scaled[i],na.rm=TRUE) #min of col
	range_val <- max_val - min_val #range of col
	data_scaled[i] <- (data_scaled[i] - min_val) / range_val
    stopifnot(valid_inputs(data_scaled[[i]]))
}
print('Scaled data')

#calculate spx 2 month averages
avg_spx_data <- c(1:(nrow(data_scaled)-two_month))
for( date_index in 1:(nrow(data_scaled)-two_month) ){
    avg_spx_data[date_index] <- mean(data_scaled[
                               date_index:(date_index+two_month),spx_col], 
                                       na.rm=TRUE)
}
stopifnot(valid_inputs(avg_spx_data))
print('Calculated outputs')

#find out number of samples that can be taken
current_date_index <- sample_day_count
sample_size <- 0
while( current_date_index + sample_day_count + two_month <= 
            nrow(data_scaled)){ #stop when we've run out of dates
    current_date_index <- current_date_index + sample_day_count
    sample_size <- sample_size + 1
}

random_start <- sample( sample_day_count, 1, replace=F)
print(paste('random sample: ',random_start))

#setup training set data frame
ptm2 <- proc.time()
trainingset <- 
    data.frame(date=c(1:sample_size))
for( col in 2:(((ncol(data_scaled)-1)*sample_day_count)+1) ){
    trainingset[col] <- -1
}

current_date_index <- random_start
#for each sample, add to training set
for( sampleCounter in 1:sample_size){
    ptm3 <- proc.time()

    trainingset[sampleCounter,1] <- 
                    data_scaled[current_date_index,1]
    col_counter <- 2

    #setup each training sample 
    for( date_val in current_date_index: #for each row
                (current_date_index+sample_day_count-1) ){
        for( k in 2:ncol(data_scaled) ){ #for each col
            #copy each value
            trainingset[sampleCounter,col_counter] <- 
                    data_scaled[date_val,k]
            col_counter <- col_counter + 1
        }
    }
    #copy future average column
    trainingset[sampleCounter,col_counter] <- 
        avg_spx_data[current_date_index+sample_day_count]
    print(paste('Sample: ', sampleCounter))

    current_date_index <- current_date_index + sample_day_count

    print('Sample time')
    print(proc.time() - ptm3)
}

colnames(trainingset) <- c(
                    colnames(trainingset)[1:(ncol(trainingset)-1)],
                           'future')

stopifnot(valid_dates(trainingset[[1]]))
for( i in 2:ncol(trainingset) ){
    stopifnot(valid_inputs(trainingset[[i]]))
}

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

for( i in 1:ncol(trainingset_scaled_dates) ){
    stopifnot(valid_inputs(trainingset_scaled_dates[[i]]))
}

print('Setup trainingset time')
print(proc.time() - ptm2)

#stocknet <- c(1:10)
# cross validation/10-fold
for ( ignore_fold in 0:(sample_size-1) ) { #for each fold
    reserve_date_index <- random_start + (sample_day_count*ignore_fold)
    reserve_date <- trainingset_scaled_dates[reserve_date_index,1]

    #trainingsubset ignoring fold
    trainingsubset <- subset(trainingset_scaled_dates, date!=reserve_date)

    print('Creating Neural Net')
    ptm4 <- proc.time()
    #create neural net
    temp_net <- neuralnet(
                 as.formula(paste('future', 
                              paste(colnames(trainingset_scaled_dates)[2:
                                    (ncol(trainingset_scaled_dates)-1)], 
                                    collapse=" + "), 
                              sep=" ~ ")),
                          trainingset_scaled_dates, 
                          hidden = ncol(trainingset_scaled_dates), 
                         threshold = 0.1, lifesign='full', rep=3)
 
    print('neural network creation time:')
    print(proc.time() - ptm4)

    print(temp_net)
    #stocknet[ignore_fold+1] <- temp_net

    ignored_sample <- subset(trainingset_scaled_dates, date=reserve_date)[
                                    1:(ncol(trainingset_scaled_dates)-1)]
    ignored_result <- subset(trainingset_scaled_dates, date=reserve_date)[
                                    ncol(trainingset_scaled_dates)]

    ptm5 <- proc.time()

    validation_result <- compute(temp_net, ignored_sample)
    print(validation_result)
    print('validation mean error:')
    print(mean(abs(validation_result$net.result-ignored_result$future)))
    print('computer validation set time:')
    print(proc.time() - ptm5)
}

print('Total time')
print(proc.time() - ptm)

