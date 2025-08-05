########################
if (require(jsonlite)) install.packages("jsonlite")
library(jsonlite)
# get your IP
jsonlite::fromJSON(rvest::html_text(rvest::read_html("http://jsonip.com/")))$ip
# test proxy 
session <- rvest::session("http://jsonip.com/",
                          httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0"),
                          httr::use_proxy(url = "XXXX", port = 8888,
                                          username = "XXXX", password = "XXXX"))
page_text <- rvest::html_text(rvest::read_html(session))
proxy_ip <- jsonlite::fromJSON(page_text)$ip
proxy_ip
#####################

# Scrape Scholar Google
useragent <- httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0")
proxy1 <- httr::use_proxy("5.78.83.190", port = 8080) # can pass proxy to function; here we just scrape patiently and don't use proxy
gs_df1 <- scrape_gs(term = 'intext:mammal* AND *urban*', 
                    pages = 1:20, 
                    crawl_delay = 1.2, 
                    useragent) # scrape first 20 pages (200 published works)

gs_df2 <- scrape_gs(term = 'intext:wildlife AND *urban*', 
                    pages = 1:20, 
                    crawl_delay = 1.2, 
                    useragent) # scrape first 20 pages (200 published works)

gs_df3 <- scrape_gs(term = 'intext:*carnivore* AND *urban*', 
                    pages = 1:20, 
                    crawl_delay = 1.2, 
                    useragent) # scrape first 20 pages (200 published works)

gs_df4 <- scrape_gs(term = 'intext:ungulate* AND *urban*', 
                    pages = 1:20, 
                    crawl_delay = 1.2, 
                    useragent) # scrape first 20 pages (200 published works)

gs_df5 <- scrape_gs(term = 'intext:rodent* AND *urban*', 
                    pages = 1:20, 
                    crawl_delay = 1.2, 
                    useragent) # scrape first 20 pages (200 published works)

gs_df6 <- scrape_gs(term = 'intext:bat* AND *urban*', 
                    pages = 1:20, 
                    crawl_delay = 1.2, 
                    useragent) # scrape first 20 pages (200 published works)
# result_df <- lapply(gs_df6, as.data.frame)
# gs_df6 <- as.data.frame(do.call(rbind, result_df))
# result_df
class(gs_df6)

# # even with some human-like behavior, the crawling script still gets blocked by server if run too long
# gs_df2 <- scrape_gs(term = 'intext:"mammal*" AND "*urban*"', pages = 21:40, crawl_delay = 1.2, useragent) # scrape next 20 pages (200 published works)
# 
# # if you don't have proxies, just scrape sequentially and cache results
# gs_df3 <- scrape_gs(term = 'intext:"mammal*" AND "*urban*"', pages = 41:60, crawl_delay = 1.2, useragent) # scrape next 20 pages (200 published works)
# 
# # if you don't have proxies, just scrape sequentially and cache results
# gs_df4 <- scrape_gs(term = 'intext:"mammal*" AND "*urban*"', pages = 61:80, crawl_delay = 1.2, useragent) # scrape next 20 pages (200 published works)
# 
# # we stopped at page 99 because that's how many pages Google Scholar gives us
# gs_df5 <- scrape_gs(term = 'intext:"mammal*" AND "*urban*"', pages = 81:99, crawl_delay = 1.2, useragent) # scrape last 19 pages (190 published works)
# 
# 
# # Check the first 10 entries:
  
gs_df <- rbind(gs_df1, gs_df2, gs_df3, gs_df4, gs_df5, gs_df6) # total of 99 pages (990 published works)
# See results
head(gs_df)