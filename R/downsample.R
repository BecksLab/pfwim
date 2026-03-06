#' Internal powerlaw function used for downsampling metawebs
#' #'
#' @param M richness.
#' @param y parameter
#' @param func power law.
#' @param n_samp number of samples
#' @return TODO
#' @examples TODO
sample_pdf <- function(M = 100,
                       y = 2.5,
                       func = function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / (y))))),
                       n_samp = 100) {
  row <- c()
  for (i in 1:M) {
    row <- c(row, func(i, M, y))
  }
  row2 <- as.data.frame(row)
  
  ar <- sum(row)
  row <- row / ar
  
  return(sample(1:M, n_samp, replace = T, prob = row))
}

#' Infer edgelist using pfim fules blah blah blah
#' 
#' valuable for num_size_rule as an example? `function(res_size, con_size) {ifelse(res_size <= con_size, 1, 0)}`
#'
#' @param el edgelist showing resource and consumer. NB col1 = resource, col2 = consumer
#' @param n_samp number of samples
#' @param func power-law distribution.
#' @return pruned edgelist.
#' @examples TODO
powerlaw_prey <- function(el,
                          n_samp = 50,
                          func = function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / (y)))))) {
  
  con_node_node_name_inferred <- NULL
  
  edgelist <- as.data.frame(el)
  colnames(edgelist) <- c("res_node_node_name_inferred", "con_node_node_name_inferred")
  
  web_list <- lapply(1:n_samp, matrix, data = NA, nrow = 0, ncol = 2)
  
  for (i in unique(edgelist$con_node_node_name_inferred)) {
    min <- edgelist %>% dplyr::filter(con_node_node_name_inferred == i)
    min <- as.data.frame(min)
    rich <- as.numeric(as.character(length(unique(min[, c("res_node_node_name_inferred")]))))
    
    t <- sample_pdf(M = rich, n_samp = n_samp)
    
    names(t) <- rep(i, length(t))
    
    for (j in 1:length(t)) {
      
      # Currently taking upper bound
      min2 <- min %>% sample_n(min(rich, t[[j]]))
      
      
      
      web_list[[j]] <- rbind(web_list[[j]], min2)
    }
  }
  
  web_list <- lapply(web_list, as.matrix)
  web_list <- lapply(web_list, na.omit)
  
  
  
  return(web_list)
}