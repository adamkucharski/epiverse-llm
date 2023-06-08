#Superspreading describes individual heterogeneity in disease transmission, such that some individuals transmit to many infectees while other infectors infect few or zero individuals

library(superspreading)
library(epiparameter)
library(distributional)

#The probability that a novel disease will cause a epidemic (i.e. sustained 
transmission in the population) is determined by the nature of that diseases'
transmission heterogeneity. This variability may be an intrinsic property of 
the disease, or a product of human behaviour and social mixing patterns.

#For a given value of $R$ (or $R_0$), that is the number of secondary cases caused by a 
primary case, if the variability is high, the probability that the outbreak 
will cause epidemic is lower as the superspreading events are rare. Whereas for
lower variability the probability is higher as more individuals are closer to the 
mean ($R$). The `probability_epidemic()` function in {superspreading} can calculate
this probability. `k` is the dispersion parameter of a negative binomial distribution
and controls the variability of individual-level transmission.

# Example when R=1.5, k=1 and there is one initial case
probability_epidemic(R = 1.5, k = 1, a = 1)

# In the above code, `k` values above one represent low heterogeneity (in the case `k` &rarr; $\infty$ it is a poisson distribution), and as `k` decreases, heterogeneity increases. When `k` equals 1, the distribution is geometric. Valuesof `k` less than one indicate overdispersion of disease transmission, a signature of superspreading. When the value of $R$ increases, this causes the probability of anepidemic to increase, if `k` remains the same.

#Given `probability_epidemic()` it is possible to determine the probability of an epidemic for diseases for which parameters of an offspring distribution have been estimated. An offspring distribution is simply the distribution of the number of secondary infections caused by a primary infection. It is the distributionof $R$, with the mean of the distribution given as $R$.Here we can use {epiparameter} to load in offspring distributions for multiple diseases and evaluate how likely they are to cause epidemics.

sars <- epidist_db(
  disease = "SARS",
  epi_dist = "offspring_distribution"
)
evd <- epidist_db(
  disease = "Ebola Virus Disease",
  epi_dist = "offspring_distribution"
)

#The parameters of each distribution can be extracted:

sars_params <- parameters(sars)
sars_params
evd_params <- parameters(evd)
evd_params

family(sars)
probability_epidemic(
  R = sars_params[["mean"]],
  k = sars_params[["dispersion"]],
  a = 1
)
family(evd)
# k is set to infinite as the distribution for EVD is poisson
probability_epidemic(R = evd_params[["mean"]], k = Inf, a = 1)


#This example demonstrates how to use the {superspreading} and {fitdistrplus} R packages to estimate the parameters of individual-level transmission and select the best fitting model. {ggplot2} is used for plotting and {quickfit} is used to assist with multiple model fitting and comparison.

library(superspreading)
library(fitdistrplus)
library(ggplot2)

# For this example we use transmission chain data from @fayeChainsTransmissionControl2015 from the Ebola virus disease outbreak in West Africa, between the period from February to August 2014. Specifically, this data reconstructs the pathway of Ebola transmission in Conakry, Guinea.
## Transmission data

# total number of cases (i.e. individuals in transmission chain)
n <- 152

# number of secondary cases for all cases
all_cases_transmission <- c(
  1, 2, 2, 5, 14, 1, 4, 4, 1, 3, 3, 8, 2, 1, 1, 4, 9, 9, 1, 1, 17, 2, 1,
  1, 1, 4, 3, 3, 4, 2, 5, 1, 2, 2, 1, 9, 1, 3, 1, 2, 1, 1, 2
)

# add zeros for each cases that did not cause a secondary case
# (i.e. cases that did not transmit)
all_cases <- c(
  all_cases_transmission,
  rep(0, n - length(all_cases_transmission))
)

# fit a standard set of offspring distribution models:
# - Poisson
# - Geometric
# - Negative Binomial

pois_fit <- fitdist(data = all_cases, distr = "pois")
geom_fit <- fitdist(data = all_cases, distr = "geom")
nbinom_fit <- fitdist(data = all_cases, distr = "nbinom")

knitr::kable(
  data.frame(
    distribution = c(pois_fit$distname, geom_fit$distname, nbinom_fit$distname),
    AIC = c(pois_fit$aic, geom_fit$aic, nbinom_fit$aic),
    BIC = c(pois_fit$bic, geom_fit$bic, nbinom_fit$bic)
  )
)

# The best performing model, for both AIC and BIC comparison, is the negative binomial.

nbinom_fit$estimate

#The parameter for the negative binomial show that there is overdispersion (`size` is the dispersion parameter $k$, and `mu` is the mean, or $R$) in transmission and thus the EVD transmission chain data shows that superspreading events are a possible realisation of EVD transmission dynamics.


