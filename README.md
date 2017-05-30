# DFL
Performs DiNardo-Fortin-Lemieux decomposition in R. Standard errors are bootstrapped.

This code implements the DiNardo-Fortin-Lemieux decompostion from DFL (1996). DFL analysis takes a variable of interest for
two groups (A and B), then asks what the distribution of the variable of interest for Group B would look like if members of
Group B had the same observables as Group A.

The dfl function includes indicies so it can be called through from a bootstrap for standard deviations. "formula"
contains the grouping variable and the observables in the form of "grouping ~ observables." For example, if we wanted
see how much women would make if they had the the same experience, years of education, and earned MBAs at the same rate as men,
we could use the following code:

results <- boot(data=teachers_mm, statistic=dfl, 
                R=10, formula=gendercode~experience+yearsofeducation+MBA, varofint = "annualsalary")
outputMatrix <- data.frame(results$t0[1:9], c(0,0,0,sd(results$t[,4]),
                                              sd(results$t[,5]),sd(results$t[,6]),0,0,0))
colnames(outputMatrix) <- c("quartile","se")

OutputMatrix has the quartile cutoffs for men in the first 3 rows and for women in the last 3 rows. The middle 3 rows contain
the counterfactual women's distribution. These three have standard errors calculated from the bootstrap.
