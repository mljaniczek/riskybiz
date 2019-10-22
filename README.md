
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riskybiz

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/margarethannum/riskybiz.svg?branch=master)](https://travis-ci.org/margarethannum/riskybiz)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/margarethannum/riskybiz?branch=master&svg=true)](https://ci.appveyor.com/project/margarethannum/riskybiz)
[![Codecov test
coverage](https://codecov.io/gh/margarethannum/riskybiz/branch/master/graph/badge.svg)](https://codecov.io/gh/margarethannum/riskybiz?branch=master)
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
   tidyr::drop_na()

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

## Contributing

Please note that the {riskybiz} project is released with a [Contributor
Code of
Conduct](http://www.danieldsjoberg.com/gtsummary/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms. A big
thank you to all contributors\!  
[@ddsjoberg](https://github.com/ddsjoberg), and
[@margarethannum](https://github.com/margarethannum)
