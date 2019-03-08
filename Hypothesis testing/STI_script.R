#############################################################################
## Title: STI and synchrony analysis
## User: Lisbeth Morrison 
## email: l.morrison@pgr.reading.ac.uk
## Date: Feb 2019
#############################################################################

rm(list=ls()) # clear R
library(lme4)
library(lmerTest)
library(ggsignif)
library(ggplot2)
library(plyr)
library(dplyr)
library(plotrix)
library(parallel)
options(scipen=999)

## read in synchrony data
pair_attr <- read.csv("../Data/Butterfly_sync_data/pair_attr.csv", header=TRUE) 
pair_attr_CBC <- read.csv("../Data/Bird_sync_data/pair_attr_CBC.csv", header=TRUE) 
pair_attr_BBS <- read.csv("../Data/Bird_sync_data/pair_attr_BBS.csv", header=TRUE) 
bird_STI <- read.csv("../Data/birds_STI.csv", header=TRUE)
butterfly_STI <- read.csv("../Data/butterflies_STI.csv", header=TRUE)

############### AVERAGE SYNCHORNY #################

#### UKBMS
## merge datasets
pair_attr <- merge(pair_attr, butterfly_STI, by.x="spp", by.y="species_code") 
length(unique(pair_attr$spp)) # 28 species
## No STI data for Essex skipper
summary(pair_attr)

pair_attr$mid.year <- as.factor(pair_attr$mid.year)
pair_attr$pair.id <- as.character(pair_attr$pair.id)
pair_attr$spp <- as.factor(pair_attr$spp)

start_time <- Sys.time()
climate_ukbms <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year + STI + (1|spp) + (1|pair.id), data=pair_attr)
end_time <- Sys.time()
end_time - start_time ## 4.5mins
summary(climate_ukbms) ## STI non-significant (p=0.152)

## test with mobility in the model too
## remove NA's (small white has no mobility data)
pair_attr <- na.omit(pair_attr)
## split mobility into two groups
pair_attr$mobility_wil <- as.numeric(pair_attr$mobility_wil)
pair_attr$mobility_score2 <- cut(pair_attr$mobility_wil, 2, labels=c("low", "high"))
pair_attr$mobility_score2 <- as.factor(pair_attr$mobility_score2)

climate_mob_ukbms <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year + STI + mobility_score2 + (1|spp) + (1|pair.id), data=pair_attr)
summary(climate_mob_ukbms) ## STI non-significant (p=0.09)

## interaction
climate_mob_ukbms2 <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year + STI*mobility_score2 + (1|spp) + (1|pair.id), data=pair_attr)
summary(climate_mob_ukbms2) 
anova(climate_mob_ukbms2) ## interaction non-significant (p=0.681)

##### CBC
## merge datasets
pair_attr_CBC <- merge(pair_attr_CBC, bird_STI, by.x="spp", by.y="species_code") ## 31 species
str(pair_attr_CBC)

pair_attr_CBC$mid.year <- as.factor(pair_attr_CBC$mid.year)
pair_attr_CBC$pair.id <- as.character(pair_attr_CBC$pair.id)
pair_attr_CBC$spp <- as.factor(pair_attr_CBC$spp)

start_time <- Sys.time()
climate_cbc <- lmer(lag0 ~ mean_northing + distance + hab_sim + mid.year + STI + (1|spp) + (1|pair.id), data=pair_attr_CBC)
end_time <- Sys.time()
end_time - start_time ## 24.36 seconds
summary(climate_cbc) ## STI non-significant (p=0.191)

##### BBS
## merge datasets
pair_attr_BBS <- merge(pair_attr_BBS, bird_STI, by.x="spp", by.y="species_code") ## 24 species
str(pair_attr_BBS)

pair_attr_BBS$mid.year <- as.integer(pair_attr_BBS$mid.year)
pair_attr_BBS$pair.id <- as.character(pair_attr_BBS$pair.id)
pair_attr_BBS$spp <- as.factor(pair_attr_BBS$spp)

start_time <- Sys.time()
climate_bbs <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year + STI + (1|spp) + (1|pair.id), data=pair_attr_BBS)
end_time <- Sys.time()
end_time - start_time ## 24.36 seconds
summary(climate_bbs) ## STI non-significant (p=0.882)
############### CHANGE IN SYNCHORNY #################

