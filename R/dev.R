
#' Internal helper function for package development
#' @examples
#' if (FALSE) {
#'   devtools::load_all(); rebuild_docs_and_check()
#' }
#' 
#' @keywords internal
rebuild_docs_and_check <- function() {
  previous_version <- "0.0.0.9000"
  usethis::use_description(list(
      "Title" = "ambhtmx",
      "Description" = "Build a Full-stack R App with ambiorix and htmx.",
      "Version" = previous_version,
      "Authors@R" = utils::person(
          "Jordi", "Rosell",
          email = "jroselln@gmail.com",
          role = c("aut", "cre"),
          comment = c(ORCID = "0000-0002-4349-1458")
      ),
      Language =  "en"
  ))
  usethis::use_package("R", type = "Depends", min_version = "4.4")
  usethis::use_cc0_license()
  suggests_packages <- c(
      "pak",
      "pkgdown",
      "devtools",
      "usethis"
  )
  suggests_packages |> purrr::map(
      \(x){usethis::use_package(x, type = "Suggests"); x} 
  )
  imports_packages <- c(
      "ambiorix",
      "rlang",
      "purrr",
      "b64",
      "tibble",
      "uwu",
      "htmltools",
      "glue",
      "zeallot",
      "dplyr",
      "ggplot2",
      "stringr",
      "DBI",
      "RSQLite",
      "pool"
  )
  imports_packages |> purrr::map(
      \(x){usethis::use_package(x, type = "Imports"); x}
  )
  # dev_packages <- c(
  #   "scilis"
  # )
  # dev_packages |> purrr::map(
  #   \(x){usethis::use_dev_package(x, type = "Imports"); x}
  # )
    
  # spain_ccaas <- readr::read_rds("inst/extdata/spain_ccaas.rds")
  # spain_provinces <- readr::read_rds("inst/extdata/spain_provinces.rds")
  # usethis::use_data(spain_ccaas, spain_provinces, overwrite = TRUE)
  devtools::load_all()
  usethis::use_namespace()
  devtools::document()
  pkgdown::build_site()
  devtools::check()
  usethis::use_version(which = "dev", push = FALSE)
}
