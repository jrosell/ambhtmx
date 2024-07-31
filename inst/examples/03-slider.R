#' Loading required packages
library(ambhtmx)
library(ambiorix)
library(tidyverse)
library(zeallot)
library(glue)
library(htmltools)

#' Starting the app
counter <- 1
rexp_data <- c(rexp(1), rexp(1))
c(app, context, operations) %<-% ambhtmx_app()

#' Generate a plot from rexp_data
generate_plot <- \(){
  rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
  ggplot(rexp_df, aes(x, y)) + geom_line()
}

#' Main page of the app
app$get("/", \(req, res){
  rexp_plot <- generate_plot()
  html <- render_page(
    title = "ambiorix + htmx example",
    main = withTags(div(style = "margin: 20px", tagList(
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
        type = "hidden",
        id = "slider_value",
        value = 1
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
        `hx-swap` = "innerHTML",
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

app$start()
