# stop("TODO: update plotly data with htmx")
# TODO: check plotlyProxy && Plotly["update"].apply(null, [document.getElementById("htmlwidget-*")]);

devtools::load_all()
# library(ambhtmx)
library(ggplot2)
library(plotly)

page_title <- "ambhtmx slider example"

#' Generate a plot from rexp_data
generate_htmlwidget <- \(){
  print("generate_htmlwidget")
  rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
  p_plot <- ggplot(rexp_df, aes(x, y)) + geom_line()
  plotly::ggplotly(p_plot, width = 200, height = 100)  
}

counter <- 1
rexp_data <- c(rexp(1), rexp(1))

#' Starting the app
c(app, context, operations) %<-% ambhtmx()


#' Main page of the app
app$get("/", \(req, res){
  html <- ""
  tryCatch({
      rexp_widget <- generate_htmlwidget()
      rexp_tags <- amb_htmlwidget(rexp_widget, id = "rexp_widget")
      html <- div(
          style = "margin: 20px",
          h1(page_title),
          div(
            id = "counter",
            p(glue("Counter is set to {counter}")),
            rexp_tags
          ),
          button(
            "+1",
            hx_get="/increment",
            hx_target="#counter",
            # hx_target="#rexp_widget [data-for]",
            # hx_target="#debug",
            hx_swap="outerHTML"
          ),
          div(id = "debug")
        ) |> 
        send_page(res)
  },
    error = \(e) print(e)
  )
})

#' Call to return the plot
app$get("/increment", \(req, res){
  counter <<- counter + 1
  rexp_data <<- c(rexp_data, rexp(1))
  rexp_widget <- generate_htmlwidget()
  rexp_tags <- amb_htmlwidget(rexp_widget, id = "rexp_widget")
  div(
      id = "counter",
      p(glue("Counter is set to {counter}")),
      rexp_tags
    ) |> 
    send_tags(res)
})

#' Start the app with all the previous defined routes
app$start(open = FALSE)
