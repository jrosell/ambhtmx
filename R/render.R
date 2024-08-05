
#' Render a custom page with a custom title and main content
#' 
#' @keywords render
#' @param main htmltools object of the body of the html page
#' @param page_title the title tag contents of the page
#' @param head_tags optional htmltools object of the head of the html page
#' @returns the rendered html of the full html page with dependencies
#' @details It can throw exceptions, so handling exceptions is recommended, if not a must.
#' @export
render_page <- \(main = NULL, page_title = NULL, head_tags = NULL) {
  penv <- rlang::env_parent()
  genv <- rlang::global_env()
  if (is.null(page_title)){    
    page_title <- penv[["page_title"]]
  }
  if (is.null(page_title)){    
    page_title <- genv[["page_title"]]
  }
  if (is.null(page_title)){    
    page_title <- "ambhtmx"
  }
  if (is.null(main)){    
    main <- penv[["main"]]
  }
  if (is.null(main)){    
    main <- genv[["main"]]
  }
  if (is.null(main)){    
    main <- htmltools::HTML("")
  }
  if (is.null(head_tags)){    
    head_tags <- penv[["head_tags"]]
  }
  if (is.null(head_tags)){    
    head_tags <- genv[["head_tags"]]
  }
  if (is.null(head_tags)) {
    head_tags <- htmltools::tagList(      
      tags$link(href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css", rel = "stylesheet", integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH",  crossorigin="anonymous"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js", integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz", crossorigin="anonymous"),
      htmltools::HTML('<script src="https://cdn.jsdelivr.net/gh/gnat/surreal@main/surreal.js"></script><script src="https://cdn.jsdelivr.net/gh/gnat/css-scope-inline@main/script.js"></script>')
    )
  }     
  html_tags <- htmltools::tagList(
    tags$head(
      tags$title(page_title),
      tags$style("body {background-color:white;}"),
      tags$script(src = "https://unpkg.com/htmx.org@2.0.1"),
      head_tags,      
    ),
    tags$body(
      `hx-encoding` = "multipart/form-data",
      main
    ) 
  )

  render_html(html_tags) 
}



#' Render a page and send the respose
#' 
#' @keywords render
#' @param res response object
#' @param main htmltools object of the body of the html page
#' @param ... other paramters to the render page function
#' @export
send_page <- \(main = NULL, res, ...) {
  html <- "Sorry. The system can't render the page as expected."
  tryCatch(
    expr = {
      html <- render_page(main = main, ...)
    },
    error = \(e) print(e)
  )
  res$send(html)
}


#' Render a custom page with a custom title and main content
#' 
#' @keywords render
#' @param main htmltools object to render
#' @param res response object
#' @param ... htmltools object to render
#' @export
send_tags <- \(main = NULL, res, ...) {
  html <- "Sorry. The system can't render the tags as expected."
  tryCatch(
    expr = {
      if (!is.null(main)) {
        html <- render_tags(main, ...)
      } else {
        html <- render_tags(...)
      }
    },
    error = \(e) print(e)
  )
  res$send(html)
}

#' @noRd
replace_hx_attrs <- function(x) {
  if (is.list(x)) {
    # Check if the element has a named list called 'attribs'
    if ("attribs" %in% names(x)) {
      # Replace 'hx_' with 'hx-' in attribute names
      names(x$attribs) <- gsub("hx_", "hx-", names(x$attribs))
    }
    
    # Apply the function recursively to all elements of the list
    x <- lapply(x, replace_hx_attrs)
  }
  
  return(x)
}

#' @noRd
replace_css_var_attrs <- function(x) {
  if (is.list(x)) {
    # Check if the element has a named list called 'attribs'
    if ("attribs" %in% names(x)) {
      # Replace 'hx_' with 'hx-' in attribute names
      names(x$attribs) <- gsub("hx_", "hx-", names(x$attribs))
    }
    
    # Apply the function recursively to all elements of the list
    original_class <- class(x)
    x <- lapply(x, replace_hx_attrs)
    class(x) <- original_class
  }
  return(x)
}


#' @noRd
replace_hx_attrs <- function(x) {
  if (is.list(x)) {
    # Check if the element has a named list called 'attribs'
    if ("attribs" %in% names(x)) {
      # Replace 'hx_' with 'hx-' in attribute names
      names(x$attribs) <- gsub("hx_", "hx-", names(x$attribs))
    }
    
    # Apply the function recursively to all elements of the list
    original_class <- class(x)
    x <- lapply(x, replace_hx_attrs)
    class(x) <- original_class
  }
  return(x)
}

#' @noRd
render_html <- \(htmx_tags){
  html_tags <- replace_hx_attrs(htmx_tags)
  rendered <- htmltools::renderTags(html_tags)
  deps <- lapply(rendered$dependencies, function(dep) {
    dep <- htmltools::copyDependencyToDir(dep, "lib", FALSE)
    dep <- htmltools::makeDependencyRelative(dep, NULL, FALSE)
    dep
  })
  bodyBegin <- if (!isTRUE(grepl("<body\\b", rendered$html[1], ignore.case = TRUE))) {
    "<body>"
  }
  bodyEnd <- if (!is.null(bodyBegin)) {
    "</body>"
  }
  html <- c(
    "<!DOCTYPE html>",
    '<html lang="en">',
    "<head>",
    "<meta charset=\"utf-8\"/>",
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    rendered$head,
    "<style>body{background-color:white;}</style>",
    htmltools::renderDependencies(deps, c("href", "file")),
    "</head>",
    bodyBegin,
    rendered$html,
    bodyEnd,
    "</html>"
  )
  return(paste0(html, collapse = ""))
}


#' Render tags to character vector
#' 
#' @keywords render
#' @param ... one or more htmltools objects.
#' @returns a character representation of input
#' @export
render_tags <- \(...) {
  as.character(htmltools::tagList(...))
}

#' Render imatge or ggplot to image tag
#' 
#' @param p a ggplot or another object that can be printed and captured as a png image
#' @returns img htmltools tag with a data encoded src attribute
#' @export
render_plot <- \(p){
  grDevices::png(p_file <- tempfile(fileext = ".png")); print(p); grDevices::dev.off()
  p_txt <- b64::encode_file(p_file)
  tags$img(src = glue::glue("data:image/png;base64,{p_txt}"))
}
