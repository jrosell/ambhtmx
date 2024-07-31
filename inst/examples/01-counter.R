#' Loading required packages
rlang::check_installed("ambhtmx", action = \(pkg, ...) remotes::install_github("jrosell/ambhtmx"))
rlang::check_installed("ambiorix", action = \(pkg, ... ) remotes::install_github("devOpifex/ambiorix"))
rlang::check_installed("tidyverse")
rlang::check_installed("zeallot")
rlang::check_installed("glue")
rlang::check_installed("htmltools")
library(ambhtmx)
library(ambiorix)
library(tidyverse)
library(zeallot)
library(glue)
library(htmltools)

#' Starting the app
counter <- 0
c(app, context, operations) %<-% ambhtmx_app()

#' Main page of the app
app$get("/", \(req, res){
  html <- render_page(
    title = "ambiorix + htmx example",
    main = withTags(div(style = "margin: 20px", tagList(
        h1("ambiorix + htmx example"),
        p(id = "counter", glue("Counter is set to {counter}")),
        button(
          "+1",
          `hx-post`="/increment", `hx-target`="#counter", `hx-swap`="innerHTML"
        )
    )))
  )
  res$send(html)
})

#' Post call to return the value of the global counter variable
app$post("/increment", \(req, res){
  counter <<- counter + 1
  res$send(glue("Counter is set to {counter}"))
})

app$start()