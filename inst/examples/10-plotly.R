stop("TODO: render a htmlwidget as in shinyWidgetOutput")
devtools::load_all()
# library(ambhtmx)
library(ggplot2)
library(plotly)



#' Generate a plot from rexp_data
generate_plot <- \(){
  print("generate_plot")
  rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
  ggplot(rexp_df, aes(x, y)) + geom_line()
}

# Rendering plotly htmlwidget
widget_html.default <- function (name, package, id, style, class, inline = FALSE, ...) {
  print("widget_html.default")
  tryCatch(
    {
      if (inline) {
        htmltools::tags$span(id = id, style = style, class = class)
      } else {
        htmltools::tags$div(id = id, style = style, class = class)
      }
    },
    error = \(e) {
      print("error widget_html.default")
      print(e)
    }
  )
}
htmlwidget_lookup_func <- \(name, package) {
  print("htmlwidget_lookup_func")
  tryCatch(
    get(name, asNamespace(package), inherits = FALSE),
    error = function(e) NULL
  )
}
htmlwidget_lookup_widget_html_method <- \(name, package) {
  print("htmlwidget_lookup_widget_html_method")
  tryCatch(
    {
      fn_name <- paste0("widget_html.", name)
      fn <- htmlwidget_lookup_func(fn_name, package)
      if (!is.null(fn)) {
        return(list(fn = fn, name = fn_name, legacy = FALSE))
      }
      fn_name <- paste0(name, "_html")
      fn <- htmlwidget_lookup_func(fn_name, package)
      if (!is.null(fn)) {
        return(list(fn = fn, name = fn_name, legacy = TRUE))
      }
      list(fn = widget_html.default, name = "widget_html.default", legacy = FALSE)
    },
    error = \(e) {
      print("error htmlwidget_lookup_widget_html_method")
      print(e)
    }
  )
}

htmlwidget_widget_html <- \(name, package, id, style, class, inline = FALSE, ...) {
  print("htmlwidget_widget_html")
  tryCatch(
    {
      fn_info <- htmlwidget_lookup_widget_html_method(name, package)
      fn <- fn_info[["fn"]]
      args <- list(id = id, style = style, class = class, ...)
      if ("inline" %in% names(formals(fn))) {
        args$inline <- inline
      }
      fn_res <- do.call(fn, args)
      if (isTRUE(fn_info[["legacy"]])) {
        if (!inherits(fn_res, c("shiny.tag", "shiny.tag.list", "html"))) {
          warning(fn_info[["name"]], " returned an object of class `", class(fn_res)[1],
            "` instead of a `shiny.tag`."
          )
        }
      }
      fn_res
    },
    error = \(e) {
      print("error htmlwidget_widget_html")
      stop(e)
    }
  )
}

render_htmlwidget <- \(
    outputId, name, width, height, package = name,
    inline = FALSE, reportSize = TRUE, reportTheme = FALSE,
    fill = !inline) {
  print("render_htmlwidget")
  tryCatch(
    {
      tag <- htmlwidget_widget_html(
        name, package, id = outputId,
        class = paste0(
          name, " html-widget html-widget-output",
          if (reportSize) " shiny-report-size",
          if (reportTheme) " shiny-report-theme"
        ),
        style = htmltools::css(
          width = htmltools::validateCssUnit(width),
          height = htmltools::validateCssUnit(height),
          display = if (inline) "inline-block"
        ),
        width = width,
        height = height
      )
      tryCatch(
        {
          tag <- htmltools::bindFillRole(tag, item = fill)
        }, error = \(e) {
          print("error bindFillRole")
          print(e)
        }
      )
      tryCatch(
        {
          tag <- htmltools::tagList(tag)
        }, error = \(e) {
          print("error tagList")
          print(e)
        }
      )
      tryCatch(
        {
          dependencies_got <- htmlwidgets::getDependency(name, package)
        }, error = \(e) {
          print("error getDependency")
          print(e)
        }
      )
      tryCatch(
        {
          htmltools::attachDependencies(
            tag, dependencies_got, append = TRUE
          )
        }, error = \(e) {
          print("error attachDependencies")
          print(e)
        }
      )
      
    },
    error = \(e) {
      print("error render_htmlwidget")
      stop(e)
    }
  )
}

render_ggplotly <- \(x) {    
  x |>
    plotly::ggplotly() |> 
    render_htmlwidget(
      outputId = "ggplotly_1",
      name = "ggplotly_name",
      width = 100,
      height = 100
    )
}

counter <- 1
rexp_data <- c(rexp(1), rexp(1))

#' Starting the app
c(app, context, operations) %<-% ambhtmx()


#' Main page of the app
app$get("/", \(req, res){
  tryCatch({
      rexp_plot <- generate_plot()
      div(
          style = "margin: 20px",
          h1("ambiorix + htmx example"),
          div(
            id = "counter",
            p(glue("Counter is set to {counter}")),
            render_ggplotly(rexp_plot)
          ),
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
        ) |> 
        send_page(res, page_title = "ambhtmx slider example"
      )
  },
    error = \(e) print(e)
  )
})


#' Post call to return the plot
app$post("/increment", \(req, res){
  counter <<- counter + 1
  rexp_data <<- c(rexp_data, rexp(1))
  rexp_plot <- generate_plot()
  tagList(
      p(glue("Counter is set to {counter}")),
      render_png(rexp_plot)
    ) |> 
    send_tags(res)
})

#' Post call to update the plot accordint to the slider
app$post("/increment_slider", \(req, res){
  body <- parse_multipart(req)
  slider_value <- as.integer(body$slider)
  counter <<- counter + slider_value
  rexp_data <<- c(rexp_data, rexp(slider_value))
  rexp_plot <- generate_plot()
  tagList(
      p(glue("Counter is set to {counter}")),
      render_png(rexp_plot)
    ) |> 
    send_tags(res)
})

#' Start the app with all the previous defined routes
app$start()
