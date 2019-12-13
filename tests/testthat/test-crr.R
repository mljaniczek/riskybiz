context("test-crr")
trial <- na.omit(trial)
covars <- model.matrix(~ age + factor(trt) + factor(grade), trial)[,-1]
ftime1 <- trial$ttdeath
fstatus1 <- trial$death_cr

test_that("uv crr.formula no errors/warnings with standard use", {
  expect_error(crr(Surv(ttdeath, death_cr) ~ age, trial), NA)
  expect_warning(crr(Surv(ttdeath, death_cr) ~ age, trial), NA)
})

test_that("mv crr.formula no errors/warnings with standard use", {
  expect_error(crr(Surv(ttdeath, death_cr) ~ age + trt + grade, trial), NA)
  expect_warning(crr(Surv(ttdeath, death_cr) ~ age + trt + grade, trial), NA)
})

test_that("interaction crr.formula no errors/warnings with standard use", {
  expect_error(crr(Surv(ttdeath, death_cr) ~ age*trt + grade, trial), NA)
  expect_warning(crr(Surv(ttdeath, death_cr) ~ age*trt + grade, trial), NA)
})

test_that("mv crr.default no errors/warnings with standard use", {
  expect_error(crr(ftime=ftime1,
                   fstatus = fstatus1,
                   cov1 = covars), NA)
  expect_warning(crr(ftime=ftime1,
                     fstatus = fstatus1,
                     cov1 = covars), NA)
})
