#' Competing risks functions
#'
#' These functions override the `crr` function provided in {cmprsk}
#' to produce more manageable competing risks model results (i.e. include
#' model.frame and formula in output) so that results can leverage functions
#' like `broom::tidy` the same way other regression function results do.
#'
#' @param formula input formula (e.g Surv(time, event) ~ var1 + var2). event
#' variable can have multiple levels for use in competing risks.
#' @param data MODIFY
#' @param ... other arguments passed on to `cmprsk::crr` (e.g. `cencode`, `failcode`)
#'
#'


#' @export


crr.formula <- function(formula, data, ...){
  Call <- match.call()
  Call[[1]] <- as.name("crr") # nicer output for user


  # rough start at checks up top as placeholder - just want to get the formula working first

  # get terms from formula input. No need for specials right now?
  # we can add clustered competing risks functionality later maybe :-P
  # if (is.list(formula))
  #   Terms <- if (missing(data)) terms(formula[[1]], specials=NULL) else
  #     terms(formula[[1]], specials=NULL, data=data)
  # else Terms <- if (missing(data)) terms(formula, specials=NULL) else
  #   terms(formula, specials=NULL, data=data)
  #
  #
  # # create call to model.frame() that contains a formula
  # Call$formula = formula
  #
  # indx <- match(c("formula", "data"),
  #               names(Call), nomatch = 0)
  # # check if there's a formula
  # if (indx[1] == 0) stop("A formula argument is required, otherwise use
  #                        standard crr input")

  # get terms from formula
  Terms <- terms(formula, specials = NULL, data = data)
  ftime_term <- Terms[[2]][[2]]
  fstatus_term <- Terms[[2]][[3]]
  form <- Terms[[3]]

  # grab vectors for input to crr
  ftime <- data[[ftime_term]]
  fstatus <- data[[fstatus_term]]

  # covariate matrix for crr
  cov1 <- model.matrix(as.formula(paste("~", deparse(form))), data)[, -1L]


  fit <- crr(ftime=ftime,
             fstatus = fstatus,
             cov1 = cov1)

  fit$terms <- Terms
  fit$formula <- formula(Terms)

  return(fit)
}


#' @export
crr.default <- function(...) cmprsk::crr(...)
