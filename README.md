
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riskybiz

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/margarethannum/riskybiz.svg?branch=master)](https://travis-ci.org/margarethannum/riskybiz)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/margarethannum/riskybiz?branch=master&svg=true)](https://ci.appveyor.com/project/margarethannum/riskybiz)
[![Codecov test
coverage](https://codecov.io/gh/margarethannum/riskybiz/branch/master/graph/badge.svg)](https://codecov.io/gh/margarethannum/riskybiz?branch=master)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
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

The standard `cmprsk::crr()` function has specific input requirements.

``` r

library(gtsummary)
library(dplyr)
library(cmprsk)
#> Loading required package: survival
library(riskybiz)

set.seed(123)
trial2 <- trial %>%
mutate(grey = sample(0:2, 200, replace = TRUE, prob = c(0.4, 0.5, 0.1))) %>%
   tidyr::drop_na()

#original crr
covars <- model.matrix(~ age + factor(trt) + factor(grade), trial2)[,-1]
ftime1 <- trial2$ttdeath
fstatus1 <- trial2$grey
mod_orig <- crr(ftime=ftime1,
                fstatus = fstatus1,
                cov1 = covars)
```

Output of model does not contain elements like `model.frame` since the
function does not take a `data.frame` as input.

``` r
summary(mod_orig)
#> Competing Risks Regression
#> 
#> Call:
#> crr(ftime = ftime1, fstatus = fstatus1, cov1 = covars)
#> 
#>                        coef exp(coef) se(coef)       z p-value
#> age                 0.01494     1.015  0.00772  1.9347   0.053
#> factor(trt)Placebo -0.00401     0.996  0.19694 -0.0204   0.980
#> factor(grade)II     0.07304     1.076  0.22339  0.3270   0.740
#> factor(grade)III    0.08105     1.084  0.22864  0.3545   0.720
#> 
#>                    exp(coef) exp(-coef)  2.5% 97.5%
#> age                    1.015      0.985 1.000  1.03
#> factor(trt)Placebo     0.996      1.004 0.677  1.47
#> factor(grade)II        1.076      0.930 0.694  1.67
#> factor(grade)III       1.084      0.922 0.693  1.70
#> 
#> Num. cases = 173
#> Pseudo Log-likelihood = -397 
#> Pseudo likelihood ratio test = 3.69  on 4 df,
```

Using our wrapper function `riskybiz::crr.formula()` allows for
inputting an intuitive formula and data, which allows for downstream
functions.

``` r

# using new wrapper function, accepts data and formula
mod_new <- crr.formula(Surv(ttdeath, grey) ~ age + trt + grade, trial2)
#> Warning in Surv(ttdeath, grey): Invalid status value, converted to NA
head(model.frame(mod_new))
#>    Surv(ttdeath, grey) age     trt grade
#> 1               24.00+  23    Drug     I
#> 3               24.00+  31    Drug     I
#> 5                20.02  51    Drug    II
#> 6               16.55+  39    Drug   III
#> 10               15.85  42 Placebo     I
#> 11              24.00+  63    Drug     I
tidy(mod_new)
#> # A tibble: 4 x 5
#>   .rownames      coef `se(coef)`       z `p-value`
#>   <chr>         <dbl>      <dbl>   <dbl>     <dbl>
#> 1 age         0.0149     0.00772  1.93       0.053
#> 2 trtPlacebo -0.00401    0.197   -0.0204     0.98 
#> 3 gradeII     0.0730     0.223    0.327      0.74 
#> 4 gradeIII    0.0810     0.229    0.354      0.72
```

## Contributing

Please note that the {riskybiz} project is released with a [Contributor
Code of
Conduct](http://www.danieldsjoberg.com/gtsummary/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms. A big
thank you to all contributors\!  
[@ddsjoberg](https://github.com/ddsjoberg), and
[@margarethannum](https://github.com/margarethannum)
