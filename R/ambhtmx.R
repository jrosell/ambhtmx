

#' Creating an ambiorix + htmx app
#' 
#' @param dbname file path to store a SQLite database (optional).
#' @param value a 1 row tibble with the names and types of the columns (optional)
#' @param protocol (default AMBHTMX_PROTOCOL or http)
#' @param host (default AMBHTMX_HOST or 127.0.0.1)
#' @param port (default AMBHTMX_PORT or 3000) 
#' @param live script with the file path (optional)
#' @param favicon (optional)
#' @param render_index function to be stored as a model method (optional)
#' @param render_row function to be stored as a model method (optional)
#' @returns A list with the ambiorix app, the running context and the model methods.
#' @export
ambhtmx_app <- \(
      dbname = NULL, 
      value = tibble::tibble(), 
      protocol = NULL,
      host = NULL, 
      port = NULL, 
      live = "",      
      favicon = NULL,
      render_index = NULL,
      render_row = NULL
    ){
  pool <- NULL
  data <- NULL
  name <- NULL
  if(is.null(Sys.getenv("AMBHTMX_HOST")) || 
        is.null(Sys.getenv("AMBHTMX_PORT")) ||
        is.null(Sys.getenv("AMBHTMX_PROTOCOL"))
      ) {
    print("Set AMBHTMX_PROTOCOL, AMBHTMX_HOST and AMBHTMX_PORT environment variables to configure the server. By default, http://127.0.0.1:8000 is set.")
  }
  protocol <- protocol %||% Sys.getenv("AMBHTMX_PROTOCOL") %||% "http"
  port <- port %||% Sys.getenv("AMBHTMX_PORT") %||% "8000"
  host <- host %||% Sys.getenv("AMBHTMX_HOST") %||% "127.0.0.1"
  if (live != "") {
    warning("live = TRUE is alpha")     
    # ps -ef | grep "nodemon --signal SIGTERM "
    args1 <- commandArgs()[1]
    cat(glue::glue("\nRun from {args1} on the terminal for hot reloading:\nnpx nodemon --signal SIGTERM {live}\n\n\n"))
  }  
  if (nrow(value) == 1) {
    create_table <- !is.null(dbname) && !file.exists(dbname)
    pool <- pool::dbPool(
      drv = RSQLite::SQLite(),
      dbname = dbname
    )
    on.exit(\() {
      pool::poolClose(pool)
    })
    con <- pool::poolCheckout(pool)
    name <- stringr::str_split(dbname, stringr::fixed("."))[[1]][1]
    if (create_table) {            
      DBI::dbWriteTable(
        con,
        name = name,
        value = value
      )      
    }
    if (file.exists(dbname)) {
      data <- dplyr::tbl(con, name) |> dplyr::collect()
    }
    pool::poolReturn(con)
  }
  context = list(pool = pool, name = name, value = value)
  add_row <- \(value = NULL, context = NULL){
    if (is.null(context)){
      penv <- rlang::env_parent()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      penv <- rlang::global_env()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      stop("You need to set a context.")
    }
    tryCatch({
        con <- pool::poolCheckout(context$pool)
      },
      error = \(e) stop(e)
    )
    if (is.null(value)) stop("Value is required")
    if (is.null(value[["id"]])) {
      value <- value |>
        dplyr::mutate(id = uwu::new_v4(1))
    }
    DBI::dbAppendTable(con, name = context$name, value = value)
    pool::poolReturn(con)
    return(value$id)
    }
  read_row <- \(value = NULL,context = NULL, id = NULL){
    if (is.null(context)){
      penv <- rlang::env_parent()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      penv <- rlang::global_env()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      stop("You need to set a context.")
    }
    tryCatch({
        con <- pool::poolCheckout(context$pool)
      },
      error = \(e) stop(e)
    )
    df <- dplyr::tbl(con, context$name) |>
      dplyr::filter(.data[["id"]] == {{ id }}) |>
      dplyr::collect()
    pool::poolReturn(con)
    return(df)
  }
  read_rows <- \(context = NULL, collect = TRUE){
    if (is.null(context)){
      penv <- rlang::env_parent()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      penv <- rlang::global_env()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      stop("You need to set a context.")
    }
    tryCatch({
        con <- pool::poolCheckout(context$pool)
      },
      error = \(e) stop(e)
    )
    df <- dplyr::tbl(con, context$name) |>
      dplyr::filter(.data[["id"]] != "")
    if(collect) df <- dplyr::collect(df)
    pool::poolReturn(con)
    return(df)
  }  
  update_row <- \(value = NULL, context = NULL, id = NULL){
    if (is.null(context)){
      penv <- rlang::env_parent()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      penv <- rlang::global_env()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      stop("You need to set a context.")
    }
    tryCatch({
        con <- pool::poolCheckout(context$pool)
      },
      error = \(e) stop(e)
    )
    if(!is.null(value[["id"]])) id = value$id
    value$id <- NULL
    columns_to_update <- paste0(paste0(names(value), "=\"", value, "\""), collapse = ", ")    
    sql <- glue::glue("UPDATE {context$name} SET {columns_to_update} WHERE id=\"{id}\"")
    invisible(DBI::dbExecute(con, sql))
    pool::poolReturn(con)
    invisible(NULL)
  }
  delete_row <- \(value = NULL, context = NULL, id = NULL){
    if (is.null(context)){
      penv <- rlang::env_parent()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      penv <- rlang::global_env()
      context <- penv[["context"]]
    }
    if (is.null(context)){
      stop("You need to set a context.")
    }
    tryCatch({
        con <- pool::poolCheckout(context$pool)
      },
      error = \(e) stop(e)
    )
    if(!is.null(value) && !is.null(value$id)) {
      sql <- glue::glue("DELETE FROM {context$name} WHERE id=\"{value$id}\"")
    }
    if(!is.null(id)) {
      sql <- glue::glue("DELETE FROM {context$name} WHERE id=\"{id}\"")
    }
    tryCatch({
        invisible(DBI::dbExecute(con, sql))
      },
      error = \(e) print(e)
    )
    tryCatch({
        pool::poolReturn(con)
      },
      error = \(e) print(e)
    )    
    invisible(NULL)
  }
  app <- ambiorix::Ambiorix$new(host = host, port = port)
  if (nchar(Sys.getenv("AMBHTMX_USER")) < 2 || nchar(Sys.getenv("AMBHTMX_PASSWORD")) < 2) {
    cat("\nSet AMBHTMX_USER and AMBHTMX_PASSWORD environment variables to configure authentication.\n\n")
  }
  if(requireNamespace("scilis") && length(Sys.getenv("AMBHTMX_SECRET")) >= 2) {
    app <- app$use(scilis::scilis(Sys.getenv("AMBHTMX_SECRET")))
  } else {
    cat("\nLoad scilis package and set AMBHTMX_SECRET environment variable to keep cookies safe.\n\n")
  }
  if(requireNamespace("signaculum")) {
    if(is.null(favicon)) {    
      cat("\nDefault favicon is used. You can customize it.\n\n")
      favicon <- system.file("favicon.ico", package = "signaculum")    
    }
    app <- app$get("/favicon.ico", signaculum::signaculum(favicon))
  } else {
    cat("\nLoad signaculum package and set a favicon to customize the favicon.\n\n")
  }  
  r <- list(
    app = app,
    context = list(pool = pool, name = name, value = value),
    operations = list(
      add_row = add_row,
      read_row = read_row,
      read_rows = read_rows,
      update_row = update_row,
      delete_row = delete_row,
      render_index = render_index,
      render_row = render_row
    )
  )
  return(r)
}


