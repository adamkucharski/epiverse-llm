# load finalsize
library(finalsize)

# load necessary packages
if (!require("socialmixr")) install.packages("socialmixr")
if (!require("ggplot2")) install.packages("ggplot2")

library(ggplot2)

# This example considers a infection with an R0 of 1.5, similar to that which could potentially be observed for pandemic influenza.

# define r0 as 1.5
r0 <- 1.5

# This example uses social contact data from the POLYMOD project (Mossong et al. 2008) to estimate the final size of an epidemic in the U.K. These data are provided with the socialmixr package.

# The contact data are divided into five age groups: 0 – 4, 5 – 17, 18 – 39, 40 – 64, and 65 and over, specified using the age.limits argument in socialmixr::contact_matrix(). The symmetric = TRUE argument to socialmixr::contact_matrix() returns a symmetric contact matrix, so that the contacts reported by group {𝑖} of individuals from group {𝑗} are the same as those reported by group {𝑗} of group {𝑖}.

The demographic data — the number of individuals in each age group — is also available through socialmixr::contact_matrix().

# get UK polymod data
polymod <- socialmixr::polymod
contact_data <- socialmixr::contact_matrix(
  polymod,
  countries = "United Kingdom",
  age.limits = c(0, 5, 18, 40, 65),
  symmetric = TRUE
)

# view the elements of the contact data list
# the contact matrix
contact_data$matrix

# the demography data
contact_data$demography

# get the contact matrix and demography data
contact_matrix <- t(contact_data$matrix)
demography_vector <- contact_data$demography$population
demography_data <- contact_data$demography

# scale the contact matrix so the largest eigenvalue is 1.0
# this is to ensure that the overall epidemic dynamics correctly reflect
# the assumed value of R0
contact_matrix <- contact_matrix / max(Re(eigen(contact_matrix)$values))

# divide each row of the contact matrix by the corresponding demography
# this reflects the assumption that each individual in group {j} make contacts
# at random with individuals in group {i}
contact_matrix <- contact_matrix / demography_vector

n_demo_grps <- length(demography_vector)

#As a starting scenario, consider a novel pathogen where all age groups have a similar, high susceptibility to infection. This means it is assumed that all individuals fall into a single category: fully susceptible.

#Full uniform susceptibility can be modelled as a matrix with values of 1.0, with as many rows as there are demographic groups. The matrix has a single column, representing the single susceptibility group to which all individuals belong.

# all individuals are equally and highly susceptible
n_susc_groups <- 1L
susc_guess <- 1.0

susc_uniform <- matrix(
  data = susc_guess,
  nrow = n_demo_grps,
  ncol = n_susc_groups
)

# Final size calculations also need to know the proportion of each demographic group {𝑖} that falls into the susceptibility group {𝑗}

# This distribution of age groups into susceptibility groups can be represented by the demography-susceptibility distribution matrix.

# Since all individuals in each age group have the same susceptibility, there is no variation within age groups. Consequently, all individuals in each age group are assumed to be fully susceptible. This can be represented as a single-column matrix, with as many rows as age groups, and as many columns as susceptibility groups.

# In this example, the matrix p_susc_uniform has 5 rows, one for each age group, and only one column, for the single high susceptibility group that holds all individuals.

p_susc_uniform <- matrix(
  data = 1.0,
  nrow = n_demo_grps,
  ncol = n_susc_groups
)

# This example models susceptibility (susc_uniform) and the demography-in-susceptibility (p_susc_uniform) as matrices rather than vectors. This is because a single susceptibility group is a special case of the general final size equation.

# finalsize supports multiple susceptibility groups (this will be covered later), and these are more easily represented as a matrix, the susceptibility matrix.

#Each element {𝑖,𝑗} in this matrix represents the susceptibility of individuals in demographic group {𝑖}, and susceptibility group {𝑗}

# In this example, all individuals are equally susceptible to infection, and thus the susceptibility matrix (susc_uniform) has only a single column with identical values.

# Consequently, the demography-susceptibility distribution matrix (p_susc_uniform) has the same dimensions, and all of its values are 1.0.

# The final size of the epidemic in the population can then be calculated using the only function in the package, final_size(). This example allows the function to fall back on the default options for the arguments solver ("iterative") and control (an empty list).

# calculate final size
final_size_data <- final_size(
  r0 = r0,
  contact_matrix = contact_matrix,
  demography_vector = demography_vector,
  susceptibility = susc_uniform,
  p_susceptibility = p_susc_uniform
)

# view the output data frame
final_size_data

# To visualise and order demographic groups as factors
final_size_data$demo_grp <- factor(
  final_size_data$demo_grp,
  levels = demography_data$age.group
)