#' Creating an ambiorix + htmx app
#' 
#' @keywords ambhtmx
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
ambhtmx <- \(
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
  protocol <- protocol %||% "http"  
  host <- host %||% "127.0.0.1"
  port <- port %||% "8000"
  if(identical(Sys.getenv("AMBHTMX_HOST"), "") || 
        identical(Sys.getenv("AMBHTMX_PORT"), "") ||
        identical(Sys.getenv("AMBHTMX_PROTOCOL"), "")
      ) {
    cat(glue::glue("Set AMBHTMX_PROTOCOL, AMBHTMX_HOST and AMBHTMX_PORT environment variables to configure the server. For now, {protocol}://{host}:{port} is set."))
  } else{
    protocol <- Sys.getenv("AMBHTMX_PROTOCOL")
    host <- Sys.getenv("AMBHTMX_HOST")
    port <- Sys.getenv("AMBHTMX_PORT")
  }
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
    if (stringr::str_detect(name, "/")) name <- dplyr::last(stringr::str_split("/tmp/RtmpUkt3qX/file7653f58e0", "/")[[1]])
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
    if (is_debug_enabled()) {print("value"); print(value)}
    tryCatch({
        DBI::dbAppendTable(con, name = context$name, value = value)
      },
      error = \(e) stop(e)
    )   
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
    if (is_debug_enabled()) {print("sql"); print(sql)}
    tryCatch({
        invisible(DBI::dbExecute(con, sql))
      },
      error = \(e) print(e)
    )
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
    if(!is.null(value) && !is.null(value[["id"]])) {
      sql <- glue::glue("DELETE FROM {context$name} WHERE id=\"{value$id}\"")
    }
    if(!is.null(id)) {
      sql <- glue::glue("DELETE FROM {context$name} WHERE id=\"{id}\"")
    }
    tryCatch({
        if (is_debug_enabled()) {print("sql"); print(sql)}
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
