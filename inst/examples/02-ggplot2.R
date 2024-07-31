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
rexp_data <- rexp(1)
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

#' Post call to return the plot
app$post("/increment", \(req, res){
  counter <<- counter + 1
  rexp_data <<- c(rexp_data, rexp(1))
  rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
  p <- ggplot(rexp_df, aes(x, y)) + geom_line()
  png(p_file <- tempfile(fileext = ".png")); print(p); dev.off()
  p_txt <- b64::encode_file(p_file)    
  res$send(render_tags(
    tags$p(glue("Counter is set to {counter}")),
    tags$img(src = glue("data:image/png;base64,{p_txt}"))
  ))
})

app$start()
