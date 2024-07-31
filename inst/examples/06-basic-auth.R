#' Loading required packages
if(!"rlang" %in% installed.packages()){
  if(!interactive()) { stop("The package \"rlang\" is required.") }
  cat("The package \"rlang\" is required.\n✖ Would you like to install it?\n\n1: Yes\n2: No\n\nSelection:")  
  if (readLines(n = 1) == "1"){
      install.packages("rlang")
  }  
}
rlang::check_installed("remotes")
rlang::check_installed("ambhtmx", action = \(pkg, ...) remotes::install_github("jrosell/ambhtmx"))
rlang::check_installed("ambiorix", action = \(pkg, ... ) remotes::install_github("devOpifex/ambiorix"))
rlang::check_installed("scilis", action = \(pkg, ... ) remotes::install_github("devOpifex/scilis"))
rlang::check_installed("tidyverse")
rlang::check_installed("zeallot")
rlang::check_installed("glue")
rlang::check_installed("htmltools")
library(ambhtmx)
library(ambiorix)
library(scilis)
library(tidyverse)
library(zeallot)
library(glue)
library(htmltools)

#' Starting the app
counter <- 1
rexp_data <- c(rexp(1), rexp(1))
c(app, context, operations) %<-% ambhtmx_app()
app$use(scilis(Sys.getenv("AMBHTMX_SECRET")))
app$use(\(req, res){
  cookie <- req$cookie$loggedin  
  req$is_authenticated <- if(is.character(cookie) && cookie == "") { 
    FALSE
  } else if(length(cookie) == 0L) {
    FALSE
  } else if(cookie == Sys.getenv("AMBHTMX_USER")) {
    TRUE
  } else {
    FALSE
  }  
  invisible(NULL)
})

#' Generate a plot from rexp_data
generate_plot <- \(){
  rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
  ggplot(rexp_df, aes(x, y)) + geom_line()
}

#' Main page of the app
app$get("/", \(req, res){  
  if (!req$is_authenticated) {
    res$status <- 302L
    return(res$redirect("/login"))
  }
  rexp_plot <- generate_plot()
  html <- render_page(
    title = "ambiorix + htmx example",
    main = withTags(div(style = "margin: 20px", tagList(
      div(style ="float:right", id = "logout", button("logout", onclick = "void(location.href='/logout')")),
      h1("ambiorix + htmx example"),
      div(id = "counter", withTags(tagList(
          p(glue("Counter is set to {counter}")),
          render_plot(rexp_plot)
      ))),
      button(
        "+1",
        `hx-post`="/increment", `hx-target`="#counter", `hx-swap`="innerHTML"
      ),
      input(
        type = "range",
        id = "slider",
        name = "slider",
        min = 1,
        max = 10,
        value = 1,
        `hx-post`= "/increment_slider",
        `hx-trigger`= "change",
        `hx-target`="#counter",
        `hx-swap`="innerHTML"
      )
    )))
  )
  res$send(html)
})


#' Post call to return the plot
app$post("/increment", \(req, res){
  counter <<- counter + 1
  rexp_data <<- c(rexp_data, rexp(1))
  rexp_plot <- generate_plot()
  res$send(render_tags(
    tags$p(glue("Counter is set to {counter}")),
    render_plot(rexp_plot)
  ))
})

#' Post call to update the plot accordint to the slider
app$post("/increment_slider", \(req, res){
  body <- parse_multipart(req)
  slider_value <- as.integer(body$slider)
  counter <<- counter + slider_value
  rexp_data <<- c(rexp_data, rexp(slider_value))
  rexp_plot <- generate_plot()
  res$send(render_tags(
    tags$p(glue("Counter is set to {counter}")),
    render_plot(rexp_plot)
  ))
})

app$get("/login", \(req, res) {
  error_messages = ""
  print(req$cookie)
  cookie <- req$cookie$error_messages
  if (is.character(cookie) && cookie != "" && length(cookie) > 0){
    error_messages <- req$cookie$error_messages
    res$cookie("error_messages", "")
  }
  html <- render_page(
    title = "Login",
    main = withTags(form(action = "/login", method = "post", enctype = "multipart/form-data", style = "margin: 20px", tagList(
      h1("Login"),
      div(id = "login", withTags(tagList(
        div(label("User", div(input(type = "text", name = "user")))),
        div(label("Password", div(input(type = "password", name = "password")))),
        div(id = "login-response", error_messages)
      ))),
      button(
        "Login"
      )
    )))
  )
  res$send(html)
})

app$post("/login", \(req, res) {  
  params <- parse_multipart(req)  
  error_messages <- c("")

  if (is.null(params$user))
    error_messages <- c("Missing user", error_messages)

  if (!is.null(params$user) && params$user != Sys.getenv("AMBHTMX_USER"))
    error_messages <- c("Invalid user", error_messages)
  
  if (is.null(params$password))
    error_messages <- c("Missing password", error_messages)
  
  if (!is.null(params$password) && params$password != Sys.getenv("AMBHTMX_PASSWORD"))
    error_messages <- c("Invalid password", error_messages)

  if (length(error_messages)>1) {
    res$cookie(
        "error_messages",
        paste0(error_messages[1:length(error_messages)-1], ". ", collapse = "")
    )
    res$status <- 302L
    return(res$redirect("/login"))
  }  
  res$cookie(
      "loggedin",
      params$user,
      path = "/"
  )
  # res$header("HX-Redirect", "http://127.0.0.1:8000/");res$send("")
  res$status <- 302L
  res$redirect("/")
})

app$get("/logout", \(req, res) {    
  res$cookie(
      "loggedin",
      "",
      path = "/"
  )
  res$status <- 302L
  res$redirect("/")
})

#' Start the app with all the previous defined routes
app$start(open = FALSE)
