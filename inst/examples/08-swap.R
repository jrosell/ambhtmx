library(ambhtmx)

app <- ambhtmx_app()$app

render_index <- \(){
  tagList(
    tags$p("This is the home page"),
    tags$a("Go to item 1", `hx-get` = "/item/1", `hx-target` = "#main", `hx-swap` = "innerHTML"),    
    tags$a("Go to item 2", `hx-get` = "/item/2", `hx-target` = "#main", `hx-swap` = "innerHTML")
  )
}
app$get("/", \(req, res) {
  tags$div(
      id = "main",
      render_index()
    ) |> 
    render_page()
    res$send()
})

# app$get("/item/1", \(req, res) {
#   tagList(
#       tags$p("This is item 1"),
#       tags$a("Go to item 2", `hx-get` = "/item/1", `hx-target` = "#main", `hx-swap` = "innerHTML"),      
#       tags$a("Go to the home page", `hx-get` = "/", `hx-target` = "#main", `hx-swap` = "outerHTML")
#     ) |> 
#     render_page() |> 
#     res$send()
# })

# app$get("/item/2", \(req, res) {
#   tagList(
#       tags$p("This is item 2"),
#       tags$a("Go to item 1", `hx-get` = "/item/2", `hx-target` = "#main", `hx-swap` = "innerHTML"),      
#       tags$a("Go to the home page", `hx-get` = "/", `hx-target` = "#main", `hx-swap` = "outerHTML")
#     ) |> 
#     render_page() |> 
#     res$send()
# })

app$start()