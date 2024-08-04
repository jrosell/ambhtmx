<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- badges: end -->

**THIS IS A WORK IN PROGRESS, DO NOT USE**

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
remotes::install_github("jrosell/ambhtmx", force = 1)
rlang::check_installed("ambiorix", action = \(pkg, ... ) remotes::install_github("devOpifex/ambiorix"))
rlang::check_installed("scilis", action = \(pkg, ... ) remotes::install_github("devOpifex/scilis"))
rlang::check_installed("signaculum", action = \(pkg, ... ) remotes::install_github("devOpifex/signaculum"))
rlang::check_installed("tidyverse")
rlang::check_installed("zeallot")
rlang::check_installed("glue")
rlang::check_installed("htmltools")
rlang::check_installed("this.path")
```

Furthermore, you may want to create a .Renviron file with the following variables:

```
AMBHTMX_USER=<your user>
AMBHTMX_PASSWORD=<your password>
AMBHTMX_SECRET=<a secret key to make cookies safer>
GITHUB_PAT=<an optional token to install github repos safely>
AMBHTMX_PROTOCOL=<to change host default http>
AMBHTMX_HOST=<to change host default 127.0.0.1>
AMBHTMX_PORT=<to change port default 3000>
````

## Code examples

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


### [Password protected CRUD (Create, Read, Update, and Delete) example with ambhtmx](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/07-crud.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/07.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/07-crud.R)

### [Cleaner and shorter code hx_ to hx- replacement](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/07-hx_attributes.R)
[![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/08.png)](https://github.com/jrosell/ambhtmx/blob/main/inst/examples/08-hx_attributes.R)

## Deployment examples (WIP)

If you create a Dockerfile you can deploy your ambhtmx app to HuggingFace Spaces, Digital Ocean, Google Cloud, etc.

I created the ambhtmx.crud repo for the CRUD example on [Github](https://github.com/jrosell/ambhtmx.crud) and [HuggingFace Spaces](https://huggingface.co/spaces/jrosell/ambhtmx.crud).

![](https://raw.githubusercontent.com/jrosell/ambhtmx/main/inst/examples/huggingface-spaces-Dockerfile.png)


## Troubleshooting

Known issues:

* Are you trying to autenticate from 0.0.0.0 host? Cookies don't work from 0.0.0.0 host, try 127.0.0.1 or a domain name instead (/etc/hosts or DNS).
* Are you trying an app without including all the required packages in the Dockerfile? Please, check the logs and edit the Dockerfile and try again.
* HuggingFace Spaces example is WIP and it's still not working.

Another issue? Please, [let me know](https://github.com/jrosell/ambhtmx/issues).