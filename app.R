# load_all() is only for Windows. On Linux, the neostocks package must be installed
# first via `R CMD INSTALL .` or `devtools::install()`.
pkgload::load_all()

future::plan(future::multisession)

options(shiny.autoload.r = FALSE)

new_app()  # shinyApp
