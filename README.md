
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
library(riskybiz)
#> Loading required package: cmprsk
#> Loading required package: survival
#> 
#> Attaching package: 'riskybiz'
#> The following object is masked from 'package:cmprsk':
#> 
#>     crr

trial <- na.omit(trial)
#original crr
covars <- model.matrix(~ age + factor(trt) + factor(grade), trial)[,-1]
ftime1 <- trial$ttdeath
fstatus1 <- trial$death_cr
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
#> cmprsk::crr(ftime = ..1, fstatus = ..2, cov1 = ..3)
#> 
#>                         coef exp(coef) se(coef)       z p-value
#> age                 5.27e-05     1.000  0.00599  0.0088    0.99
#> factor(trt)Placebo -1.15e-01     0.892  0.17919 -0.6404    0.52
#> factor(grade)II    -1.01e-01     0.904  0.23149 -0.4368    0.66
#> factor(grade)III    2.96e-01     1.345  0.20284  1.4606    0.14
#> 
#>                    exp(coef) exp(-coef)  2.5% 97.5%
#> age                    1.000      1.000 0.988  1.01
#> factor(trt)Placebo     0.892      1.122 0.628  1.27
#> factor(grade)II        0.904      1.106 0.574  1.42
#> factor(grade)III       1.345      0.744 0.904  2.00
#> 
#> Num. cases = 173
#> Pseudo Log-likelihood = -434 
#> Pseudo likelihood ratio test = 2.87  on 4 df,
```

Using our wrapper function `riskybiz::crr()` allows for inputting an
intuitive formula and data, which allows for downstream functions.

``` r

# using new wrapper function, accepts data and formula
mod_new <- crr(Surv(ttdeath, death_cr) ~ age + trt + grade, trial)
#> Warning in Surv(ttdeath, death_cr): Invalid status value, converted to NA
head(model.frame(mod_new))
#>    Surv(ttdeath, death_cr) age     trt grade
#> 1                   24.00+  23 Placebo    II
#> 2                   24.00+   9    Drug     I
#> 3                    24.00  31 Placebo    II
#> 6                   15.64+  39    Drug     I
#> 10                  10.53+  34    Drug     I
#> 11                  24.00+  42    Drug   III
tidy(mod_new)
#> # A tibble: 4 x 7
#>   term         estimate std.error statistic p.value conf.low conf.high
#>   <chr>           <dbl>     <dbl>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 age         0.0000527   0.00599   0.00880    0.99  -0.0117    0.0118
#> 2 trtPlacebo -0.115       0.179    -0.640      0.52  -0.466     0.236 
#> 3 gradeII    -0.101       0.231    -0.437      0.66  -0.555     0.353 
#> 4 gradeIII    0.296       0.203     1.46       0.14  -0.101     0.694
```

## Contributing

Please note that the {riskybiz} project is released with a [Contributor
Code of
Conduct](https://github.com/margarethannum/riskybiz/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms. A big
thank you to all contributors\!  
[@ddsjoberg](https://github.com/ddsjoberg), and
[@margarethannum](https://github.com/margarethannum)
