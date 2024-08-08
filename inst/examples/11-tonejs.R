# devtools::load_all()
library(ambhtmx)

live_path <- tryCatch(
  {this.path::this.path()},
  error = function(e) return("")
)

page_title <- "ambhtmx tonejs example"

head_tags <- htmltools::tagList(      
  tags$link(href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css", rel = "stylesheet", integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH",  crossorigin="anonymous"),
  tags$script(src = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js", integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz", crossorigin="anonymous"),
  htmltools::HTML('<script src="https://cdn.jsdelivr.net/gh/gnat/surreal@main/surreal.js"></script><script src="https://cdn.jsdelivr.net/gh/gnat/css-scope-inline@main/script.js"></script>'),
  htmltools::HTML('<script src="http://unpkg.com/tone"></script>'),
  htmltools::HTML('<style>input[type="radio"] {margin: 0 5px 0 20px}</style>')
)

amb_tonejs <- \(
      id,
      button_text,
      pitch_name,
      pitch_octave,
      duration_value,
      duration_unit,
      duration_dotted = ""
    ) {
  pitch <- paste0(pitch_name, pitch_octave, collapse = "")
  dotted <- if (!is.null(duration_dotted)) { "." } else { "" }
  duration <- paste0(duration_value, duration_unit, dotted, collapse = "")
  script_chr <- paste0('
    document.querySelector("#', id, '")?.addEventListener("click", async () => {
        const synth = new Tone.Synth().toDestination();
        synth.triggerAttackRelease("', pitch, '", "', duration, '");
        await Tone.start();
        console.log("audio is ready");
     });',
     collapse = ""
  )
  div(
    class = paste0("amb_tonejs ", id),
    style = "margin : 10px; float: left;",    
    button(id = id, button_text),         
    script(HTML(script_chr)),    
    a("x", style = "color: red; text-decoration: none", href="#", hx_delete="/delete", hx_confirm = glue('Are you sure you want to delete "{button_text}"?'), hx_swap = "outerHTML", hx_target = glue(".{id}"))
  )
}

app <- ambhtmx(live = live_path)$app$
  get("/", \(req, res){  
    div(
      id = "page", style = "margin: 20px", h1(page_title),
      div(id = "main",
        div(
          style ="margin-bottom: 10px",
          span("Pitch name", div(
            label(input(name = "pitch_name", type = "radio", value = "A", "A", checked = "checked")),
            label(input(name = "pitch_name", type = "radio", value = "B", "B")),
            label(input(name = "pitch_name", type = "radio", value = "C", "C")),
            label(input(name = "pitch_name", type = "radio", value = "D", "D")),
            label(input(name = "pitch_name", type = "radio", value = "E", "E")),
            label(input(name = "pitch_name", type = "radio", value = "F", "F"))
          ))
        ),
        div(
          style ="margin-bottom: 10px",
          label("Pitch octave", div(
            input(name = "pitch_octave", type = "range", min = 0, max = 9, value = 4)
          ))
        ),
        div(
          style ="margin-bottom: 10px",
          label("Duration value", div(
            input(name = "duration_value", type = "range", min = 0.25, max = 8, step = 0.25, value = 0.25)
          ))
        ),
        div(
          style ="margin-bottom: 10px",
          span("Duration unit", div(
            label(input(name = "duration_unit", type = "radio", value = "n", "note", checked = "checked")),
            label(input(name = "duration_unit", type = "radio", value = "t", "triplet")),
            label(input(name = "duration_unit", type = "radio", value = "m", "measures"))
          ))
        ),
        div(
          style ="margin-bottom: 10px",
          label(
            input(name = "duration_dotted", type = "checkbox", value = "."),
            "Duration dotted",
          )
        ),
        div(
          style = "margin: 10px",
          button(
            "Add",
            style = "margin-right: 20px",
            hx_post = "/add",
            hx_include = '[name="pitch_name"], [name="pitch_octave"], [name="duration_value"],[name="duration_unit"], [name="duration_dotted"]',
            hx_vals = 'js:{id: document.querySelectorAll(".amb_tonejs").length + 1}',
            hx_target = "#list",
            hx_swap = "beforeend"
          ),
          button(
            "Reset",
            hx_delete = "/delete",
            hx_target = "#list",
            hx_swap = "innerHTML",
            hx_confirm = glue('Are you sure you want to reset all the notes?')
          )
        ),
        div(
          id = "list",
          amb_tonejs(
            id = "amb_tonejs_1",
            "Play c4 for 4n",
            pitch_name = 'c',
            pitch_octave = '4',
            duration_value = 4,
            duration_unit = 'n'
          ),
          amb_tonejs(
            id = "amb_tonejs_2",
            "Play c5 for 8n",
            pitch_name = 'c',
            pitch_octave = '5',
            duration_value = 8,
            duration_unit = 'n'
          )
        )
      )
    ) |>
    send_page(res)
  })$
  post("/add", \(req, res) {
    tryCatch(
      {
        params <- parse_multipart(req)
        print(params)
        amb_tonejs_id <- paste0("amb_tonejs_", params$id, collapse = "")
        pitch <- paste0(params$pitch_name, params$pitch_octave, collapse = "")
        dotted <- if (!is.null(params$duration_dotted)) { "." } else { "" }
        duration <- paste0(params$duration_value, params$duration_unit, dotted, collapse = "")
        text <- glue("Play {pitch} for {duration}")
        html_tags <- amb_tonejs(
          id = amb_tonejs_id,
          glue("Play {pitch} for {duration}"),
          pitch_name = params$pitch_name,
          pitch_octave = params$pitch_octave,
          duration_value = params$duration_value,
          duration_unit = params$duration_unit,
          duration_dotted = params$duration_dotted
        ) |> 
        send_tags(res)
      },
      error = \(e) {
        print(e)
        res$send("Error")
      }
    )
  })$
  delete("/delete", \(req, res) {
    res$send("")
  })

app$start(open = FALSE)


