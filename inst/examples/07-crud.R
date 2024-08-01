devtools::load_all()
# library(ambhtmx)
library(ambiorix)
library(scilis)
library(tidyverse)
library(zeallot)
library(glue)
library(htmltools)
library(signaculum)

page_title <- "Secure CRUD example with ambhtmx (ambiorix + htmx)"

live_path <- tryCatch(
  {this.path::this.path()},
  error = function(e) return("")
)

render_items <- \(items) {
  items |>    
    rowwise() |>
    group_split() |> 
    map(\(item) {
      tags$li(        
        tags$a(
          item$name,
          href = glue("/{item$id}"),
          `hx-get`= glue("/{item$id}"),
          `hx-target` = "#main",
          `hx-swap` = "innerHTML"
        )
      )
    })
}
render_item <- \(item) {
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
    live = live_path,
    render_rows = render_items,
    render_row = render_item
  )

#' Authentication feature with secret cookies and .Renviron variables
app$use(scilis(Sys.getenv("AMBHTMX_SECRET")))
app$get("/login", \(req, res) {
  process_login_get(req, res)
})
app$post("/login", \(req, res) {      
  process_login_post(
    req,
    res,
    user = Sys.getenv("AMBHTMX_USER"),
    password = Sys.getenv("AMBHTMX_PASSWORD")
  )
})
app$get("/logout", \(req, res) {
  process_logout_get(req, res)
})
app$use(\(req, res){
  process_loggedin_middleware(
    req,
    res,
    user = Sys.getenv("AMBHTMX_USER")
  )
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

#' Read the index of the items
app$get("/", \(req, res){  
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  index <- p("Add your first item.")
  item_rows <- items$read_rows()
  if(nrow(item_rows) > 0) index <- items$render_rows(item_rows)
  html <- render_page(
      page_title = page_title,
      main = withTags(div(id = "page", style = "margin: 50px",
            div(style ="float:right", id = "logout", button("Logout", onclick = "void(location.href='/logout')")),
            h1(page_title),
            div(id = "main", style = "margin-top: 20px", tagList(
                  h2("Index of items"),
                  index,
                  button(
                    "New item",
                    style = "margin-top:20px",
                    `hx-get` = "/new",
                    `hx-target` = "#main",
                    `hx-swap` = "innerHTML"
                  )
            ))
      ))
  )
  res$send(html)
})


#' New item form
app$get("/new", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  errors <- process_error_get(req, res)
  print("errors")
  print(errors)
  html <- render_tags(withTags(tagList(
      h2("New item"),
      div(label("Name", p(input(name = "name")))),
      div(label("Content", p(textarea(name = "content")))),
      a(
        "Go back",
        href = "/",
        style = "margin-right:20px",
        `hx-confirm` = "Are you sure you want to go back?",
        `hx-get` = "/",
        `hx-target` = "#page",
        `hx-swap` = "outerHTML",
        `hx-encoding` = "multipart/form-data"
      ),      
      button(
        "Create",
        style = "margin-top:20px",
        `hx-post` = "/",
        `hx-target` = "#main",
        `hx-swap` = "innerHTML",
        `hx-include` = "[name='name'], [name='content']",
      ),
      errors
  )))
  res$send(html)
})


#' Show an existing item
app$get("/:id", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""
  item <- items$read_row(id = item_id)   
  html <- render_tags(withTags(tagList(
    h2("Show item details"),
    items$render_row(item),
    a(
      "Go back",
      href = "/",
      style = "margin-right:20px",
      `hx-get` = "/",
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
    ),
    a(
      "Delete",
      href = "/",
      style = "color: red; margin-right:20px",
      `hx-confirm` = "Are you sure you want to delete the item?",
      `hx-delete` = glue("/{item$id}"),
      `hx-target` = "#main",
      `hx-swap` = "innerHTML",
      `hx-encoding` = "multipart/form-data"
    ),
    button(
      "Edit",
      style = "margin-top:20px",
      `hx-get` = glue("/{item_id}/edit"),
      `hx-target` = "#main",
      `hx-swap` = "innerHTML"
    )
  )))
  res$send(html)
})

#' Edit item form
app$get("/:id/edit", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""
  item <- items$read_row(id = item_id)
  html <- render_tags(withTags(tagList(
    h2("Edit item"),
    input(type = "hidden", name = "id", value = item$id),
    div(label("Name", p(input(name = "name", value = item$name)))),
    div(HTML(glue('<textarea rows=5 name="content">{item$content}</textarea>'))),
    a(
      "Go back",
      href = "/",
      style = "margin-right:20px",
      `hx-confirm` = "Are you sure you want to go back?",
      `hx-get` = "/",
      `hx-target` = "#page",
      `hx-swap` = "outerHTML",
      `hx-encoding` = "multipart/form-data"
    ),
    button(
      "Update",
      style = "margin-top:20px",
      `hx-put` = glue("/{item$id}"),
      `hx-target` = "#main",
      `hx-swap` = "innerHTML",
      `hx-include` = "[name='name'], [name='content']",
    )
  )))
  res$send(html)
})

#' Create a new item
app$post("/", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  params <- parse_multipart(req)  
  if (is.null(params[["name"]])) {    
    return(process_error_post(
      req,
      res,
      errors = "Name is required",
      error_url = "/new"
    ))
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
  res$header("HX-redirect", "/")
  res$send("")
})

#' Update an existing item
app$put("/:id", \(req, res){
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
  res$header("HX-redirect", "/")
  res$send("")
})

#' Delete an existing item
app$delete("/:id", \(req, res){
  if (!req$loggedin) {    
    return(res$redirect("/login", status = 302L))
  }
  item_id <- req$params$id %||% ""  
  items$delete_row(id = item_id)
  res$header("HX-redirect", "/")
  res$send("")
})

#' Start the app with all the previous defined routes
app$start(open = FALSE)