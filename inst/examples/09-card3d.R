library(ambhtmx)
# devtools::load_all()

card_3d_demo <- \() {  
  # Original python code credit: https://fastht.ml/
  # Design credit: https://codepen.io/markmiro/pen/wbqMPa
  bgurl <- "https://ucarecdn.com/35a0e8a7-fcc5-48af-8a3f-70bb96ff5c48/-/preview/750x1000/"
  card_js <- here::here('inst', 'examples', '09-card3d.js')
  card_css <- here::here('inst', 'examples', '09-card3d.css')  
  card_styles <- "font-family: 'Arial Black', 'Arial Bold', Gadget, sans-serif; perspective: 1500px;"
  card_3d <- \(text, bgurl, amt, left_align) {
    align <- ifelse(left_align, 'left', 'right')
    scr <- script_from_js_tpl(card_js, amt = amt)	      
    sty <- style_from_css_tpl(
      card_css, bgurl = glue('url({bgurl})'), align = align
    )   
    return(div(text, div(), scr, sty, align = align))
  }
  card <- card_3d("Mouseover me", bgurl, amt = 1.5, left_align = T)
  div(card, style = card_styles)
}

app <- ambhtmx_app()$app

app$get("/", \(req, res) {
  card_3d_demo() |> send_page(res)
})

app$start()
