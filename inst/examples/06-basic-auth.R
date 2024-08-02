library(ambhtmx)
# devtools::load_all()
library(ambiorix)
library(tidyverse)
library(zeallot)
library(glue)
library(htmltools)

page_title <- "ambhtmx basic authentication example"

live_path <- tryCatch(
  {this.path::this.path()},
  error = function(e) return("")
)

#' Starting the app
c(app, context, operations) %<-% ambhtmx_app(
  live = live_path
)


#' Authentication feature with secret cookies and .Renviron variables
app$get("/login", \(req, res) {
  process_login_get(req, res)
})
app$post("/login", \(req, res) {      
  process_login_post(
    req,
    res,
    user = Sys.getenv("AMBHTMX_USER"),
    password = Sys.getenv("AMBHTMX_PASSWORD")
  )
})
app$get("/logout", \(req, res) {
  process_logout_get(req, res)
})
app$use(\(req, res){
  process_loggedin_middleware(
    req,
    res,
    user = Sys.getenv("AMBHTMX_USER")
  )
})

#' Generate a plot from rexp_data
counter <- 1
rexp_data <- c(rexp(1), rexp(1))
generate_plot <- \(){
  rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
  ggplot(rexp_df, aes(x, y)) + geom_line()
}

#' Contollers
app$get("/", \(req, res){  
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  hello <- glue("Hello {req$cookie$loggedin}")
  rexp_plot <- generate_plot()
  html <- render_page(
    page_title = "ambhtmx basic authentication example",
    main = withTags(div(style = "margin: 20px", tagList(
      div(style ="float:right", id = "logout", button("Logout", onclick = "void(location.href='/logout')")),
      h1(hello),
      div(id = "counter", withTags(tagList(
          p(glue("Counter is set to {counter}")),
          render_plot(rexp_plot)
      ))),
      button(
        "+1",
        `hx-post`="/increment", `hx-target`="#counter", `hx-swap`="innerHTML"
      )
    )))
  )
  res$send(html)
})

app$post("/increment", \(req, res){
  counter <<- counter + 1
  rexp_data <<- c(rexp_data, rexp(1))
  rexp_plot <- generate_plot()
  res$send(render_tags(
    tags$p(glue("Counter is set to {counter}")),
    render_plot(rexp_plot)
  ))
})

#' Start the app with all the previous defined routes
app$start(open = FALSE)
