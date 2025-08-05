# litsearchr isn't yet on CRAN, need to install from github
if (require(litsearchr)) remotes::install_github("elizagrames/litsearchr", ref = "main")
# Packages to load/install
packages <- c(
  "easyPubMed",
  "litsearchr", "stopwords", "igraph",
  "ggplot2", "ggraph", "ggrepel"
)
# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# Load packages
lapply(packages, library, character.only = TRUE)


# Source web scraping function
devtools::source_gist("https://gist.github.com/ClaudiuPapasteri/7bef34394c395e03ee074f884ddbf4d4")