#' Render a custom page with a custom title and main content
#' 
#' @param main htmltools object of the body of the html page
#' @param page_title the title tag contents of the page
#' @returns the rendered html of the full html page with dependencies
#' @export
render_page <- \(main = NULL, page_title = NULL) {
  if (is.null(page_title)){
    penv <- rlang::env_parent()
    page_title <- penv[["page_title"]]
  }
  if (is.null(main)){
    penv <- rlang::env_parent()
    main <- penv[["main"]]
  }
  html_tags <- htmltools::tagList(
    tags$head(
      tags$title(page_title),
      tags$style("body {background-color:white;}"),
      tags$link(href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css", rel = "stylesheet", integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH",  crossorigin="anonymous"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js", integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz", crossorigin="anonymous"),
      tags$script(src = "https://unpkg.com/htmx.org@2.0.1")
    ),
    tags$body(
      `hx-encoding` = "multipart/form-data",
      main
    ) 
  )
  render_html(html_tags) 
}



#' Render a custom page with a custom title and main content
#' 
#' @param res response object
#' @param main htmltools object of the body of the html page
#' @param page_title the title tag contents of the page
#' @returns the response page
#' @export
send_page <- \(main, res, ...) {  
  html <- render_page(main = main, ...)
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


#' Render and send login page response
#' 
#' @param req request object
#' @param res response object
#' @param page_title if you need to customize the title of the page
#' @param main if you need to customize the body of the login page
#' @param id if you need to customize the id of the login form
#' @param login_url if you need to customize the url of the login form
#' @param style if you need to customize the styles of the login form
#' @param cookie_errors if you need to customize the name of the errors cookie
#' @returns the login page response
#' @export
process_login_get <- \(
      req,
      res,
      page_title = "Login",
      main = NULL,
      id = "login_form",
      login_url = "/login",
      style = "margin: 20px",
      cookie_errors = "errors"
    ){
  if (is_debug_enabled()) print("process_login_get")
  errors <- ""    
  cookie <- req$cookie[[cookie_errors]]
  
  if (is_debug_enabled()) {
    cat(glue::glue("\ncookie_errors {cookie_errors} is {req$cookie[[cookie_errors]]}\n\n"))
  }

  if (is.character(cookie) && cookie != "" && 
      length(cookie) > 0 &&
      !stringr::str_detect(cookie, "devOpifex/scilis")
  ) {
    errors <- req$cookie[[cookie_errors]]    
    res$cookie(name = cookie_errors, value = "")
  }
  if (is.null(main)) {
    main <- htmltools::tagList(
      tags$h1(page_title),
      tags$div(htmltools::tagList(
        tags$div(
          tags$label(
            "User",
            tags$div(tags$input(type = "text", name = "user"))
          )
        ),
        tags$div(
          tags$label(
            "Password",
            tags$div(tags$input(type = "password", name = "password"))
          )
        ),
        tags$div(id = "login_response", errors)
      )),
      tags$button(page_title)
    )
  }
  html <- render_page(
    page_title = page_title,
    main = tags$form(
      action = login_url, 
      method = "post", 
      enctype = "multipart/form-data", 
      id = id, 
      style = style, 
      main
    )
  )
  res$send(html)
}

#' Process login requests
#' 
#' @param req request object
#' @param res response object
#' @param user_param if you need to customize the name of the user parameter
#' @param password_param if you need to customize the name of the password parameter
#' @param user if you want to customize the required user or it uses AMBHTMX_USER
#' @param password if you want to customize the required password  or it uses AMBHTMX_PASSWORD
#' @param user_error if you need to customize the error message for the user
#' @param password_error if you need to customize the error message for the password
#' @param cookie_loggedin if you need to customize the name of the loggedin cookie
#' @param cookie_errors if you need to customize the name of the errors cookie
#' @param login_url if you need to customize the url of the login form
#' @param success_url if you need to customize the url of the success loggedin process
#' @returns the login process response
#' @export
process_login_post <- \(
    req,
    res,
    user_param = "user",
    password_param = "password",
    user = Sys.getenv("AMBHTMX_USER"),
    password = Sys.getenv("AMBHTMX_PASSWORD"),
    user_error = "Invalid user",
    password_error = "Invalid password",
    cookie_loggedin = "loggedin",
    cookie_errors = "errors",
    login_url = "/login",
    success_url = "/") {
  if (is_debug_enabled()) print("process_login_post")
  params <- ambiorix::parse_multipart(req)  
  errors <- c("")

  if (!identical(params[[user_param]], Sys.getenv("AMBHTMX_USER")))
    errors <- c(user_error, errors)

  if (!identical(params[[password_param]], Sys.getenv("AMBHTMX_PASSWORD")))
    errors <- c(password_error, errors)

  if (length(errors)>1) {
    error_message <- paste0(errors[1:length(errors)-1], ". ", collapse = "")
    res$cookie(
      name = cookie_errors,
      value = error_message
    )    
    return(res$redirect(login_url, status = 302L))
  }

  if (is_debug_enabled()) {
    cat(glue::glue("\ncookie_loggedin {cookie_loggedin} and user {params[[user_param]]}\n\n"))
  }
  res$cookie(
      cookie_loggedin,
      params[[user_param]]
  )
  if (is_debug_enabled()) {
    cat(glue::glue("\n{cookie_loggedin} = {params[[user_param]]}\n\n"))
  }
  res$redirect(success_url, status = 302L)
}

#' Process logout requests
#' 
#' @param req request object
#' @param res response object
#' @param cookie_loggedin if you need to customize the name of the loggedin cookie
#' @param success_url if you need to customize the url of the success loggedin process
#' @returns the logout process response
#' @export
process_logout_get <- \(
      req,
      res,  
      cookie_loggedin = "loggedin",  
      success_url = "/"
    ) {
  if (is_debug_enabled()) print("process_logout_get")
  res$cookie(
      name = cookie_loggedin,
      ""
  )
  if (is_debug_enabled()) {
    cat(glue::glue('\ncookie {cookie_loggedin} is set to ""\n\n'))
  }
  res$redirect(success_url, status = 302L)
}

#' Process loggedin middleware
#' 
#' @param req request object
#' @param res response object
#' @param user if you want to customize the required user or it uses AMBHTMX_USER
#' @param cookie_loggedin if you need to customize the name of the loggedin cookie
#' @returns the updated request with the req$loggedin status
#' @export
process_loggedin_middleware <- \(
      req,
      res,
      user = Sys.getenv("AMBHTMX_USER"),
      cookie_loggedin = "loggedin"
    ) { 
  if (is_debug_enabled()) print("process_loggedin_middleware")
  req$loggedin <- identical(req$cookie[[cookie_loggedin]], user)

  if (is_debug_enabled()) {    
    cat(glue::glue("\req$cookie[[cookie_loggedin]] is {req$cookie[[cookie_loggedin]]}\n\n"))
    cat(glue::glue("\nreq$loggedin <- {req$loggedin}\n\n"))
  }
}


#' Process error post requests
#' 
#' @param req request object
#' @param res response object
#' @param errors the error message character vector
#' @param cookie_errors if you need to customize the name of the errors cookie
#' @param error_url if you need to customize the url of the error to redirect to.
#' @returns the error process response
#' @export
process_error_post <- \(
      req,
      res,
      errors = NULL,
      cookie_errors = "errors",
      error_url = NULL
    ) {  
  if (is_debug_enabled()) print("process_error_post")
  error_message <- paste0(errors, ". ", collapse = "")
  res$cookie(
    name = cookie_errors,
    value = error_message
  )
  res$header("HX-Redirect", error_url)
  return(res$redirect(error_url, status = 302L))
}

#' Process error get requests
#' 
#' @param req request object
#' @param res response object
#' @param cookie_errors if you need to customize the name of the errors cookie
#' @returns the error character vector
#' @export
process_error_get <- \(
      req,
      res,      
      cookie_errors = "errors"
    ){
  if (is_debug_enabled()) print("process_error_get")
  errors <- ""
  cookie <- req$cookie[[cookie_errors]]
  if (is.character(cookie) && cookie != "" && length(cookie) > 0){
    errors <- req$cookie[[cookie_errors]]    
    res$cookie(name = cookie_errors, value = "")  
  }
  return(errors)
}