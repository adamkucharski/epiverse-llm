# Load libraries

library(epiparameter)
library(distributional)

#{epiparameter} introduces three new classes for working with epidemiological parameters in R:
# `<epiparam>`: library of epidemiolgical parameters
# `<epidist>`: singular set of epidemiolgical parameters 
# `<vb_epidist>`: a singular set of epidemiolgical parameters for a vector-borne disease containing both an extrinsic and intrinsic distribution. This object contains two sets of parameters, one for the human (intrinsic) and one for the vector (extrinsic).

#First, we will introduce the library, or database, of epidemiological parameters available from {epiparameter}. 

#The `<epiparam>` class is introduced to enable users to easily explore the range of parameters that are available. 

#The library can be read into R using the `epiparam()` function. By default all entries in the library are supplied.

epi_dist_db <- epiparam()
epi_dist_db

#The `<epiparam>` class has a custom printing method which gives a summary of the information included in the database including the number of distributions, number of diseases, number of different studies among other summary metrics, as well as the first six rows of the diseases, epidemiological distributions (`epi_distribution`) and probability distribution (`prob_distribution`).

#The `<epiparam>` class is based (i.e. inherits from) the data frame, and therefore the same subsetting and manipulation can be carried out, including the `head()` and `tail()` of the database.

head(epi_dist_db)[, 1:5]
tail(epi_dist_db)[, 1:5]

#If subsetting of the `<epiparam>` object removes one of the crucial columns then the object is converted to a data frame. Here removing the `disease` column causes the `<epiparam>` object to be converted to a data frame. 

epi_dist_df <- epi_dist_db[-which(colnames(epi_dist_db) == "disease")]

#To see a full list of the diseases and distributions stored in the library use the  `list_distributions()` function. 

#The second class introduced in the {epiparameter} package is the `<epidist>` class. This holds a single set of epidemiological parameters. 

#An `<epidist>` object can be converted from one of the rows of the `<epiparam>` object or can be created manually. First we will show the conversion of `<epiparam>` &rarr; `<epidist>`. This uses the `as_epidist()` function.

# find entry for COVID-19
epi_dist_covid <- epi_dist_db[which(epi_dist_db$disease == "COVID-19"), ]

# find entry for COVID-19 incubation period
epi_dist_covid_incub <- epi_dist_covid[which(epi_dist_covid$epi_distribution == "incubation_period"), ] # nolint

# select one of the COVID-19 incubation period
covid_incub <- epi_dist_covid_incub[10, ]

# convert epiparam entry to epidist
covid_incub <- as_epidist(covid_incub)
covid_incub

#The `<epidist>` object also has a custom printing method which shows the disease, pathogen (if known), the epidemiological distribution, a short citation of the study the parameters are from and the probability distribution and parameter of that distribution (if available).

#The opposite conversion from `<epidist>` to `<epiparam>` can also be achieved using `as_epiparam()`.

as_epiparam(covid_incub)

#There are two alternatives to reading in `<epiparam>` objects and subsetting to `<epidist>`. 
#1. Extract an `<epidist>` directly from the library with `epidist_db()`.
#2. Create `<epidist>` manually with constructor function.

#The `epidist_db()` allows direct subsetting of the library and returns an `<epidist>` of a single set of epidemiological parameters.

epidist_db(
  disease = "COVID-19",
  epi_dist = "incubation_period",
  author = "Bui_etal"
)

#Additionally to using entries from the {epiparameter} library, `<epidist>` objects can be manually created. This may be especially useful if new parameter estimates become available but are not yet incorporated into the library.

ebola_incubation <- epidist(
  disease = "ebola",
  epi_dist = "incubation_period",
  prob_distribution = "lnorm",
  prob_distribution_params = c(meanlog = 1, sdlog = 1)
)

### Benefit of `<epidist>`

#By providing a consistent and robust object to store epidemiological parameters, `<epidist>` objects can be applied in epidemiological pipelines, for example [{episoap}](https://github.com/epiverse-trace/episoap). The data contained within the object (e.g. parameter values, pathogen type, etc.) can be modified but the pipeline will operate as the class is unchanged.

#The probability distribution (`prob_distribution`) argument requires the distribution specified in the standard R naming. In some cases these are the same as the distribution's name, e.g., `gamma` and `weibull`. Examples of where the distribution name and R name differ are lognormal and `lnorm`, negative binomial and `nbinom`, geometric and `geom`, and poisson and `pois`. Extra arguments are also available in `epidist()` to add information on uncertainty and citation information.

## Distribution functions

#`<epidist>` objects store distributions, and mathematical functions of these distribution can easily be extracted directly from them. It is commonly required to extract the probability density function, cumulative distribution function, quantile or generate random numbers from the distribution in the `<epidist>` object. The distribution functions in {epiparameter} allow users to easily access these aspects.

density(ebola_incubation, at = 0.5)
cdf(ebola_incubation, q = 0.5)
quantile(ebola_incubation, p = 0.5)
generate(ebola_incubation, times = 10)


## Plotting epidemiological distributions

#`<epidist>` objects can easily be plotted to see the PDF and CDF of distribution.

plot(ebola_incubation)

#There are two styles of conversion functions in {epiparameter}. The general conversions which have the function name `convert_dist_*()` (where `*` and `dist` are placeholders). These convert either one set of parameters to many summary statistics (e.g. `convert_lnorm_params()`) or a set of summary statistics input to one set of parameters (e.g. `convert_lnorm_summary_stats()`). The other style of function is the one-to-one conversion, which has the function name `dist_param2summary_stat()` or `dist_summarystat2param()` (where `dist`, `param` and `summary_stat` are placeholders). These functions take two arguments as input and convert to two output (e.g. `gamma_shapescale2meansd()`), with the exception of the geometric conversions which have a single input and a single output.

### General conversion functions

#The general conversion functions from summary statistics to parameters (e.g. `convert_gamma_summary_stats()`) have no defined function arguments. Instead the summary statistics should be matched exactly by name.

# There are two methods of extraction implemented in {epiparameter}. One is to estimate the parameters given the values of two percentiles, and the other is to estimate the parameters given the median and the range of the data. Both of these extractions are implemented in the `extract_param()` function.

#Here we demonstrate extraction using percentiles. The `type` should be `"percentiles"`, the `values` are the values reported at the percentiles, given as a vector. The percentiles, given between 0 and 1, are specified as a vector in `percentiles`. The example below uses values 1 and 10 at the 2.5th and 97.5th percentile, respectively.

extract_param(
  type = "percentiles",
  values = c(1, 10),
  distribution = "gamma",
  percentiles = c(0.025, 0.975)
)

#The alternative extraction, by median and range, can be achieved by specifying `type = "range"` and using the `samples` argument instead of the `percentiles` argument. When using `type = "percentiles"` the `samples` argument is ignored and when using `type = "range"` the `percentiles` argument is ignored.

extract_param(
  type = "range",
  values = c(10, 5, 15),
  distribution = "lnorm",
  samples = 25
)
