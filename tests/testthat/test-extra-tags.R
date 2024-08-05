test_that('style_tpl_css_vars_replace works tpl_replace for one tpl variable', {
  result <- style_tpl_css_vars_replace("me { background: var(--tpl-bgurl) center}", bgurl = "url(/icon.png)")
  expected <- "me { background: url(/icon.png) center}"
  expect_equal(result, expected)
})

test_that('style_tpl_css_vars_replace works tpl_replace for two tpl variables', {
  result <- style_tpl_css_vars_replace("me { background: var(--tpl-bgurl) var(--tpl-align)}", bgurl = "url(/icon.png)", align = "left")
  expected <- "me { background: url(/icon.png) left}"
  expect_equal(result, expected)
})

test_that('style_from_css_tpl works', {
  result <- withr::with_tempfile("temp_css_file", {
    writeLines("me { background: var(--tpl-bgurl) center}", temp_css_file)
    as.character(style_from_css_tpl(temp_css_file, bgurl = "url(/icon.png)"))
  })
  expected <- "<style> me { background: url(/icon.png) center}\n </style>"
  expect_equal(result, expected)
})

test_that('script_tpl_js_vars_replace works', {
  result <- script_tpl_js_vars_replace("amt = {amt}", amt = "1.5")
  expected <- "amt = 1.5"
  expect_equal(result, expected)
})
