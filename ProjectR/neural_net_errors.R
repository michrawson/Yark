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
print('Importing data...')
data_time_series <- read.csv('result.csv',head=FALSE,
                             sep=',', na.strings=c('0') )
ncol_data = ncol(data_time_series)
nrow_data = nrow(data_time_series)

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
stopifnot(ncol(data_time_series)==ncol_data)
stopifnot(nrow(data_time_series)==nrow_data)

data_scaled <- data_time_series

#scale values
for ( i in 2:ncol(data_scaled) ) { #for each col after date
    max_val <- max(data_scaled[i],na.rm=TRUE) #max of col
    min_val <- min(data_scaled[i],na.rm=TRUE) #min of col
    range_val <- max_val - min_val #range of col
    data_scaled[i] <- (data_scaled[i] - min_val) / range_val
    stopifnot(valid_inputs(data_scaled[[i]]))
}
stopifnot(ncol(data_scaled)==ncol_data)
stopifnot(nrow(data_scaled)==nrow_data)

print('Scaled data')

#calculate spx 2 month averages
avg_spx_data <- c(1:(nrow(data_scaled)-two_month))
for( date_index in 1:(nrow(data_scaled)-two_month) ){
    avg_spx_data[date_index] <- mean(data_scaled[
                               date_index:(date_index+two_month),spx_col], 
                                       na.rm=TRUE)
}
stopifnot(valid_inputs(avg_spx_data))
stopifnot(length(avg_spx_data)==(nrow(data_scaled)-two_month))

print('Calculated outputs')

#find out number of samples that can be taken
current_date_index <- sample_day_count
sample_size <- 0
while( current_date_index + sample_day_count + two_month <= 
            nrow(data_scaled)){ #stop when we've run out of dates
    current_date_index <- current_date_index + sample_day_count
    sample_size <- sample_size + 1
}
stopifnot(sample_size>=10)

random_start <- sample( 1:sample_day_count, 1, replace=F)
print(paste('random sample: ',random_start))

#setup training set data frame
ptm2 <- proc.time()
trainingset <- 
    data.frame(date=c(1:sample_size))
for( col in 2:(((ncol(data_scaled)-1)*sample_day_count)+1+1) ){
    trainingset[col] <- -1
}
stopifnot(ncol(trainingset)==((ncol_data-1)*sample_day_count+1+1))
stopifnot(nrow(trainingset)==sample_size)

print('Preparing samples...')

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
stopifnot(ncol(trainingset)==((ncol_data-1)*sample_day_count+1+1))
stopifnot(nrow(trainingset)==sample_size)

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

stopifnot(ncol(trainingset_scaled_dates)==ncol(trainingset))
stopifnot(nrow(trainingset_scaled_dates)==sample_size)

for( i in 1:ncol(trainingset_scaled_dates) ){
    stopifnot(valid_inputs(trainingset_scaled_dates[[i]]))
}

print('Setup trainingset time')
print(proc.time() - ptm2)

validation_sample_size <- floor(sample_size/10)
stopifnot(validation_sample_size>=1)
reserved_samples <- sample( 1:sample_size, sample_size, replace=F)
stopifnot(length(reserved_samples)==sample_size)

reserved_sample_counter <- 1

print('Total time so far...')
print(proc.time() - ptm)

# cross validation/10-fold
for ( fold in 0:10 ) { #for each fold
    #create subset of training data
    #trainingsubset ignoring fold via random pick of 10%
    trainingsubset <- trainingset_scaled_dates[
                    (-1*reserved_samples[reserved_sample_counter:
                    (reserved_sample_counter+validation_sample_size-1)]), ]
    stopifnot(ncol(trainingsubset)==ncol(trainingset_scaled_dates))
    stopifnot(nrow(trainingsubset)==
              nrow(trainingset_scaled_dates)-validation_sample_size)
    
    for( i in 1:ncol(trainingsubset) ){
        stopifnot(valid_inputs(trainingsubset[[i]]))
    }

    reserved_sample_counter <- reserved_sample_counter + 
                                                validation_sample_size

    print(paste('Creating Neural Net [', fold, '] ...'))
    ptm4 <- proc.time()
    #create neural net
    temp_net <- neuralnet(
                 as.formula(paste('future', 
                              paste(colnames(trainingsubset)[2:
                                    (ncol(trainingsubset)-1)], 
                                    collapse=" + "), 
                              sep=" ~ ")),
                          trainingsubset, 
                         hidden = floor(1/10*ncol(trainingsubset)), 
                         threshold = 0.1, lifesign='full', rep=3)
 
    print('neural network creation time:')
    print(proc.time() - ptm4)

    print(temp_net)

    ignored_sample <- trainingset_scaled_dates[
                    (reserved_samples[reserved_sample_counter:
                    (reserved_sample_counter+validation_sample_size-1)]),
                    1:(ncol(trainingset_scaled_dates)-1)]
    stopifnot(ncol(ignored_sample)==ncol(trainingset_scaled_dates)-1)
    stopifnot(nrow(ignored_sample)== validation_sample_size)
    
    for( i in 1:ncol(ignored_sample) ){
        stopifnot(valid_inputs(ignored_sample[[i]]))
    }

    ignored_result <- trainingset_scaled_dates[
                    (reserved_samples[reserved_sample_counter:
                    (reserved_sample_counter+validation_sample_size-1)]),
                    ncol(trainingset_scaled_dates)]
    stopifnot(ncol(ignored_result)==1)
    stopifnot(nrow(ignored_result)== validation_sample_size)
    
    for( i in 1:length(ignored_result) ){
        stopifnot(valid_inputs(ignored_result[i]))
    }

    ptm5 <- proc.time()

    print('Computing...')
    validation_result <- compute(temp_net, 
                                 ignored_sample[,2:ncol(ignored_sample)])
    print(validation_result)
    print('True result:')
    print(ignored_result)
    print('validation mean error:')
    print(mean((validation_result$net.result-ignored_result)^2))
    print('computer validation set time:')
    print(proc.time() - ptm5)
}

print('Total time')
print(proc.time() - ptm)

