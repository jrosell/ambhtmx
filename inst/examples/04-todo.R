devtools::load_all()
# library(ambhtmx)
library(ambiorix)
library(scilis)
library(tidyverse)
library(zeallot)
library(glue)
library(htmltools)

#' Starting the app
counter <- 0
c(app, context, operations) %<-% ambhtmx_app("todo.sqlite", value = tibble(
  id = character(1), item = character(1), status = integer(1)
))
data_add <- operations$add_row
data_read <- operations$read_rows
data_update <- operations$update_row
data_delete <- operations$delete_row

#' Some todo functions
todo_page <- \(items) {
  tagList(
    tags$div(
      class = "container small-container",
      create_card(
        class = "my-3",
        title = "Get Things Done!",
        title_class = "text-center",
        todo_form()
      ),
      create_card(
        class = "my-3",
        tags$div(
          id = "todo_items",
          `hx-target` = "this",
          `hx-swap` = "innerHTML",
          create_todo_list(items)
        )
      )
    )
  )
}
create_card <- \(
  ...,
  id = NULL,
  class = NULL,
  title = NULL,
  title_icon = NULL,
  title_class = NULL,
  footer = NULL
) {
  tags$div(
    class = paste("card p-1 p-md-4 border-0", class),
    tags$div(
      class = "card-body",
      if (!is.null(title) || !is.null(title_icon)) {
        tags$h3(
          class = paste("card-title spectral-bold fs-4 mb-3", title_class),
          title_icon,
          title
        )
      },
      ...
    )
  )
}
todo_form <- \(item_id = NULL, item_value = "", type = "add") {
  add <- identical(type, "add")
  tags$form(
    `hx-target` = "#todo_items",
    `hx-swap` = "innerHTML",
    `hx-post` = if (add) "/add_todo" else paste0("/edit_todo/", item_id),
    `hx-on::after-request` = "this.reset()",
    tags$div(
      class = "input-group d-flex",
      text_input(
        id = "name",
        class = "flex-grow-1",
        input_class = "rounded-end-0",
        value = item_value,
        aria_label = "Todo item"
      ),
      create_button(
        type = "submit",
        id = "add_btn",
        class = "btn",
        if (add) "+" else "ok"
      )
    )
  )
}
create_todo_list <- \(items) {
  if (nrow(items) == 0L) {
    return(
      tags$p(
        class = "text-center card-title",
        "✨ No todo items yet. Add one! ✨"
      )
    )
  }
  list_items <- 
    items |> 
    mutate(item = create_list_item(item, id, status))  
  tags$ul(
    class = "list-group",
    list_items$item
  )
}
create_list_item <- \(item, id, status) {
  Map(
    f = \(the_item, the_id, the_status) {
      tags$li(
        class = paste(
          "list-group-item",
          if (the_status) "list-group-item-success"
        ),
        tags$div(
          class = "d-flex justify-content-between align-items-end",
          tags$div(
            tags$input(
              type = "checkbox",
              value = "",
              id = the_id,
              name = "item_id",
              value = the_id,
              checked = if (the_status) NA else NULL,
              `hx-put` = paste0("/check_todo/", the_id)
            ),
            tags$label(
              class = paste(
                "form-check-label",
                if (the_status) "text-decoration-line-through"
              ),
              `for` = the_id,
              the_item
            )
          ),
          tags$div(
            class = "btn-group",
            role = "group",
            `aria-label` = "Action buttons",
            create_button(
              class = "btn btn-outline-primary btn-sm border-0",
              `hx-get` = paste0("/edit_todo/form/", the_id),
              `hx-target` = "closest .list-group-item",
              "Edit"
            ),
            create_button(
              class = "btn btn-outline-danger btn-sm border-0",
              `hx-delete` = paste0("/delete_todo/", the_id),
              "x"
            )
          )
        )
      )
    },
    item,
    id,
    status
  )
}
text_input <- \(
  ...,
  id,
  label = NULL,
  value = "",
  input_class = NULL,
  hx_post = NULL
) {
  tags$div(
    class = "mb-3",
    `hx-target` = "this",
    `hx-swap` = "outerHTML",
    tags$label(
      `for` = id,
      class = "form-label",
      label
    ),
    tags$input(
      type = "text",
      name = id,
      id = id,
      class = paste("form-control", input_class),
      required = NA,
      value = value,
      `hx-post` = hx_post
    ),
    ...
  )
}
create_button <- \(..., class = "rounded-1", type = "button") {
  tags$button(
    type = type,
    class = class,
    ...
  )
}


#' Listing all the todos
app$get("/", \(req, res){
  todos <- data_read(context = context)
  html <- render_page(
    page_title = "ambhtmx todo example",
    main = withTags(div(style = "margin: 20px", tagList(
      h1("ambhtmx todo example"),
      todo_page(items = data_read(context = context))
    )))
  )
  res$send(html)
})

#' Create a todo
app$post("/add_todo", \(req, res) {
  body <- parse_multipart(req)
  item <- body$name %||% ""
  is_valid <- !identical(item, "")
  if (is_valid) {
    data_add(context = context, value = tibble(item = item, status = 0))
  }
  html <- create_todo_list(data_read(context = context))
  res$send(html)
})

#' Show the fort to edit a todo
app$get("/edit_todo/form/:id", \(req, res) {
  body <- parse_multipart(req)
  item_id <- req$params$id %||% ""
  item_value <- data_read(context = context) |> filter(id == item_id) |> pull(item)
  html <- todo_form(
    item_id = item_id,
    item_value = item_value,
    type = "edit"
  )
  res$send(html)
})


#' Update a todo
app$post("/edit_todo/:id", \(req, res) {
  item_id <- req$params$id %||% ""
  body <- parse_multipart(req)
  item_value <- body$name %||% ""
  is_valid <- !identical(item_id, "") && !identical(item_value, "")
  if (is_valid) {
    data_update(context = context, value = tibble(id = item_id, item = item_value, status = 0)) 
  }
  html <- create_todo_list(data_read(context = context))
  res$send(html)
})


#' Check a todo
app$put("/check_todo/:id", \(req, res) {
  item_id <- req$params$id %||% ""
  is_valid <- !identical(item_id, "")
  if (is_valid) {    
    status_value <- data_read(context = context) |> filter(id == item_id) |> pull(status) |> 
      as.logical()
    data_update(context = context, value = tibble(id = item_id, status = as.integer(!status_value)))
  }
  html <- create_todo_list(data_read(context = context))
  res$send(html)
})

#' Delete a todo
app$delete("/delete_todo/:id", \(req, res) {
  item_id <- req$params$id %||% ""
  is_valid <- !identical(item_id, "")
  if (is_valid) {    
    data_delete(context = context, value = tibble(id = item_id))
  }
  html <- create_todo_list(data_read(context = context))
  res$send(html)
})


#' Start the app with all the previous defined routes
app$start()
