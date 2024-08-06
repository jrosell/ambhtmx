devtools::load_all()
# library(ambhtmx)

page_title <- "ambhtmx tonejs example"

app <- ambhtmx()$app

app$get("/", \(req, res){
 
})

app$start(open = TRUE)
