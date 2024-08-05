# devtools::load_all()
library(ambhtmx) 

#' Starting the app
counter <- 0
c(app, context, operations) %<-% ambhtmx("todo.sqlite", value = tibble(
  id = character(1), item = character(1), status = integer(1)
))
data_add <- operations$add_row
data_read <- operations$read_rows
data_update <- operations$update_row
data_delete <- operations$delete_row

#' Add and edit todo form
todo_form <- \(item_id = NULL, item_value = "", type = "add") {
  tryCatch(
    {
      add <- identical(type, "add")
      form(
        `hx-target` = "#todo_items",
        `hx-swap` = "innerHTML",
        `hx-post` = if (add) "/add_todo" else paste0("/edit_todo/", item_id),
        `hx-on::after-request` = "this.reset()",
        div(
          class = "input-group d-flex",
          amb_input_text(
            id = "name",
            class = "flex-grow-1",
            input_class = "rounded-end-0",
            value = item_value,
            aria_label = "Todo item"
          ),
          amb_button(
            type = "submit",
            id = "add_btn", 
            class = "btn",
            if (add) "+" else "ok"
          )
        )
      )
    },
    error = \(e) print(e)
  )
}

#' Show all the items
todo_index <- \(items) {
  tryCatch(
    {
      if (nrow(items) == 0L) {
        return(
          p(
            class = "text-center card-title",
            "✨ No todo items yet. Add one! ✨"
          )
        )
      }
      list_items <- 
        items |> 
        mutate(item = Map(todo_row, item, id, status))  
      ul(
        class = "list-group",
        list_items$item
      )
    },
    error = \(e) print(e)
  )
}

#' Show one item
todo_row <- \(the_item, the_id, the_status) {
  tryCatch(
    {
      li(
        class = paste(
          "list-group-item",
          if (the_status) "list-group-item-success"
        ),
        div(
          class = "d-flex justify-content-between align-items-end",
          div(
            input(
              type = "checkbox",
              value = "",
              id = the_id,
              name = "item_id",
              value = the_id,
              checked = if (the_status) NA else NULL,
              `hx-put` = paste0("/check_todo/", the_id)
            ),
            label(
              class = paste(
                "form-check-label",
                if (the_status) "text-decoration-line-through"
              ),
              `for` = the_id,
              the_item
            )
          ),
          div(
            class = "btn-group",
            role = "group",
            `aria-label` = "Action buttons",
            amb_button(
              class = "btn btn-outline-primary btn-sm border-0",
              `hx-get` = paste0("/edit_todo/form/", the_id),
              `hx-target` = "closest .list-group-item",
              "Edit"
            ),
            amb_button(
              class = "btn btn-outline-danger btn-sm border-0",
              `hx-delete` = paste0("/delete_todo/", the_id),
              "x"
            )
          )
        )
      )
    },
    error = \(e) print(e)
  )
}

#' Listing all the todos
app$get("/", \(req, res){
  tryCatch(
    {
      send_page(
        res,
        page_title = "ambhtmx todo example",
        main = div(
          style = "margin: 20px", 
          h1("ambhtmx todo example"),
          div(
            class = "container small-container",
            amb_card(
              class = "my-3",
              title = "Get Things Done!",
              title_class = "text-center",
              title_icon = HTML('<i class="bi bi-app-indicator"></i>'),
              todo_form()
            ),
            amb_card(
              class = "my-3",
              div(
                id = "todo_items",
                `hx-target` = "this",
                `hx-swap` = "innerHTML",
                todo_index(data_read())
              )
            )
          )
        )
      )
    },
    error = \(e) print(e)
  )
})

#' Create a todo
app$post("/add_todo", \(req, res) {
  tryCatch(
    {
      body <- parse_multipart(req)
      item <- body$name %||% ""
      is_valid <- !identical(item, "")
      if (is_valid) {
        data_add(value = tibble(item = item, status = 0))
      }
      data_read() |> 
        todo_index() |> 
        send_tags(res)
    },
    error = \(e) print(e)
  )
})

#' Show the fort to edit a todo
app$get("/edit_todo/form/:id", \(req, res) {
  tryCatch(
    {
      body <- parse_multipart(req)
      item_id <- req$params$id %||% ""
      item_value <- data_read() |> filter(id == item_id) |> pull(item)
      todo_form(
          item_id = item_id,
          item_value = item_value,
          type = "edit"
        ) |> 
        send_tags(res)      
    },
    error = \(e) print(e)
  )
})


#' Update a todo
app$post("/edit_todo/:id", \(req, res) {
  tryCatch(
    {
      item_id <- req$params$id %||% ""
      body <- parse_multipart(req)
      item_value <- body$name %||% ""
      is_valid <- !identical(item_id, "") && !identical(item_value, "")
      if (is_valid) {
        data_update(value = tibble(id = item_id, item = item_value, status = 0)) 
      }
      data_read() |> 
        todo_index() |> 
        send_tags(res)
    },
    error = \(e) print(e)
  )
})


#' Check a todo
app$put("/check_todo/:id", \(req, res) {
  tryCatch(
    {
      item_id <- req$params$id %||% ""
      is_valid <- !identical(item_id, "")
      if (is_valid) {    
        status_value <- data_read() |> filter(id == item_id) |> pull(status) |> 
          as.logical()
        data_update(value = tibble(id = item_id, status = as.integer(!status_value)))
      }
      data_read() |> 
        todo_index() |> 
        send_tags(res)
    },
    error = \(e) print(e)
  )
})

#' Delete a todo
app$delete("/delete_todo/:id", \(req, res) {
  tryCatch(
    {
      item_id <- req$params$id %||% ""
      is_valid <- !identical(item_id, "")
      if (is_valid) {    
        data_delete(value = tibble(id = item_id))
      }
      data_read() |> 
        todo_index() |> 
        send_tags(res)
    },
    error = \(e) print(e)
  )
})


#' Start the app with all the previous defined routes
app$start()
