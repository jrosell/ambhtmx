library(ambhtmx)
# devtools::load_all() 

page_title <- "Password protected CRUD (Create, Read, Update, and Delete) example with ambhtmx"

render_index <- \() {
  main <- NULL
  tryCatch({
      index <- p("Add your first item.")
      item_rows <- items$read_rows()
      if(nrow(item_rows) > 0) {
        index <- item_rows |>    
          rowwise() |>
          group_split() |> 
          map(\(item) {
            tags$li(        
              tags$a(
                item$name,
                href = glue("/items/{item$id}"),
                `hx-get`= glue("/items/{item$id}"),
                `hx-target` = "#main",
                `hx-swap` = "innerHTML"
              )
            )
          })
      }
      main <- div(id = "page", style = "margin: 50px",
          div(style ="float:right", id = "logout", button("Logout", onclick = "void(location.href='/logout')")),
          h1(page_title),
          div(id = "main", style = "margin-top: 20px", tagList(
                h2("Index of items"),
                index,
                button(
                  "New item",
                  style = "margin-top:20px",
                  `hx-get` = "/items/new",
                  `hx-target` = "#main",
                  `hx-swap` = "innerHTML"
                )
          ))
      )
    },
    error = \(e) print(e)
  )
  return(main)
}

render_new <- \(req, res) {
  errors <- process_error_get(req, res)
  render_tags(tagList(
    h2("New item"),
    div(label("Name", p(input(name = "name")))),
    div(label("Content", p(textarea(name = "content")))),
    a(
      "Go back",
      href = "/",
      style = "margin-right:20px",
      `hx-confirm` = "Are you sure you want to go back?",
      `hx-get` = "/items",
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
      `hx-encoding` = "multipart/form-data"
    ),      
    button(
      "Create",
      style = "margin-top:20px",
      `hx-post` = "/items",
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
      `hx-include` = "[name='name'], [name='content']",
    ),
    errors
  ))
}

render_row <- \(item) {
  tags$div(    
    tags$strong(item$name),
    tags$br(),
    HTML(item$content)
  )
}

#' Starting the app
counter <- 0
c(app, context, items) %<-%
  ambhtmx_app(
    "items.sqlite",
    value = tibble(
      id = character(1),
      name = character(1),
      content = character(1)
    ),
    render_index = render_index,
    render_row = render_row
  )

#' Authentication feature with secret cookies and .Renviron variables
app$get("/login", \(req, res) {
  process_login_get(req, res)
})
app$post("/login", \(req, res) {      
  process_login_post(req, res)
})
app$get("/logout", \(req, res) {
  process_logout_get(req, res)
})
app$use(\(req, res){
  process_loggedin_middleware(req, res)
})

#' Some CRUD operations examples
cat("\nBe sure is initially empty:\n")
walk(items$read_rows()$id, \(x) items$delete_row(id = x))
items$read_rows() |> print()

cat("\nAdd some items:\n")
tibble(name = "Elis elis", content = "Putxinelis.",) |> 
  items$add_row() -> first_id
tibble(name = "Que bombolles", content = "T\'empatolles.") |> 
  items$add_row() -> some_id
tibble(name = "Holi", content = "Guapi.") |> 
  items$add_row() -> last_id
items$read_rows() |> print()

cat("\nDelete last item:\n")
items$delete_row(id = last_id)
items$read_rows() |> print()

cat("\nUpdate first items:\n")
tibble(name = "First", content = "Hello in <span style='color:red'>red</span>.") |>
  items$update_row(id = first_id)
items$read_rows() |> print()

cat("\nRender the first item:\n")
items$read_row(id = first_id) |> 
  items$read_row() |> 
  as.character() |> 
  cat()

cat("\nAdd an item with id 1:\n")
tibble(id = "1", name = "Quines postres", content = "Tant bones.") |>
  items$add_row()
items$read_rows() |> print()


#' The main page
app$get("/", \(req, res){  
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  html <- ""  
  tryCatch({
      html <- render_page(
          page_title = page_title,
          main = items$render_index()
      )
    },
    error = \(e) print(e)
  )
  res$send(html)
})

#' Read the index of the items
app$get("/items", \(req, res){  
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  res$send(items$render_index())
})

#' New item form
app$get("/items/new", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  tryCatch({
      html <- render_new(req, res)
    },
    error = \(e) print(e)
  )  
  res$send(html)
})


#' Show an existing item
app$get("/items/:id", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""
  item <- items$read_row(id = item_id)   
  html <- render_tags(tagList(
    h2("Show item details"),
    items$render_row(item),
    a(
      "Go back",
      href = "/",
      style = "margin-right:20px",
      `hx-get` = "/items",
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
    ),
    a(
      "Delete",
      href = "/",
      style = "color: red; margin-right:20px",
      `hx-confirm` = "Are you sure you want to delete the item?",
      `hx-delete` = glue("/items/{item$id}"),
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
      `hx-encoding` = "multipart/form-data"
    ),
    button(
      "Edit",
      style = "margin-top:20px",
      `hx-get` = glue("/items/{item_id}/edit"),
      `hx-target` = "#main",
      `hx-swap` = "innerHTML"
    )
  ))
  res$send(html)
})

#' Edit item form
app$get("/items/:id/edit", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""
  item <- items$read_row(id = item_id)
  html <- render_tags(tagList(
    h2("Edit item"),
    input(type = "hidden", name = "id", value = item$id),
    div(label("Name", p(input(name = "name", value = item$name)))),
    div(HTML(glue('<textarea rows=5 name="content">{item$content}</textarea>'))),
    a(
      "Go back",
      href = "/",
      style = "margin-right:20px",
      `hx-confirm` = "Are you sure you want to go back?",
      `hx-get` = "/items",
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
      `hx-encoding` = "multipart/form-data"
    ),
    button(
      "Update",
      style = "margin-top:20px",
      `hx-put` = glue("/items/{item$id}"),
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
      `hx-include` = "[name='name'], [name='content']",
    )
  ))
  res$send(html)
})


#' Create a new item
app$post("/items", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  params <- parse_multipart(req)  
  if (is.null(params[["name"]])) {    
    error_message <- "Name is required."
    res$cookie(
      name = "errors",
      value = error_message
    )

    res$header("HX-Retarget", "#main")
    res$header("HX-Retarget", "#main")
    res$header("HX-Reswap", "innerHTML")
    print("Retarget amb error")
    return(res$send(render_new(req, res)))
  }
  if (is.null(params[["content"]])) {
    params[["content"]] = ""
  }
  tryCatch({
      params |> 
        as_tibble() |>
        items$add_row()
    }, 
    error = \(e) print(e)
  )    
  res$send(items$render_index())
})

#' Update an existing item
app$put("/items/:id", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""  
  params <- parse_multipart(req) |> 
    as_tibble() |> 
    mutate(id = item_id)
  item <- items$read_row(id = item_id)  
  tryCatch({
      item |>
        dplyr::rows_upsert(params, by = "id") |>
        items$update_row()    
    }, 
    error = \(e) print(e)
  )
  res$send(items$render_index())
})

#' Delete an existing item
app$delete("/items/:id", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""  
  items$delete_row(id = item_id)
  res$send(items$render_index())
})

#' Start the app with all the previous defined routes
app$start(open = FALSE)