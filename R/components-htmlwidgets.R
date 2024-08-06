#' @keywords components
#' @rdname components
#' @param widget htmlwidget to convert as a shiny.tag
#' @param ... attributes to add to the container
#' @param width to customeize the width of the container
#' @param height to customeize the width of the container
#' @export
amb_htmlwidget <- \(widget, ..., width = "100%", height = "400px") {
  temp_widget_file <- NULL
  widget_chr <- withr::with_tempfile("temp_widget_file", fileext = ".html", {
    htmlwidgets::saveWidget(widget, temp_widget_file, selfcontained = TRUE)
    lines_read <- readLines(temp_widget_file)    
    full_html <- paste0(lines_read, "\n", collapse = "")
    full_html |> 
      stringr::str_replace_all("<!DOCTYPE html>", "") |> 
      stringr::str_replace_all('<meta charset="utf-8" />', "") |>
      stringr::str_replace_all("<title>.*</title>", "") |>
      stringr::str_replace_all("<html.*>", "") |> 
      stringr::str_replace_all("</html>", "") |> 
      stringr::str_replace_all("<head>", "") |> 
      stringr::str_replace_all("</head>", "") |> 
      stringr::str_replace_all("<body.*>", "") |> 
      stringr::str_replace_all("</body>", "")
  })
  widget_html <- htmltools::HTML(widget_chr)
  widget_tags <- htmltools::tags$div(widget_html, width = width, height = height, ...)
  widget_tags
}

# #'@noRd
# amb_htmlwidget_data <- \(widget, ..., width = "100%", height = "400px") {
#   widget_chr <- withr::with_tempfile("temp_widget_file", fileext = ".html", {
#     htmlwidgets::saveWidget(widget, temp_widget_file, selfcontained = TRUE)
#     readLines(temp_widget_file) |> 
#       paste0("\n", collapse = "")  
#   })
#   start_pattern <- '<script type="application/json" data-for="'
#   stringr::str_extract(widget_chr, glue::glue('{start_pattern}.*</script>'))
# }