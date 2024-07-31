rlang::check_installed("ambiorix", action = \(pkg, ... ) remotes::install_github("devOpifex/ambiorix")); library(ambiorix)
rlang::check_installed("uwu", action = \(pkg, ... ) remotes::install_github("josiahparry/uwu")); library(uwu)
rlang::check_installed("htmltools"); library(htmltools)
rlang::check_installed("glue"); library(glue)
rlang::check_installed("zeallot"); library(zeallot)
rlang::check_installed("dplyr"); library(dplyr)
rlang::check_installed("ggplot2"); library(ggplot2)
rlang::check_installed("stringr"); library(stringr)
rlang::check_installed("DBI"); library(DBI)
rlang::check_installed("RSQLite")
rlang::check_installed("pool"); library(pool)

ambhtmx_app <- \(
    dbname = NULL, 
    value = tibble(), 
    host = "127.0.0.1", 
    port = "8000", 
    live = FALSE,     
    renderer = NULL) {
  pool <- NULL
  data <- NULL
  name <- NULL
  if (live) {
    warning("live = TRUE not yet implemented.")
  }
  if (nrow(value) == 1) {
    create_table <- !is.null(dbname) && !file.exists(dbname)
    pool <- dbPool(
      drv = RSQLite::SQLite(),
      dbname = dbname
    )
    on.exit(\() {
      poolClose(pool)
    })
    con <- poolCheckout(pool)
    name <- str_split(dbname, fixed("."))[[1]][1]
    if (create_table) {            
      DBI::dbWriteTable(
        con,
        name = name,
        value = value
      )      
    }
    if (file.exists(dbname)) {
      data <- tbl(con, name) |> collect()
    }
    poolReturn(con)
  }
  context = list(pool = pool, name = name, value = value)
  data_add <- \(context, value = NULL){
    if (is.null(value)) stop("Value is required")
    con <- poolCheckout(context$pool)     
    value$id <- uwu::new_v4(1)
    DBI::dbAppendTable(con, name = context$name, value = value)
    poolReturn(con)
  }
  data_read <- \(context){
    con <- poolCheckout(context$pool)
    df <- tbl(con, context$name) |> filter(id != "") |> collect()
    poolReturn(con)
    return(df)
  }
  data_update <- \(context, value = NULL){
    con <- poolCheckout(context$pool)
    columns_to_update <- paste0(paste0(names(value[-1]), "=\"", value[-1], "\""), collapse = ", ")  
    sql <- glue("UPDATE {context$name} SET {columns_to_update} WHERE id=\"{value$id}\"")
    print(sql)
    result <- dbExecute(con, sql)  
    poolReturn(con)
    return(result)
  }
  data_delete <- \(context, value = NULL){
    con <- poolCheckout(context$pool)
    sql <- glue("DELETE FROM {context$name} WHERE id=\"{value$id}\"")
    print(sql)
    result <- dbExecute(con, sql)  
    poolReturn(con)
    return(df)
  }
  list(
    app = Ambiorix$new(host = host, port = port), 
    context = list(pool = pool, name = name, value = value),
    operations = list(
      data_add = data_add,
      data_read = data_read,
      data_update = data_update,
      data_delete = data_delete
    )
  )
}


render_html <- \(html){
  rendered <- renderTags(html)
  deps <- lapply(rendered$dependencies, function(dep) {
    dep <- copyDependencyToDir(dep, "lib", FALSE)
    dep <- makeDependencyRelative(dep, NULL, FALSE)
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
    renderDependencies(deps, c("href", "file")),
    "</head>",
    bodyBegin,
    rendered$html,
    bodyEnd,
    "</html>"
  )
  return(paste0(html, collapse = ""))
}


render_page <- \(title, main) {    
  html <- tagList(
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

render_tags <- \(...) {
  as.character(tagList(...))
}

render_plot <- \(p){
  png(p_file <- tempfile(fileext = ".png")); print(p); dev.off()
  p_txt <- b64::encode_file(p_file)
  tags$img(src = glue("data:image/png;base64,{p_txt}"))
}