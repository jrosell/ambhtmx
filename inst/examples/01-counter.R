library(ambhtmx)
# devtools::load_all()

#' Starting the app
counter <- 0
tryCatch({
    c(app, context, operations) %<-% ambhtmx_app()
  },
  error = \(e) print(e)
)

#' Main page of the app
app$get("/", \(req, res){
  html <- ""
  tryCatch(
    {
      html <- render_page(
        page_title = "ambhtmx counter example",
        main = div(
            style = "margin: 20px", 
            h1("ambhtmx counter example"),
            p(id = "counter", glue("Counter is set to {counter}")),
            button(
              "+1",
              `hx-post`="/increment", `hx-target`="#counter", `hx-swap`="innerHTML"
            )
        )
      )
    },
    error = \(e) html <- p(e)
  )
  res$send(html)
})

#' Post call to return the value of the global counter variable
app$post("/increment", \(req, res){
  counter <<- counter + 1
  res$send(glue("Counter is set to {counter}"))
})

#' Start the app with all the previous defined routes
app$start()