#### UKBMS
## subset to only look at mid years 1985, 2000 and 2012
pair_attr_1985 <- pair_attr[pair_attr$mid.year==1984.5,]
pair_attr_2000 <- pair_attr[pair_attr$mid.year==1999.5,]
pair_attr_2012 <- pair_attr[pair_attr$mid.year==2011.5,]
pair_attr_ukbms <- rbind(pair_attr_1985, pair_attr_2000, pair_attr_2012) ## 3 years and 32 species

pair_attr_ukbms$mid.year <- as.factor(pair_attr_ukbms$mid.year)
pair_attr_ukbms$pair.id <- as.character(pair_attr_ukbms$pair.id)
pair_attr_ukbms$spp <- as.factor(pair_attr_ukbms$spp)

start_time <- Sys.time()
climate_ukbms_change <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year*STI + (1|spp) + (1|pair.id), data=pair_attr_ukbms)
end_time <- Sys.time()
end_time - start_time ## 14.18secs
summary(climate_ukbms_change)
anova(climate_ukbms_change) ## interaction is non-significant (p=0.52)

## add mobility
climate_ukbms_change_mob <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year*STI + mobility_score2 + (1|spp) + (1|pair.id), data=pair_attr_ukbms)
anova(climate_ukbms_change_mob) ## interaction is non-significant (p=0.43)

#### CBC
pair_attr_cbc_1985 <- pair_attr_CBC[pair_attr_CBC$mid.year==1984.5,]
pair_attr_cbc_1996 <- pair_attr_CBC[pair_attr_CBC$mid.year==1995.5,]
pair_attr_cbc <- rbind(pair_attr_cbc_1985, pair_attr_cbc_1996)

pair_attr_cbc$mid.year <- as.factor(pair_attr_cbc$mid.year)
pair_attr_cbc$pair.id <- as.character(pair_attr_cbc$pair.id)
pair_attr_cbc$spp <- as.factor(pair_attr_cbc$spp)

###### run model with STI and year interaction
start_time <- Sys.time()
climate_cbc_change <- lmer(lag0 ~ mean_northing + distance + hab_sim + mid.year*STI + (1|pair.id) + (1|spp), data = pair_attr_cbc)
end_time <- Sys.time()
end_time - start_time ## 5.886secs
summary(climate_cbc_change)
anova(climate_cbc_change) ## interaction is non-significant (p=0.1519)

#### BBS
pair_attr_bbs_1999 <- pair_attr_BBS[pair_attr_BBS$mid.year==1998.5,]
pair_attr_bbs_2012 <- pair_attr_BBS[pair_attr_BBS$mid.year==2011.5,]
pair_attr_bbs <- rbind(pair_attr_bbs_1999, pair_attr_bbs_2012)

pair_attr_bbs$mid.year <- as.factor(pair_attr_bbs$mid.year)
pair_attr_bbs$pair.id <- as.character(pair_attr_bbs$pair.id)
pair_attr_bbs$spp <- as.factor(pair_attr_bbs$spp)

###### run model with STI and year interaction
start_time <- Sys.time()
climate_bbs_change <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year*STI + (1|pair.id) + (1|spp), data = pair_attr_bbs)
end_time <- Sys.time()
end_time - start_time ## 36.953
summary(climate_bbs_change)
anova(climate_bbs_change) ## interaction is significant (p=0.0332)

## split STI into three groups (low, med, high) to plot interaction result
pair_attr_bbs$STI <- as.numeric(pair_attr_bbs$STI)
pair_attr_bbs$STI_score <- cut(pair_attr_bbs$STI, 3, labels=FALSE)
pair_attr_bbs$STI_score <- as.factor(pair_attr_bbs$STI_score)

## run model
climate_bbs_change2 <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year*STI_score + (1|pair.id) + (1|spp), data = pair_attr_bbs)
summary(climate_bbs_change2)
anova(climate_bbs_change2) ## not significant 

### predict new data
newdata_bbs <- expand.grid(mean_northing=mean(pair_attr_bbs$mean_northing), distance=mean(pair_attr_bbs$distance), 
                           renk_hab_sim=mean(pair_attr_bbs$renk_hab_sim), mid.year=unique(pair_attr_bbs$mid.year), 
                           pair.id=sample(pair_attr_bbs$pair.id,10), spp=sample(pair_attr_bbs$spp,10),
                           STI_score=unique(pair_attr_bbs$STI_score))
newdata_bbs$lag0 <- predict(climate_bbs_change2, newdata=newdata_bbs, re.form=NA)

