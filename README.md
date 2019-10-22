
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riskybiz

<!-- badges: start -->

<!-- badges: end -->

The goal of {riskybiz} is to provide both a formula framework for
creating competing risks regression objects and also output useful
components such as `model.frame` that the original {cmprsk} package does
not provide.

# Installation

The {riskybiz} package was written as a wrapper/enhancer to the {cmprsk}
package.

To install the development version of {riskybiz}

``` r
install.packages("remotes")
remotes::install_github("margarethannum/riskybiz")
```

# Example

``` r

library(gtsummary)
library(cmprsk)

set.seed(123)
trial2 <- trial %>%
mutate(grey = sample(0:2, 200, replace = TRUE, prob = c(0.4, 0.5, 0.1))) %>%
   drop_na()

#original crr
covars <- model.matrix(~ age + factor(trt) + factor(grade), trial2)[,-1]
ftime1 <- trial2$ttdeath
fstatus1 <- trial2$grey
mod_orig <- crr(ftime=ftime1,
                fstatus = fstatus,
                cov1 = covars)

# using new wrapper function, accepts data and formula
mod_new <- crr.formula(Surv(ttdeath, grey) ~ age + trt + grade, trial2)

tidy.crr(mod_new)
```

<!-- ## Installation -->

<!-- You can install the development version from [GitHub](https://github.com/) with: -->

<!-- ``` r -->

<!-- # install.packages("devtools") -->

<!-- devtools::install_github("margarethannum/riskybusiness") -->

<!-- ``` -->
