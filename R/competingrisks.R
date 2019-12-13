#' Competing risks functions
#'
#' These functions override the `crr` function provided in {cmprsk}
#' to produce more manageable competing risks model results (i.e. include
#' model.frame and formula in output) so that results can leverage functions
#' like `broom::tidy` the same way other regression function results do.
#'
#' @param formula formula object with response on the left of a ~ operator
#' and terms on the right. Event variable can have multiple levels for use in
#' competing risks.
#' @param data a data.frame in which to interpret the variables named in the
#' `formula`
#' @inheritDotParams cmprsk::crr
#' @name crr
#' @examples
#'
#' trial <- na.omit(trial)
#'
#'  #original crr
#'  covars <- model.matrix(~ age + factor(trt) + factor(grade), trial)[,-1]
#'  ftime1 <- trial$ttdeath
#'  fstatus1 <- trial$death_cr
#'  mod_orig <- crr(ftime=ftime1,
#'           fstatus = fstatus1,
#'           cov1 = covars)
#'
#'  # using new wrapper function, accepts data and formula
#'  mod_new <- crr(Surv(ttdeath, death_cr) ~ age + trt + grade, trial)
NULL

#' @rdname crr
#' @export
crr <- function(formula, data, ...) {
  UseMethod("crr")
}

#' @rdname crr
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
  Terms <- stats::terms(formula, specials = NULL, data = data)
  ftime_term <- Terms[[2]][[2]]
  fstatus_term <- Terms[[2]][[3]]
  form <- Terms[[3]]

  # grab vectors for input to crr
  ftime <- data[[ftime_term]]
  fstatus <- data[[fstatus_term]]
  #browser()
  # covariate matrix for crr
  cov1 <- stats::model.matrix(stats::as.formula(paste("~", deparse(form))), data)[, -1L, drop = FALSE]


  ## extract data from the model formula and frame
  if(missing(data)) data <- environment(formula)
  mf <- match.call(expand.dots = FALSE)
  m <- match(c("formula", "data", "subset", "na.action"), names(mf), 0L)
  mf <- mf[c(1L, m)]
  mf$drop.unused.levels <- TRUE
  ## need stats:: for non-standard evaluation
  mf[[1L]] <- quote(stats::model.frame)
  #browser()
  mf <- suppressWarnings(eval(mf, parent.frame()))
  # if (method == "model.frame")
  #   return(mf)


  fit <- cmprsk::crr(ftime=ftime,
             fstatus = fstatus,
             cov1 = cov1)
  fit$call = Call
  fit$formula = formula(Terms)
  fit$data = data
  fit$model = mf
  fit$terms = Terms
  # fit <- c(fit, list(
  #   call = Call,
  #   formula = formula(Terms),
  #   terms = Terms,
  #   data = data,
  #   model = mf
  # )
  #)

  return(fit)
}

#' @export
model.frame.crr <- function (formula, ...)
{
  dots <- list(...)
  nargs <- dots[match(c("data", "na.action", "subset"), names(dots), 0L)]
  if (length(nargs) || is.null(formula$model)) {
    fcall <- formula$call
    m <- match(c("formula", "data", "subset", "na.action"), names(fcall), 0L)
    fcall <- fcall[c(1L, m)]
    fcall$drop.unused.levels <- TRUE
    fcall$method <- "model.frame"
    fcall[[1L]] <- quote(stats::model.frame)
    fcall$formula <- stats::terms(formula)
    fcall[names(nargs)] <- nargs
    env <- environment(formula$terms)
    if (is.null(env)) env <- parent.frame()
    eval(fcall, env)
  }
  else formula$model
}


# first pass - taken STRAIGHT from coxph pretty much
#' @export

model.matrix.crr <- function(object, data=NULL,
                               contrast.arg=object$contrasts, ...) {
  #
  # If the object has an "x" component, return it, unless a new
  #   data set is given
  if (is.null(data) && !is.null(object[['x']]))
    return(object[['x']]) #don't match "xlevels"

  Terms <- stats::delete.response(object$terms)
  if (is.null(data)) mf <- stats::model.frame(object)
  else {
    if (is.null(attr(data, "terms")))
      mf <- stats::model.frame(Terms, data, xlev=object$xlevels)
    else mf <- data  #assume "data" is already a model frame
  }

  # cluster <- attr(Terms, "specials")$cluster
  # if (length(cluster)) {
  #   temp <- untangle.specials(Terms, "cluster")
  #   dropterms <- temp$terms
  # }
  # else dropterms <- NULL

  #attr(Terms, "intercept") <- 1
  stemp <- survival::untangle.specials(Terms, 'strata', 1)
  hasinteractions <- FALSE
  dropterms <- NULL
  if (length(stemp$vars) > 0) {  #if there is a strata statement
    for (i in stemp$vars) {  #multiple strata terms are allowed
      # The factors attr has one row for each variable in the frame, one
      #   col for each term in the model.  Pick rows for each strata
      #   var, and find if it participates in any interactions.
      if (any(attr(Terms, 'order')[attr(Terms, "factors")[i,] >0] >1))
        hasinteractions <- TRUE
    }
    if (!hasinteractions) dropterms <- stemp$terms
  }

  if (length(dropterms)) {
    Terms2 <- Terms[ -dropterms]
    X <- stats::model.matrix(Terms2, mf, constrasts=contrast.arg)
    # we want to number the terms wrt the original model matrix
    temp <- attr(X, "assign")
    shift <- sort(dropterms)
    temp <- temp + 1*(shift[1] <= temp)
    if (length(shift)==2) temp + 1*(shift[2] <= temp)
    attr(X, "assign") <- temp
  }
  else X <- stats::model.matrix(Terms, mf, contrasts=contrast.arg)

  # drop the intercept after the fact, and also drop strata if necessary
  Xatt <- attributes(X)
  if (hasinteractions) adrop <- c(0, survival::untangle.specials(Terms, "strata")$terms)
  else adrop <- 0
  xdrop <- Xatt$assign %in% adrop  #columns to drop (always the intercept)
  X <- X[, !xdrop, drop=FALSE]
  attr(X, "assign") <- Xatt$assign[!xdrop]
  attr(X, "contrasts") <- Xatt$contrasts
  X
}


#' @rdname crr
#' @export
crr.default <- function(...) cmprsk::crr(...)
