#' Generate component
#' 
#' @keywords components
#' @rdname components
#' @param ... htmlobjects to add
#' @param class to add more classes to the card
#' @param title to customeize the title text
#' @param title_icon to customize the title icon
#' @param title_class to add more classes to the title
#' @export
amb_card <- \(
  ...,
  class = NULL,
  title = NULL,
  title_icon = NULL,
  title_class = NULL
) {
  htmltools::tags$div(
    class = paste("card p-1 p-md-4 border-0", class),
    htmltools::tags$div(
      class = "card-body",
      if (!is.null(title) || !is.null(title_icon)) {
        htmltools::tags$h3(
          class = paste("card-title spectral-bold fs-4 mb-3", title_class),
          title_icon,
          title
        )
      },
      ...
    )
  )
}

#' @rdname components
#' @param ... htmlobjects to add
#' @param id for the label and the input
#' @param label customize
#' @param value customize
#' @param input_class customize
#' @param hx_post customize
#' @export
amb_input_text <- \(
      ...,
      id,
      label = NULL,
      value = "",
      input_class = NULL,
      hx_post = NULL
    ) {
  htmltools::tags$div(
    class = "mb-3",
    `hx-target` = "this",
    `hx-swap` = "outerHTML",
    htmltools::tags$label(
      `for` = id,
      class = "form-label",
      label
    ),
    htmltools::tags$input(
      type = "text",
      name = id,
      id = id,
      class = paste("form-control", input_class),
      required = NA,
      value = value,
      `hx-post` = hx_post
    ),
    ...
  )
}

#' @rdname components
#' @param ... htmlobjects to add
#' @param class customize
#' @param type customize
#' @export
amb_button <- \(..., class = "rounded-1", type = "button") {
  button(
    type = type,
    class = class,
    ...
  )
}