mm2 <- model.matrix(terms(climate_bbs_change2), newdata_bbs)
pvar2 <- diag(mm2 %*% tcrossprod(vcov(climate_bbs_change2),mm2))
tvar2 <- pvar2+VarCorr(climate_bbs_change2)$spp[1]+VarCorr(climate_bbs_change2)$pair.id[1]
cmult <- 2

newdata_bbs <- data.frame(
  newdata_bbs
  , plo = newdata_bbs$lag0-1.96*sqrt(pvar2)
  , phi = newdata_bbs$lag0+1.96*sqrt(pvar2)
  , tlo = newdata_bbs$lag0-1.96*sqrt(tvar2)
  , thi = newdata_bbs$lag0+1.96*sqrt(tvar2)
)

## run model without STI and species random effect to obtain residuals
STI_bbs <- lmer(lag0 ~ mean_northing + distance + renk_hab_sim + mid.year + (1|pair.id), data=pair_attr_bbs)
pair_attr_bbs$residuals <- resid(STI_bbs)

## create new dataframe to calculate mean, SD and SE of residuals for each species
summary_bbs <- pair_attr_bbs %>% group_by(spp, STI_score, mid.year) %>% 
  summarise_at(vars(residuals), funs(mean,std.error))

## change values
newdata_bbs$mid.year <- revalue(newdata_bbs$mid.year, c("1998.5"="1999"))
newdata_bbs$mid.year <- revalue(newdata_bbs$mid.year, c("2011.5"="2012"))
colnames(newdata_bbs)[7] <- "STI"
newdata_bbs$STI <- as.factor(newdata_bbs$STI)
newdata_bbs$STI <- revalue(newdata_bbs$STI, c("1"="Low"))
newdata_bbs$STI <- revalue(newdata_bbs$STI, c("2"="Medium"))
newdata_bbs$STI <- revalue(newdata_bbs$STI, c("3"="High"))
## same for summary dataframe
summary_bbs$mid.year <- revalue(summary_bbs$mid.year, c("1998.5"="1999"))
summary_bbs$mid.year <- revalue(summary_bbs$mid.year, c("2011.5"="2012"))
colnames(summary_bbs)[2] <- "STI"
summary_bbs$STI <- as.factor(summary_bbs$STI)
summary_bbs$STI <- revalue(summary_bbs$STI, c("1"="Low"))
summary_bbs$STI <- revalue(summary_bbs$STI, c("2"="Medium"))
summary_bbs$STI <- revalue(summary_bbs$STI, c("3"="High"))

pd <- position_dodge(0.1)
ggplot(summary_bbs, aes(x = mid.year, y = mean, group=STI)) +
  geom_point(aes(shape=STI), colour="grey66", size = 3, position=myjit) +
  geom_errorbar(aes(ymin = mean-std.error, ymax = mean+std.error), colour="grey66", width=0.2, position=myjit) +
  geom_line(data=newdata_bbs, aes(x=mid.year, y=lag0, colour=STI), lwd=1) +
  labs(x="Mid year of moving window", y="Population synchrony") +
  scale_y_continuous(breaks=seq(-2,0.3,0.1)) +
  theme_bw() +
  theme(legend.key.width = unit(0.8,"cm"), legend.key = element_rect(size = 2), text = element_text(size = 12), panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"), legend.margin=margin(c(-10,20,-140,0)),
        axis.text.x=element_text(colour="black"), axis.text.y = element_text(colour="black")) +
  scale_linetype_manual(name=" ",
                        labels=c("High", "Medium", "Low"), values=c(2,3,4)) +
  scale_shape_manual(name="STI", 
                     labels=c("High", "Medium", "Low"), values=c(15,16,17)) +
  guides(shape = guide_legend(override.aes = list(size = 3))) +
  guides(linetype = guide_legend(override.aes = list(size = 0.5)))
dev.off()


myjit <- ggproto("fixJitter", PositionDodge,
                 width = 0.2,
                 dodge.width = 0.35,
                 jit = NULL,
                 compute_panel =  function (self, data, params, scales) 
                 {
                   
                   #Generate Jitter if not yet
                   if(is.null(self$jit) ) {
                     self$jit <-jitter(rep(0, nrow(data)), amount=self$dodge.width)
                   }
                   
                   data <- ggproto_parent(PositionDodge, self)$compute_panel(data, params, scales)
                   
                   data$x <- data$x + self$jit
                   #For proper error extensions
                   if("xmin" %in% colnames(data)) data$xmin <- data$xmin + self$jit
                   if("xmax" %in% colnames(data)) data$xmax <- data$xmax + self$jit
                   data
                 } )