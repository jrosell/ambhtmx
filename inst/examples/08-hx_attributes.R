library(ambhtmx) # devtools::load_all()

app <- ambhtmx_app()$app

app$get("/", \(req, res) {
  div(
      id = "main",
      style = "margin: 20px",
      p("This is the home page"),
      div(
        button("Go to item 1", hx_get = "/item/1", hx_target = "#main", hx_swap = "innerHTML"),
        button("Go to item 2", hx_get = "/item/2", hx_target = "#main", hx_swap = "innerHTML")
      )
    ) |> 
    send_page(res)
})

app$get("/item/1", \(req, res) {
  tagList(
      p("This is item 1"),
      div(
        button("Go to item 2", hx_get = "/item/2", hx_target = "#main", hx_swap = "innerHTML"),
        button("Go to the home page",hx_get = "/", hx_target = "#main", hx_swap = "outerHTML")
      )
    ) |>
    send_page(res)
})

app$get("/item/2", \(req, res) {
  tagList(
      p("This is item 2"),
      div(
        button("Go to item 1", hx_get = "/item/1", hx_target = "#main", hx_swap = "innerHTML"),    
        button("Go to the home page", hx_get = "/", hx_target = "#main", hx_swap = "outerHTML")
      )
    ) |>
    send_page(res)
})

app$start()

