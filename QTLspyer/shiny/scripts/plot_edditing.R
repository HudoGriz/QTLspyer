# Post plotting processing.

make.arguments <- function(p, names, ...) {
  # Create argument list

  arguments <- list(p = p, ...)
  for (n in names) {
    arguments[[n]] <- list(fixedrange = TRUE)
  }

  return(arguments)
}

edit_plotly <- function(p, names, ...) {
  # Sets layout parameters and executes function

  arguments <- make.arguments(p = p, names = names, ...)

  p <- do.call(plotly::layout, args = arguments)

  return(p)
}
