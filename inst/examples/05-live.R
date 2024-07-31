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
c(app, context, operations) %<-% ambhtmx_app(live = this.path::this.path())

#' Main page of the app
app$get("/", \(req, res){
  html <- render_page(
    title = "ambiorix + htmx example",
    main = withTags(div(style = "margin: 100px", tagList(
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

#' Start the app with all the previous defined routes
app$start(open = FALSE)