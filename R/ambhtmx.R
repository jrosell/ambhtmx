#' Creating an ambiorix + htmx app
#' @export
ambhtmx_app <- \(
    dbname = NULL, 
    value = tibble::tibble(), 
    host = "127.0.0.1", 
    port = "8000", 
    live = FALSE,     
    renderer = NULL,
    auth = tibble(user = NULL, password = NULL)) {
  pool <- NULL
  data <- NULL
  name <- NULL
  if (!isFALSE(live)) {
    warning("live = TRUE is alpha")    
    cat(glue::glue("\nRun on the terminal for hot reloading:\nnpx nodemon --signal SIGTERM {live}\n\n\n"))
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
  data_add <- \(context, value = NULL){
    if (is.null(value)) stop("Value is required")
    con <- pool::poolCheckout(context$pool)     
    value$id <- uwu::new_v4(1)
    DBI::dbAppendTable(con, name = context$name, value = value)
    pool::poolReturn(con)
  }
  data_read <- \(context){
    con <- pool::poolCheckout(context$pool)
    df <- dplyr::tbl(con, context$name) |> dplyr::filter(.data$id != "") |> dplyr::collect()
    pool::poolReturn(con)
    return(df)
  }
  data_update <- \(context, value = NULL){
    con <- pool::poolCheckout(context$pool)
    columns_to_update <- paste0(paste0(names(value[-1]), "=\"", value[-1], "\""), collapse = ", ")  
    sql <- glue::glue("UPDATE {context$name} SET {columns_to_update} WHERE id=\"{value$id}\"")
    result <- DBI::dbExecute(con, sql)  
    pool::poolReturn(con)
    return(result)
  }
  data_delete <- \(context, value = NULL){
    con <- pool::poolCheckout(context$pool)
    sql <- glue::glue("DELETE FROM {context$name} WHERE id=\"{value$id}\"")
    result <- DBI::dbExecute(con, sql)  
    pool::poolReturn(con)
    invisible(NULL)
  }
  data_auth <- \(context, value = NULL){
    con <- pool::poolCheckout(context$pool)
    sql <- glue::glue("DELETE FROM {context$name} WHERE id=\"{value$id}\"")
    result <- DBI::dbExecute(con, sql)  
    pool::poolReturn(con)
    invisible(NULL)
  }
  r <- list(
    app = ambiorix::Ambiorix$new(host = host, port = port), 
    context = list(pool = pool, name = name, value = value),
    operations = list(
      data_add = data_add,
      data_read = data_read,
      data_update = data_update,
      data_delete = data_delete
    )
  )
  if (nrow(auth) > 0){
    r$operations$data_auth <- \(user = NULL, password = NULL) {
      auth |> filter(.data["user"] == user, .data["password"] == password)
    }
  }  
  return(r)
}

#' @noRd
render_html <- \(html){
  rendered <- htmltools::renderTags(html)
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

#' Render a custom page with a custom title and main content
#' @export
render_page <- \(title, main) {    
  html <- htmltools::tagList(
    tags$head(
      tags$title(title),
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
  render_html(html) 
}

#' Render tags to character vector
#' @export
render_tags <- \(...) {
  as.character(htmltools::tagList(...))
}

#' Render imatge or ggplot to image tag
#' @export
render_plot <- \(p){
  grDevices::png(p_file <- tempfile(fileext = ".png")); print(p); grDevices::dev.off()
  p_txt <- b64::encode_file(p_file)
  tags$img(src = glue::glue("data:image/png;base64,{p_txt}"))
}

