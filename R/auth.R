#' Render and send login page response
#' 
#' @keywords auth
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
#' @keywords auth
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
  if (!identical(params[[user_param]], Sys.getenv("AMBHTMX_USER"))){
    errors <- c(user_error, errors)
  }
  if (!identical(params[[password_param]], Sys.getenv("AMBHTMX_PASSWORD"))) {
    errors <- c(password_error, errors)
  }
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
#' @keywords auth
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
#' @keywords auth
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


#' Process error get requests
#' 
#' @keywords auth
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