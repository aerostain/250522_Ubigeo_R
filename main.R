# Librerías
library(tidyverse)
library(magrittr)
library(ggplot2)
library(expss)
library(ggdark)
library(lubridate)
library(DBI)
library(RMySQL)
library(sf)
library(terra)
library(haven)
library(rio)
library(pacman)
library(shiny)
library(devtools)

# .lintr
text <- c(
  "linters: linters_with_defaults(",
  "  assignment_linter(allow_pipe_assign = TRUE),",
  "  object_usage_linter = NULL",
  "  )"
)
pathfile <- file.path(getwd(), ".lintr")
writeLines(text, pathfile)

# Directorios y Archivos
dir.create("Files")
file.create(".gitignore")
file.create("readme.md")
file.create("informe.qmd")
file.create("notes.md")
file.create("test.R")
dir()

# Git
system("ipconfig")
system("git config --global user.name 'r1ck7'")
system("git config --global user.email 'richims026@gmail.com'")

system("git init")
system("git remote add repos https://github.com/aerostain/250522_Ubigeo_R.git")
system("git remote -v")

system("git status")
system("git add .")
system("git status")
system("git commit -m 'Init'")
system("git log")
system("git push repos master")

# Opciones de Consola
options("width" = 10000)
getOption("width")

# Procesamiento
mtcars %>% str()
mtcars %>% info()

diamonds %>% head()

# ---------------------------------------------------------------------
# Importar data
# ---------------------------------------------------------------------

dept <- read.csv(file.choose(), colClasses = "character")
dept %>% str()
prov <- read.csv(file.choose(), colClasses = "character")
prov %>% str()
dist <- read.csv(file.choose(), colClasses = "character")
dist %>% str()

# ---------------------------------------------------------------------
# Join Data
# ---------------------------------------------------------------------

tmp <-
  inner_join(dist, prov,
    by = c("province_id" = "id"), suffix = c(".dist", ".prov")
  )
tmp %>% str()

tmp %<>% mutate(
  ubigeo = id,
  distrito = name.dist,
  id_provincia = province_id,
  provincia = name.prov,
  id_departamento = department_id.dist
)
tmp %<>% select(ubigeo, distrito, id_provincia, provincia, id_departamento)

tmp_ <-
  inner_join(tmp, dept, by = c("id_departamento" = "id"))
tmp_ %>% str()
tmp_ %<>% mutate(departamento = name)
tmp_ %<>% select(-name)
tmp_ %<>% mutate(id = seq_len(1874))
tmp_ %<>% select(id, everything())

ubigeo_tabla <- tmp_

# ---------------------------------------------------------------------
# Dataframe a SqlServer
# ---------------------------------------------------------------------

install.packages("odbc")
library(odbc)

server_name <- "st_ubigeo.mssql.somee.com"
database_name <- "st_ubigeo"
username <- "richims097_SQLLogin_1"
password <- "myrt3zxxcq"

con <- dbConnect(odbc::odbc(),
  Driver = "ODBC Driver 17 for SQL Server",
  # Asegúrate de usar el nombre exacto de tu driver
  Server = server_name,
  Database = database_name,
  Uid = username,
  Pwd = password
)

dbWriteTable(con,
  name = "ubigeo",
  value = ubigeo_tabla,
  overwrite = FALSE,
  append = FALSE
)

tmpcon <-
  dbGetQuery(
    con,
    paste0("select * from ubigeo where id_departamento like '02'")
  )

tmpcon %>% str()

