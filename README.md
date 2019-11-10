
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
#>                      coef exp(coef) se(coef)     z p-value
#> age                0.0106      1.01  0.00618 1.714   0.086
#> factor(trt)Placebo 0.0891      1.09  0.18702 0.477   0.630
#> factor(grade)II    0.1396      1.15  0.22098 0.632   0.530
#> factor(grade)III   0.2287      1.26  0.21811 1.049   0.290
#> 
#>                    exp(coef) exp(-coef)  2.5% 97.5%
#> age                     1.01      0.989 0.998  1.02
#> factor(trt)Placebo      1.09      0.915 0.758  1.58
#> factor(grade)II         1.15      0.870 0.746  1.77
#> factor(grade)III        1.26      0.796 0.820  1.93
#> 
#> Num. cases = 173
#> Pseudo Log-likelihood = -430 
#> Pseudo likelihood ratio test = 3.07  on 4 df,
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
#> 1               24.00+  23 Placebo    II
#> 3               24.00+  31 Placebo    II
#> 4                16.43  51 Placebo   III
#> 5               15.64+  39    Drug     I
#> 9               10.53+  34    Drug     I
#> 10               24.00  42    Drug   III
tidy(mod_new)
#> # A tibble: 4 x 7
#>   term       estimate std.error statistic p.value conf.low conf.high
#>   <chr>         <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 age          0.0106   0.00618     1.71    0.086 -0.00152    0.0227
#> 2 trtPlacebo   0.0891   0.187       0.477   0.63  -0.277      0.456 
#> 3 gradeII      0.140    0.221       0.632   0.53  -0.294      0.573 
#> 4 gradeIII     0.229    0.218       1.05    0.290 -0.199      0.656
```

## Contributing

Please note that the {riskybiz} project is released with a [Contributor
Code of
Conduct](https://github.com/margarethannum/riskybiz/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms. A big
thank you to all contributors\!
