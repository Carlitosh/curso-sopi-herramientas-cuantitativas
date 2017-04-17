##########################################################################
### Script from: https://github.com/openforis/accuracy-assessment ########
##########################################################################

##########################################################################
### Input Dat ############################################################
##########################################################################

# get the maps frequencies
maparea <- freq(mlc.3x3, useNA="no")
maparea <- maparea[,2]             
pixelsize <- 0.09 # in Ha

# confusion matrix
ma <- as.data.frame.matrix(val.2016$performance$table)

# Valid categories
dyn <- c(1,2,5,7,8)

##########################################################################
### Estimate accuracies ##################################################
##########################################################################

# calculate the area proportions for each map class
aoi <- sum(maparea)
propmaparea <- maparea/aoi

# convert the absolute cross tab into a probability cross tab
ni. <- rowSums(ma) # number of reference points per map class
propma <-  as.matrix(ma/ni. * propmaparea)
propma[is.nan(propma)] <- 0 # for classes with ni. = 0

# estimate the accuracies now
OA <- sum(diag(propma)) # overall accuracy (Eq. 1 in Olofsson et al. 2014)
UA <- diag(propma) / rowSums(propma) # user's accuracy (Eq. 2 in Olofsson et al. 2014)
PA <- diag(propma) / colSums(propma) # producer's accuracy (Eq. 3 in Olofsson et al. 2014)

# estimate confidence intervals for the accuracies
V_OA <- sum(propmaparea^2 * UA * (1 - UA) / (ni. - 1), na.rm=T)  # variance of overall accuracy (Eq. 5 in Olofsson et al. 2014)
V_UA <- UA * (1 - UA) / (rowSums(ma) - 1) # variance of user's accuracy (Eq. 6 in Olofsson et al. 2014)

# variance of producer's accuracy (Eq. 7 in Olofsson et al. 2014)
N.j <- array(0, dim=length(dyn))
aftersumsign <- array(0, dim=length(dyn))
for(cj in 1:length(dyn)) {
  N.j[cj] <- sum(maparea / ni. * ma[, cj], na.rm=T)
  aftersumsign[cj] <- sum(maparea[-cj]^2 * ma[-cj, cj] / ni.[-cj] * ( 1 - ma[-cj, cj] / ni.[-cj]) / (ni.[-cj] - 1), na.rm = T)
}
V_PA <- 1/N.j^2 * ( 
  maparea^2 * (1-PA)^2 * UA * (1-UA) / (ni.-1) + 
    PA^2 * aftersumsign
) 
V_PA[is.nan(V_PA)] <- 0

##########################################################################
### Estimate area ########################################################
##########################################################################

# proportional area estimation
propAreaEst <- colSums(propma) # proportion of area (Eq. 8 in Olofsson et al. 2014)
AreaEst <- propAreaEst * sum(maparea) # estimated area

# standard errors of the area estimation (Eq. 10 in Olofsson et al. 2014)
V_propAreaEst <- array(0, dim=length(dyn))
for (cj in 1:length(dyn)) {
  V_propAreaEst[cj] <- sum((propmaparea * propma[, cj] - propma[, cj] ^ 2) / ( rowSums(ma) - 1))
}
V_propAreaEst[is.na(V_propAreaEst)] <- 0

# produce the overview table
ov <- as.data.frame(round(propma, 3))
ov$total <- rowSums(ma)
ov$maparea <- maparea * pixelsize # in ha
ov$prop_maparea <- round(propmaparea, 3)

ov$adj_proparea <- round(propAreaEst, 3)
ov$CI_adj_proparea <- round(1.96 * sqrt(V_propAreaEst), 3)
ov$adj_area <- round(ov$adj_proparea * aoi * pixelsize, 3) # in ha
ov$CI_adj_area <- round(1.96 * sqrt(V_propAreaEst) * aoi * pixelsize, 3) # in ha
ov$UA <- round(UA, 3)
ov$CI_UA <- round(1.96 * sqrt(V_UA), 3)
ov$PA <- round(PA, 3)
ov$CI_PA <- round(1.96 * sqrt(V_PA), 3)
rownames(ov) <- colnames(ma)
ov$OA <- c(round(OA, 3), rep(NA, times = length(dyn) - 1))
ov$CI_OA <- c(round(1.96 * sqrt(V_OA), 3), rep(NA, times = length(dyn) - 1))

print(ov)

write.csv(ov, "report.csv", row.names=T, quote=F) # write the output file
