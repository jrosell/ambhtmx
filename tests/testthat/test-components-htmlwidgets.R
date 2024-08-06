# devtools::load_all()
library(ggplot2)
library(plotly)
counter <- 2
rexp_data <- c(rexp(counter), rexp(counter))  
rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
x_ggplot <- ggplot(rexp_df, aes(x, y)) + geom_line()
x_plotly <- plotly::ggplotly(x_ggplot)

test_that("plotly generates htmlwidget", {
  result <- class(x_plotly)
  expected <- c("plotly", "htmlwidget")
  expect_equal(result, expected)
})

test_that("amb_htmlwidget can generate a shiny.tag from a htmlwidget" , {
  result <- class(amb_htmlwidget(x_plotly))  
  expected <- "shiny.tag"
  expect_equal(result, expected)
})


# test_that("amb_htmlwidget_data can generate a new script tag from an existing htmlwidget" , {
#   first_widget  <- amb_htmlwidget(x_plotly)
#   counter <- counter + 1
#   rexp_data <- c(rexp(counter), rexp(counter))  
#   rexp_df <- tibble(x = 1:length(rexp_data), y = rexp_data)
#   x_ggplot <- ggplot(rexp_df, aes(x, y)) + geom_line()
#   x_plotly <- plotly::ggplotly(x_ggplot)
#   second_script
#   str_replace(script_chr, "htmlwidget-[^\"]+", new_id)

#   print(script_chr)
#   # result <- class(r)
#   #expected <- "shiny.tag"
#   # expect_equal(result, expected)# 
# })
