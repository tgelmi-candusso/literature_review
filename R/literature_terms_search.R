scopus_initial_pull_SBM <- read_csv("data/scopus_initial_pull_SBM.csv") %>% dplyr::filter(include == "Y") %>% dplyr::select(-"...25" )
scopus_initial_pull_TGC <- read_csv("data/scopus_initial_pull_TGC.csv") %>% dplyr::filter(include == "Yes")
scopus_initial_pull_MHM <- read_csv("data/scopus_initial_pull_MHM.csv") %>% dplyr::filter(include == "1")
colnames(scopus_initial_pull_SBM)
scopus_initial_pull <- rbind(scopus_initial_pull_SBM, scopus_initial_pull_TGC) %>% rbind(., scopus_initial_pull_MHM)
scopus_initial_pull <- as.data.frame(scopus_initial_pull)

# Extract terms from from title
gs_terms <- litsearchr::extract_terms(text = scopus_initial_pull[,"Title"],
                                      method = "fakerake", min_freq = 3, min_n = 2,
                                      stopwords = stopwords::data_stopwords_stopwordsiso$en)


# Create Co-Occurrence Network
gs_docs <- paste(scopus_initial_pull[, "Title"],scopus_initial_pull[, "Index.Keywords"], scopus_initial_pull[, "Author.Keywords"]) # we will consider title and abstract of each article to represent the article's "content"
gs_dfm <- litsearchr::create_dfm(elements = gs_docs, features = gs_terms) # document-feature matrix
gs_coocnet <- litsearchr::create_network(gs_dfm, min_studies = 3)
library(ggraph)
ggraph(gs_coocnet, layout = "stress") +
  coord_fixed() +
  expand_limits(x = c(-3, 3)) +
  geom_edge_link(aes(alpha = weight)) +
  geom_node_point(shape = "circle filled", fill = "white") +
  geom_node_text(aes(label = name), hjust = "outward", check_overlap = TRUE) +
  guides(edge_alpha = "none") +
  theme_void()

#compute node strength

# Prune the Network based on node strength
gs_node_strength <- igraph::strength(gs_coocnet)
gs_node_rankstrenght <- data.frame(term = names(gs_node_strength), strength = gs_node_strength, row.names = NULL)
gs_node_rankstrenght$rank <- rank(gs_node_rankstrenght$strength, ties.method = "min")
gs_node_rankstrenght <- gs_node_rankstrenght[order(gs_node_rankstrenght$rank),]
gs_plot_strenght <-
  ggplot(gs_node_rankstrenght, aes(x = rank, y = strength, label = term)) +
  geom_line(lwd = 0.8) +
  geom_point() +
  ggrepel::geom_text_repel(size = 3, hjust = "right", nudge_y = 3, max.overlaps = 30) +
  theme_bw()
gs_plot_strenght

#find cutoff values
# Cumulatively - retain a certain proportion (e.g. 80%) of the total strength of the network of search terms
gs_cutoff_cum <- litsearchr::find_cutoff(gs_coocnet, method = "cumulative", percent = 0.8)
# Changepoints - certain points along the ranking of terms where the strength of the next strongest term is much greater than that of the previous one
gs_cutoff_change <- litsearchr::find_cutoff(gs_coocnet, method = "changepoint", knot_num = 3)
gs_plot_strenght +
  geom_hline(yintercept = gs_cutoff_cum, color = "red", lwd = 0.7, linetype = "longdash", alpha = 0.6) +
  geom_hline(yintercept = gs_cutoff_change, color = "orange", lwd = 0.7, linetype = "dashed", alpha = 0.6)

gs_cutoff_crit <- gs_cutoff_change[which.min(abs(gs_cutoff_change - gs_cutoff_cum))] # e.g. nearest cutpoint to cumulative criterion (cumulative produces one value, changepoints may be many)
gs_maxselected_terms <- litsearchr::get_keywords(litsearchr::reduce_graph(gs_coocnet, gs_cutoff_crit))

#keep only shortest substrings
superstring <- rep(FALSE, length(gs_maxselected_terms))
for(i in seq_len(length(gs_maxselected_terms))) {
  superstring[i] <- any(stringr::str_detect(gs_maxselected_terms[i], gs_maxselected_terms[-which(gs_maxselected_terms == gs_maxselected_terms[i])]))
}
gs_selected_terms <- gs_maxselected_terms[!superstring]


#We will also manually do two other changes: 
#(1) we are not interested in “systematic reviews” so we will remove it; 
#(2) we will add the terms “psychotherapy” and “ptsd” as they are not already present in their simplest form.

# gs_selected_terms <- gs_selected_terms[-which(gs_selected_terms == "systematic review")]
gs_selected_terms <- c(gs_selected_terms, "mammal", "urbanization")

#We see that term groupings are obvious: type of study (design), type of intervention, disorder/symptoms, and population.
# Manual grouping into clusters - for more rigorous search we will need a combination of OR and AND operators
landscapetype <- gs_selected_terms[c(3:4,16,18:24,26:28)]
mammaltype <- gs_selected_terms[c(1:2,5:13,15:17,29:31)]
topic <- gs_selected_terms[c(14,32:37)]
# all.equal(length(gs_selected_terms),
# sum(length(design), length(intervention), length(disorder))
# ) # check that we grouped all terms
gs_gruped_selected_terms <- list(
  landscapetype = landscapetype,
  mammaltype = mammaltype,
  topic = topic
)

# Write the search
litsearchr::write_search(
  gs_gruped_selected_terms,
  languages = "English",
  exactphrase = TRUE,
  stemming = FALSE,
  closure = "left",
  writesearch = FALSE
)
#and these would be the search term relevant to the papers we found in our naive search now with these we can move on to Web of Science I guess
# "((\"wildlife conservation\" OR \"wildlife management\") AND (\"urban environment\" OR \"urban landscape\" OR urbanization) AND (\"urban wildlife\" OR \"wildlife interactions\" OR mammal))"
#Only the last two steps, pertaining to term exclusion and term grouping, need the careful decisions of a human researcher. The automatic workflow, on it’s own, found some important terms that I would have surely omitted.
#Grames, E. M., Stillman, A. N., Tingley, M. W., & Elphick, C. S. (2019). An automated approach to identifying search terms for systematic reviews using keyword co‐occurrence networks. Methods in Ecology and Evolution, 10(10), 1645-1654.
  