#' Competing risks functions
#'
#' These functions override the `crr` function provided in {cmprsk}
#' to produce more manageable competing risks model results (i.e. include
#' model.frame and formula in output) so that results can leverage functions
#' like `broom::tidy` the same way other regression function results do.
#'
#' @param formula MODIFY
#' @param data MODIFY
#' @param ... other arguments passed on to `cmprsk::crr`
#'


#' @export
crr.formula <- function(...) {
  #DO STUFF
}


#' @export
crr.default <- function(...) cmprsk::crr(...)
