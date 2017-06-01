# DFL
Performs DiNardo-Fortin-Lemieux decomposition in R. Standard errors are bootstrapped.

This code implements the DiNardo-Fortin-Lemieux decompostion from DFL (1996) in R. DFL analysis takes a variable of interest for two groups (A and B), then asks what the distribution of the variable of interest for Group B would look like if members of Group B had the same observables as Group A.

## Arguments
**formula**   The variable that is used to decompose your variable of interest (e.g., male and female) and the observables. Group A is entered as 0 and Group B is entered as 1. It is entered as an R formula with the decomposition variable depended on the observatbles. For example, if we wanted to see how much women would make if they had the the same experience, years of education, and earned MBAs at the same rate as men, we could use the following formula:
gender~experience+yearsofeducation+MBA

**data**    The dataset.

**varofint**    The Variable of interest in the analysis.

**pctile**    (Optional) The percentiles you want reported from the distributions. It defaults to quarties (25th, 50th, and 75th percentiles). Needs to be entered as a value between 0 and 1.

**breps**   (Optional) The number of samples to use in a bootstrap. The default is 1000.

**kernel**    (Optional) The kernal to be used in creating the distributions. Defaults to Gaussian.

**Sensitivity**   (Optional) Used in finding the the percentiles. Defaults to .01. How close an estimate needs to be to the actual value before tesing individual "steps."

**Step**    (Optional) The code looking for percentiles will test values at every "step" to find the value of the variable of interest which most closely divides the distribtion of the variable of interest into the correct percentile.

**dif_tol**   (Optional) Passed to integrate.xy. Use a lower value if you get the following error:
 Error in seq.default(a, length = max(0, b - a - 1)) : 
  length must be non-negative number 
