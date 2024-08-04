utils::globalVariables(c("tags",".data"))

#' @keywords internal
#' @noRd
attach_library <- function(pkg) {
  loc <- if (pkg %in% loadedNamespaces()) dirname(getNamespaceInfo(pkg, "path"))
  library(pkg, lib.loc = loc, character.only = TRUE, warn.conflicts = FALSE)
}

.onAttach <- function(...) {
  ambhtmx_core <- c("ambiorix", "htmltools", "tibble", "dplyr", "purrr", "stringr", "glue", "zeallot")

  invisible(suppressPackageStartupMessages(
    lapply(ambhtmx_core, attach_library)
  ))
}