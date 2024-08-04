
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