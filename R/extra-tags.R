
#' Create HTML tags
#'
#' Create an R object that represents an HTML tag. For convenience, common HTML
#' tags (e.g., `<div>`) can be created by calling for their tag name directly
#' (e.g., `div()`). To create less common HTML5 (or SVG) tags (e.g.,
#' `<article>`), use the `tags` list collection (e.g., `tags$article()`). To
#' create other non HTML/SVG tags, use the lower-level `tag()` constructor.
#'
#' @name builder
#' @param ... Tag attributes (named arguments) and children (unnamed arguments).
#'   A named argument with an `NA` value is rendered as a boolean attributes
#'   (see example). Children may include any combination of:
#'   * Other tags objects
#'   * [HTML()] strings
#'   * [htmlDependency()]s
#'   * Single-element atomic vectors
#'   * `list()`s containing any combination of the above
#' @param .noWS Character vector used to omit some of the whitespace that would
#'   normally be written around this tag. Valid options include `before`,
#'   `after`, `outside`, `after-begin`, and `before-end`.
#'   Any number of these options can be specified.
#' @param .renderHook A function (or list of functions) to call when the `tag` is rendered. This
#'   function should have at least one argument (the `tag`) and return anything
#'   that can be converted into tags via [as.tags()]. Additional hooks may also be
#'   added to a particular `tag` via [tagAddRenderHook()].
#' @return A `list()` with a `shiny.tag` class that can be converted into an
#'   HTML string via `as.character()` and saved to a file with `save_html()`.
#' 
#' @rdname builder
#' @export
button <- htmltools::tags$button

#' @rdname builder
#' @export
textarea <- htmltools::tags$textarea

#' @rdname builder
#' @export
input <- htmltools::tags$input

#' @rdname builder
#' @export
label <- htmltools::tags$label

#' @rdname builder
#' @export
nav <- htmltools::tags$nav

#' @rdname builder
#' @export
li <- htmltools::tags$li

#' @rdname builder
#' @export
ul <- htmltools::tags$ul

#' @rdname builder
#' @export
ol <- htmltools::tags$ol

#' @rdname builder
#' @export
form <- htmltools::tags$form

#' @rdname builder
#' @export
style <- htmltools::tags$style

#' @rdname builder
#' @export
script <- htmltools::tags$script

#' Generate style from css template
#' 
#' @rdname style_from_css_tpl
#' @param file path to a js file
#' @param ... mutiple named arguments with the value to replaces
#' @examples
#' if (FALSE){
#'   # replaces "var(--tpl-background)" to "red"
#'   style_from_css_tpl("styles.css", background = "red")
#' }
#' @export
style_from_css_tpl <- \(file, ...) {
  html <- ""
  raw_content <- readr::read_file(file)
  content <- style_tpl_css_vars_replace(raw_content, ...)
  tryCatch(
    expr = {
      html <- htmltools::HTML("<style>", content, "</style>")
    },
    error = \(e) {
      print(e)
    }
  )
  return(html)
}


#' @noRd
style_tpl_css_vars_replace <- \(content, ...){
  props <- rlang::dots_list(...)    
  values <- paste0(props)
  if(length(values) == 0) {
    return(content)
  }  
  tpls <- paste0("var(--tpl-", names(props), ")")    
  names(values) <- tpls
  stringr::str_replace_all(content, stringr::fixed(values))
}


#' Generate script from js template
#' 
#' @rdname script_from_js_tpl
#' @param file path to a js file
#' @param ... mutiple named arguments with the value to replace
#' @examples
#' if (FALSE){
#'   # replaces "{init}" to "0"
#'   script_from_js_tpl("script.js", init = "init")
#' }
#' @export
script_from_js_tpl <- \(file, ...) {
  html <- ""
  raw_content <- readr::read_file(file)
  content <- script_tpl_js_vars_replace(raw_content, ...)
  tryCatch(
    expr = {
      html <- htmltools::HTML("<script>", content, "</script>")
    },
    error = \(e) {
      print(e)
    }
  )
  return(html)
}


#' @noRd
script_tpl_js_vars_replace <- \(content, ...){
  props <- rlang::dots_list(...)    
  values <- paste0(props)
  if(length(values) == 0) {
    return(content)
  }  
  tpls <- paste0("{", names(props), "}")
  names(values) <- tpls
  stringr::str_replace_all(content, stringr::fixed(values))
}

