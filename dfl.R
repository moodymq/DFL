library(plyr)
library(doBy)
library(iterators)
library(boot)
library(sfsmisc)

dfl <- function(data, varofint, groups, observables, pctile = c(.25, .5, .75), breps = 1000, kernel = "gaussian", Sensitivity = 0.01,
                Step = 0.001, dif_tol = 2e-10) {
  if(any(pctile < 0) | any(pctile > 1)) stop("Quartile must be between 0 and 1")
  num_pcts <- length(pctile)
  pctile <- sort(pctile)
  formula <- reformulate(observables, groups)

  find_break <- function(prob, x, y, theStart = min(x), theEnd = max(x), theSensitivity = Sensitivity, theStep = Step,
                         cumDist = 0){
    if(prob == 0) return(theStart)
    if(prob == 1) return(theEnd)
    midpt <- theStart + (theEnd - theStart)/2
    midptvalue <- integrate.xy(x,y,a = theStart, b = midpt, xtol=dif_tol) + cumDist
    mpv_pluss <- integrate.xy(x,y,a = theStart, b = midpt + theSensitivity, xtol=dif_tol) + cumDist
    mpv_minuss <- integrate.xy(x,y,a = theStart, b = midpt - theSensitivity, xtol=dif_tol) + cumDist
    theTest <- (sign(midptvalue - prob) == sign(mpv_pluss - prob) & sign(midptvalue - prob) == sign(mpv_minuss - prob))
    ifelse(prob == midptvalue, return(midpt),
           ifelse(!theTest, return(stepfind(prob, x, y, midpt - theSensitivity, midpt + theSensitivity, theStep, cumDist)),
                  ifelse(prob > midptvalue, find_break(prob, x, y, midpt, theEnd, theSensitivity, theStep, midptvalue),
                         find_break(prob, x, y, theStart, midpt, theSensitivity, theStep, cumDist)
                  )
           )
    )
  }
  
  stepfind <- function(prob, x, y, theStart, theEnd, theStep, cumDist){
    contenders <- seq(theStart, theEnd, by = theStep)
    contenders <- contenders[which(contenders[] >= theStart & contenders[] <= theEnd)]
    theDiff <- abs(prob - integrate.xy(x,y,b = contenders, xtol=dif_tol))
    return(contenders[which(theDiff[] == min(theDiff))])
  }
  
  dfl_boot <- function(formula, data, indices, varofint){
    d <- data[indices,]
    probit <- glm(formula, family = binomial(link = "probit"), 
                  data = d)
    d$phat <- predict.glm(probit, type="response")
    d$phat[d[which(colnames(d) == groups)]==0] <- NA
    
    d$weights <- (1-d$phat)/d$phat
    
    d$weights[d[which(colnames(d) == groups)]==0] <- NA
    
    d$weights <- d$weights/sum(d$weights,na.rm = TRUE)
    
    var1 = eval(parse(text=paste("d$",varofint,sep=""))) #get variable we want to decompose
    var2 <- eval(parse(text=paste("d$",all.vars(formula[[2]]),sep=""))) #get grouping variable
    theDensity <- density(var1[var2==0], bw = "SJ", kernel = kernel)
    theAnswer <- sapply(pctile, find_break, x=theDensity$x, y=theDensity$y)
    theDensity <- density(var1[var2==1], bw = "SJ", kernel = kernel,weights=d$weights[var2==1])
    theAnswer <- append(theAnswer, sapply(pctile, find_break, x=theDensity$x, y=theDensity$y))
    theDensity <- density(var1[var2==1], bw = "SJ", kernel = kernel)
    theAnswer <- append(theAnswer, sapply(pctile, find_break, x=theDensity$x, y=theDensity$y))
    return(theAnswer)
  }
  
  results <- boot(data=data, statistic=dfl_boot, 
                  R=breps, formula=formula, varofint = varofint)
  num_rows <- 3*num_pcts
  outputMatrix <- data.frame(results$t0[1:num_rows], c(rep(0, num_pcts), sapply(as.data.frame(results$t[,seq(num_pcts + 1, 2*num_pcts)]), sd),
                                                       rep(0, num_pcts)))
  colnames(outputMatrix) <- c("x","se")
  
  rowHeaders <- paste(all.vars(formula[[2]]), c(" = 0", " = 1, counterfactual", " = 1"), sep = "")
  rowHeaders <- as.vector(sapply(rowHeaders, paste, pctile, sep = "; Percentile = "))
  
  rownames(outputMatrix) <- rowHeaders
  
  outputMatrix
}
