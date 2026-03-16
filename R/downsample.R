#' Sample integers according to a discrete probability distribution
#'
#' Generates random draws from 1:M with probabilities defined by a
#' user-specified function (default is the PFWIM mixed exponential–power law
#' distribution).
#'
#' @param M Integer. Maximum value to sample (upper bound of 1:M).
#' @param y Numeric. Parameter controlling the distribution shape.
#' @param func Function. Probability function of r (1:M), M, and y.
#'   Default is the PFWIM exponential–power law function:
#'   \code{function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / y))))}.
#' @param n_samp Integer. Number of random draws.
#'
#' @return Integer vector of length \code{n_samp} with values in 1:M.
#' @keywords internal
#'
#' @examples
#' # Generate 3 replicate webs from a small edgelist
#' edgelist <- data.frame(
#'   res_node_node_name_inferred = c("plankton","plant_1","plant_2"),
#'   con_node_node_name_inferred = c("cod","rat","deer")
#' )
#' webs <- powerlaw_prey(edgelist, n_samp = 3, y = 2.5)
sample_pdf <- function(M = 100,
                       y = 2.5,
                       func = function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / y)))),
                       n_samp = 100) {

  probs <- sapply(1:M, func, M = M, y = y)
  probs <- probs / sum(probs)

  sample(1:M, n_samp, replace = TRUE, prob = probs)
}

#' Generate hypothetical realised webs using a power-law link distribution
#'
#' PFWIM generates a series of replicate hypothetical realised food webs by
#' reducing the feasible links for each consumer to match a target link
#' distribution. The default distribution is a mixed exponential–power law
#' in-degree distribution as described in Shaw (2024) and Roopnarine (2006).
#'
#' @param el Data frame or matrix containing a feasible consumer–resource
#'   edgelist. Column 1 = resource, Column 2 = consumer.
#' @param n_samp Integer. Number of replicate realised webs to generate. Default = 50.
#' @param y Numeric. Parameter controlling the shape of the power-law distribution.
#'   Default = 2.5.
#' @param func Function. Probability function of the in-degree `r`, total prey
#'   richness `M`, and parameter `y`. Must return a numeric value > 0.
#'   Default:
#'   \code{function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / y))))}.
#'
#' @return A list of length \code{n_samp}. Each element is a data frame
#'   representing a realised food web edgelist with two columns:
#'   \describe{
#'     \item{resource}{Resource species}
#'     \item{consumer}{Consumer species}
#'   }
#'
#' @details For each consumer in `el`, the number of prey links in a realised
#' web is sampled according to the distribution defined by `func`. The sampled
#' prey are drawn randomly without exceeding the maximum feasible prey for that
#' consumer.
#'
#' @references
#' Shaw, J. (2024). PFWIM: Paleo Food-web Inference Model. *Preprint*.
#' Roopnarine, P. (2006). *Palaeoecology and food-web structure in fossil communities*.
#'
#' @examples
#' # Infer a minimal edgelist
#' edgelist <- infer_edgelist(
#'   data = data.frame(
#'     species = c("plankton","plant_1","plant_2","cod","rat","deer"),
#'     feeding = c("primary","primary","primary","secondary","secondary","secondary")
#'   ),
#'   cat_combo_list = data.frame(
#'     trait_type_resource = c("feeding","feeding","feeding"),
#'     trait_resource = c("primary","primary","primary"),
#'     trait_type_consumer = c("feeding","feeding","feeding"),
#'     trait_consumer = c("secondary","secondary","secondary")
#'   ),
#'   col_taxon = "species",
#'   certainty_req = "all"
#' )
#'
#' # Generate realized webs
#' webs <- powerlaw_prey(edgelist, n_samp = 3, y = 2.5)
#'
#' @export
powerlaw_prey <- function(el,
                          n_samp = 50,
                          y = 2.5,
                          func = function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / y))))) {

  con_node_node_name_inferred <- NULL

  # Ensure input is a data frame
  edgelist <- as.data.frame(el)
  colnames(edgelist) <- c("resource", "consumer")

  consumer_list <- split(edgelist, edgelist$consumer)

  # Initialise list to store realised webs
  web_list <- vector("list", n_samp)

  for (consumer in names(consumer_list)) {

    min <- consumer_list[[consumer]]

    M_consumer <- nrow(min)

    sampled_degree <- sample_pdf(
      M = M_consumer,
      y = y,
      func = func,
      n_samp = n_samp
    )

    for (j in seq_len(n_samp)) {

      n_links <- min(M_consumer, sampled_degree[j])

      sampled_rows <- min[sample(M_consumer, n_links), ]

      if (is.null(web_list[[j]])) {
        web_list[[j]] <- sampled_rows
      } else {
        web_list[[j]] <- rbind(web_list[[j]], sampled_rows)
      }

    }
  }

  # give named outputs
  names(web_list) <- paste0("web_", seq_len(n_samp))

  return(web_list)
}
