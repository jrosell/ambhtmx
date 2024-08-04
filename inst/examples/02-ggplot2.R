library(ambhtmx) 
# devtools::load_all()
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
    page_title = "ambhtmx ggplot2 example",
    main = div(
      style = "margin: 20px",
      h1("ambiorix + htmx example"),
      p(id = "counter", glue("Counter is set to {counter}")),
      button(
        "+1",
        `hx-post`="/increment", `hx-target`="#counter", `hx-swap`="innerHTML"
      )
    )
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
