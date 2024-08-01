# ambhtmx

Build a Full-stack R App with ambiorix and htmx.

## Installation

You can install all the requeriments to run the examples:

```
if(!"rlang" %in% installed.packages()){
  if(!interactive()) { stop("The package \"rlang\" is required.") }
  cat("The package \"rlang\" is required.\n✖ Would you like to install it?\n\n1: Yes\n2: No\n\nSelection:")  
  if (readLines(n = 1) == "1"){
      install.packages("rlang")
  }  
}
rlang::check_installed("remotes")
rlang::check_installed("ambhtmx", action = \(pkg, ...) remotes::install_github("jrosell/ambhtmx"))
rlang::check_installed("ambiorix", action = \(pkg, ... ) remotes::install_github("devOpifex/ambiorix"))
rlang::check_installed("scilis", action = \(pkg, ... ) remotes::install_github("devOpifex/scilis"))
rlang::check_installed("signaculum", action = \(pkg, ... ) remotes::install_github("devOpifex/signaculum"))
rlang::check_installed("tidyverse")
rlang::check_installed("zeallot")
rlang::check_installed("glue")
rlang::check_installed("htmltools")
rlang::check_installed("this.path")
```

## Examples

### [Incrementing a counter](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/01-counter.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/01.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/01-counter.R)

### [Updating a ggplot2](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/02-ggplot2.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/02.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/02-ggplot2.R)

### [Interacting with an slider](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/03-slider.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/03.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/03-slider.R)

### [Using SQLite to build a TODO app](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/04-todo.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/04.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/04-todo.R)

### [Live Reloading using npm and nodemon](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/05-live.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/05.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/05-live.R)

### [Single user and password autentication](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/06-basic-auth.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/06.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/06-basic-auth.R)


### [Secure CRUD example with ambhtmx](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/07-crud.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/07.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/07-crud.R)
