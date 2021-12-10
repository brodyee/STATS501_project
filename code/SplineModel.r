library("tidyverse")
library("dplyr")
library("mgcv")
library("mgcViz")

dat = read_delim('violenceKNNResp_wSex_NotSplitImp.csv', delim = ",")
knn_dat = read_delim('violenceKNN.csv', delim = ",") %>% select(-c(violenceScore))
split_dat = right_join(dat, knn_dat, by = c("year", "sitename")) %>% 
    mutate(violenceScore = `violence score`) %>% 
    select(-c(4,5))

head(split_dat)

both_smooth = gam(violenceScore ~ 
              s(SNAP, by = sex, bs = "cr", k = 5) + 
              s(UnemploymentRate, by = sex, bs = "cr", k = 5) + 
              s(as.factor(split_dat$sitename), bs = "re"), data = split_dat)
both_AIC = AIC(both_smooth)

UnemployRate_smooth = gam(violenceScore ~ SNAP +
              s(UnemploymentRate, by = sex, bs = "cr", k = 5) + 
              s(as.factor(split_dat$sitename), bs = "re"), data = split_dat)
UnemployRate_AIC = AIC(UnemployRate_smooth)

SNAP_smooth = gam(violenceScore ~ 
              s(SNAP, by = sex, bs = "cr", k = 5) + 
              UnemploymentRate + s(as.factor(split_dat$sitename), bs = "re"), data = split_dat)
SNAP_AIC = AIC(SNAP_smooth)

neither_smooth = gam(violenceScore ~ SNAP + UnemploymentRate +
              s(as.factor(split_dat$sitename), bs = "re"), data = split_dat)
neither_AIC = AIC(neither_smooth)

AIC_mat = matrix(c(both_AIC, SNAP_AIC, UnemployRate_AIC, neither_AIC), nrow = 4)

rowNames = c("Both Smooth AIC", "SNAP Smooth AIC", "Unemployment Rate Smooth AIC", "Neither Smooth AIC")
row.names(AIC_mat) = rowNames

AIC_mat

# Both fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ s(SNAP, by = sex, bs = "cr", k = k) + 
                                  s(UnemploymentRate, by = sex, bs = "cr", k = k) + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])
          
    
  }#for
  
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

both_MSE = CrossValMSE(k = 5, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)

# UnemploymentRate fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ SNAP + 
                                  s(UnemploymentRate, by = sex, bs = "cr", k = k) + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])
          
    
  }#for
  
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

UnemployRate_MSE = CrossValMSE(k = 5, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)

# SNAP fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ s(SNAP, by = sex, bs = "cr", k = k) + 
                                  UnemploymentRate + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])
          
    
  }#for
  
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

SNAP_MSE = CrossValMSE(k = 5, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)

# Neither fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ SNAP + UnemploymentRate + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])
          
    
  }#for
  
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

neither_MSE = CrossValMSE(k = 5, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)

MSE_mat = matrix(c(both_MSE, SNAP_MSE, UnemployRate_MSE, neither_MSE), nrow = 4, ncol = 3, byrow = TRUE)

rowNames = c("Both Smooth MSE", "SNAP Smooth MSE", "Unemployment Rate Smooth MSE", "Neither Smooth MSE")
rownames(MSE_mat) = rowNames

colNames = c("Total", "Male", "Female")
colnames(MSE_mat) = colNames

MSE_mat

# Both fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ s(SNAP, by = sex, bs = "cr", k = k) + 
                                  s(UnemploymentRate, by = sex, bs = "cr", k = k) + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])

  }#for
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

MSE = data.frame(matrix(0, nrow = 25, ncol = 3))
names = c("Total MSE", "Male MSE", "Female MSE")
rows = c(1:25)
colnames(MSE) = names
rownames(MSE) = rows


for (i in (1:25)) {
    MSE[i,] = CrossValMSE(k = i, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)
}

which.min(MSE[,1])
which.min(MSE[,2])
which.min(MSE[,3])

MSE[which.min(MSE[,1]),]

MSE

# Both fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, m, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ s(SNAP, by = sex, bs = "cr", k = k) + 
                                  s(UnemploymentRate, by = sex, bs = "cr", k = m) + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])

  }#for
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

MSE = data.frame(matrix(0, nrow = 400, ncol = 3))
names = c("Total MSE", "Male MSE", "Female MSE")
rows = c(1:400)
colnames(MSE) = names
rownames(MSE) = rows


for (i in (4:23)) {
    for (j in 4:23)
        MSE[(j-3) + (20*(i-4)),] = CrossValMSE(k = i, m = j, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)
}

which.min(MSE[,1])
which.min(MSE[,2])
which.min(MSE[,3])

MSE[which.min(MSE[,1]), ]

# SNAP(k = 17), UnemploymentRate(k = 6)

# Both fit with smoothing spline
library("gtools")
options(warn = -1)

CrossValMSE = function(k, m, modelGroup, nLeftOut, dat, mseSplitOn) {
  
  # Make all combinations for pairs of county
  leftOutCols = combinations(length(t(unique(dat[modelGroup]))), nLeftOut, v = t(unique(dat[modelGroup])))
  
  msesSplit = rep(0,dim(leftOutCols)[1])
  msesSplit_male = rep(0,dim(leftOutCols)[1])
  msesSplit_female = rep(0,dim(leftOutCols)[1])
  
  for (lo in 1:dim(leftOutCols)[1]) {
    # Create training and testing set
    # Training set includes all but two counties
    dat_keep = dat %>% filter(sitename != leftOutCols[lo,1] & sitename != leftOutCols[lo,2])
    dat_keep$sitename = as.factor(dat_keep$sitename)
    
    dat_remove = dat %>% filter(sitename == leftOutCols[lo,1] | sitename == leftOutCols[lo,2])
    dat_remove$sitename = as.factor(dat_remove$sitename)
    
    # Fit the spline model
    gam_mod = gam(violenceScore ~ s(SNAP, by = sex, bs = "cr", k = k) + 
                                  s(UnemploymentRate, by = sex, bs = "cr", k = m) + 
                                  s(sitename, bs = "re"), data = dat_keep)

    pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")
    
    # Calculate the total mse
    msesSplit[lo] = sum((dat_remove$violenceScore - pred)^2) / length(pred)
    
    male_index = which(dat_remove$sex == 2)
    female_index = which(dat_remove$sex == 1)
    
    # Calculate the mse for male and for female
    msesSplit_male[lo] = sum((dat_remove[male_index, "violenceScore"] - pred[male_index])^2) / length(pred[male_index])
    msesSplit_female[lo] = sum((dat_remove[female_index, "violenceScore"] - pred[female_index])^2) / length(pred[female_index])

  }#for
  
  return(list(mse = mean(msesSplit), mse_male = mean(msesSplit_male), mse_female = mean(msesSplit_female)))
  
}#function

MSE_best = CrossValMSE(k = 17, m = 6, modelGroup = 2, nLeftOut = 2, dat = split_dat, mseSplitOn = 3)
MSE_best



