# TODO: Use websockets to refresh the HTML page when R server is restarted.
# TODO: Detect if the script is run from nodemon or not.

library(ambhtmx) 
# devtools::load_all()


live_path <- tryCatch(
  {this.path::this.path()},
  error = function(e) return("")
)


#' Starting the app
counter <- 0
c(app, context, operations) %<-% ambhtmx_app(live = live_path)


#' Main page of the app
app$get("/", \(req, res){
  html <- render_page(
    page_title = "ambiorix + htmx example",
    main = div(
      style = "margin: 100px", 
      h1("ambhtmx live hot realoading example"),
      p(id = "counter", glue("Counter is set to {counter}")),
      button(
        "+1",
        `hx-post`="/increment", `hx-target`="#counter", `hx-swap`="innerHTML"
      )
    )
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
