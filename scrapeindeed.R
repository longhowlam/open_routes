library(rvest)
library(stringr)

link = "https://www.indeed.nl/jobs?q=data+scientist&l=nederland&start=60"

out = read_html(link) 
lokatie = html_nodes(out, ".location") %>% html_text()
html_nodes(out, ".jobtitle") %>% html_attr("href")

link = "https://www.blokker.nl/winkels/amsterdam"

out = read_html(link) 
lokatie = html_nodes(out, "address") %>% 
  html_text() %>% 
  str_extract("\\d{4}\\s?[A-Z]{2}") %>% 
  str_remove("\\s")

