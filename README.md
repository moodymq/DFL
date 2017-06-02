# DFL
Performs DiNardo-Fortin-Lemieux decomposition in R. Standard errors are bootstrapped.

This code implements the DiNardo-Fortin-Lemieux decompostion from DFL (1996) in R. DFL analysis calculates the distribution of a variable of interest for two groups (A and B), then asks what the distribution of the variable of interest for Group B would look like if members of Group B had the same observables as Group A.

This code returns the relevant percentiles for the factual distributions of Groups A and B, as well as the counterfactual distribution of Group B. In addition, it uses bootstrap methods to calcualte standard errors for the coefficients on the counterfactual distribution.

## Arguments
gender~experience+yearsofeducation+MBA

**data**    The dataset.

**varofint**    The Variable of interest in the analysis.

**groups**    The variable used to decompose the variable of interest. Group A is enetered as 0, group B is entered as 1. Must be entered as a string.

**observables**    The observables in the system. For example, if we wanted to see how much women would earn if they had the same experience and year of education as men and completed MBAs at the same rate, our observables would be the variables experience, yearsofed, and MBA. They need to be entered as a vector of strings (i.e., c("experience", "yearsofed", "MBA")).

**pctile**    (Optional) The percentiles you want reported from the distributions. It defaults to quartiles (25th, 50th, and 75th percentiles). Needs to be entered as a value between 0 and 1.

**breps**   (Optional) The number of samples to use in a bootstrap. The default is 1000.

**kernel**    (Optional) The kernal to be used in creating the distributions. Defaults to Gaussian.

**Sensitivity**   (Optional) Used in finding the the percentiles. Defaults to .01. How close an estimate needs to be to the actual value before tesing individual "steps."

**Step**    (Optional) The code looking for percentiles will test values at every "step" to find the value of the variable of interest which most closely divides the distribtion of the variable of interest into the correct percentile.

**dif_tol**   (Optional) Passed to integrate.xy. Use a lower value if you get the following error:
 Error in seq.default(a, length = max(0, b - a - 1)) : 
  length must be non-negative number 

## Sample call:
dfl(MyData, annualsalary, "gender", c("experience", yearsofed", "MBA"), pctile = (.1, .25, .5, .75, .9), breps = 100)
