#' Infer trophic interactions using PFWIM trait rules
#'
#' Infers a consumer–resource edgelist using categorical trait matching rules
#' based on the PFWIM (Paleo Food Web Inference Model) described in
#' Shaw (2024). Interactions are inferred by comparing resource and consumer
#' trait combinations against a set of allowed trait rules.
#'
#' Trait matching is performed across all trait types present in
#' `cat_combo_list`. For each potential taxon pair, the number of satisfied
#' trait rules is calculated. An interaction is inferred when the number of
#' satisfied rules meets the required threshold defined by `certainty_req`.
#'
#' Optionally, a numerical predator–prey size rule can also be applied using
#' `num_size_rule`.
#'
#' @param data A `data.frame` containing taxa and associated trait values.
#' Each row represents a taxon and each column represents a trait.
#'
#' @param cat_combo_list A `data.frame` defining allowed consumer–resource
#' trait combinations. Must contain columns:
#' \describe{
#' \item{trait_type_resource}{Resource trait category}
#' \item{trait_resource}{Resource trait value}
#' \item{trait_type_consumer}{Consumer trait category}
#' \item{trait_consumer}{Consumer trait value}
#' }
#'
#' @param col_taxon Character string indicating the column containing taxon
#' names in `data`. Default `"taxon"`.
#'
#' @param col_num_size Optional column name containing numerical size values
#' for taxa. Used when applying a numeric predator–prey size rule.
#'
#' @param cat_trait_types Optional character vector specifying a subset of
#' categorical trait columns to use. If `NULL`, all traits appearing in
#' `cat_combo_list` are used.
#'
#' @param num_size_rule Optional function defining the predator–prey size
#' feasibility rule. The function must accept two numeric vectors:
#' `(resource_size, consumer_size)` and return `1` for feasible interactions
#' and `0` otherwise.
#'
#' Example:
#'
#' `function(res_size, con_size) { ifelse(res_size <= con_size, 1, 0) }`
#'
#' @param certainty_req Defines how many trait rules must be satisfied for an
#' interaction to be considered feasible.
#' \describe{
#' \item{"all"}{All trait types must match}
#' \item{numeric}{Minimum number of matching trait types required}
#' }
#'
#' @param allow_self Logical. If TRUE, allows interactions where the resource
#' and consumer are the same taxon (self-loops). Default is FALSE.
#'
#' @param return_full_matrix Logical. If `TRUE`, returns the full matrix of
#' taxon pairs and the number of matching trait rules. If `FALSE`, returns
#' only inferred interactions as an edgelist.
#'
#' @param print_dropped_taxa Logical. If `TRUE`, prints taxa that were removed
#' from the inferred food web because they have no feasible interactions.
#'
#' @param hide_printout Logical. If `TRUE`, suppresses progress messages.
#'
#' @param ... Additional arguments reserved for future extensions.
#'
#' @return
#' If `return_full_matrix = FALSE`:
#'
#' A two-column matrix containing:
#' \describe{
#' \item{taxon_resource}{Resource taxon}
#' \item{taxon_consumer}{Consumer taxon}
#' }
#'
#' If `return_full_matrix = TRUE`:
#'
#' A matrix containing all taxon pairs and the number of trait rules satisfied.
#'
#' @details
#' The function evaluates all possible consumer–resource taxon pairs and
#' determines interaction feasibility using categorical trait rules and,
#' optionally, a numerical size constraint. The final edgelist includes only
#' interactions meeting the certainty requirement.
#'
#' @references
#' Shaw, J. (2024). PFWIM: Paleo Food web Inference Model. *Preprint*.
#'
#' @examples
#' infer_edgelist(
#'   data = traits,
#'   cat_combo_list = feeding_rules,
#'   col_taxon = "species",
#'   certainty_req = "all"
#' )
#'
#' @export
infer_edgelist <- function(data,
                           cat_combo_list,
                           col_taxon = "taxon",
                           col_num_size = NULL,
                           cat_trait_types = NULL,
                           num_size_rule = NULL,
                           certainty_req = "all",
                           allow_self = TRUE,
                           return_full_matrix = FALSE,
                           print_dropped_taxa = FALSE,
                           hide_printout = FALSE,
                           ...) {

  # Hide "no visible binding for global variable" comment
  . <- Var1 <- Var2 <- pres_sum <- size_consumer <- size_resource <- taxon_consumer <- taxon_resource <- trait <- trait_type <- trait_type_consumer <- trait_type_interaction <- trait_type_pres <- trait_value_pres <- trait_type_resource <- trait_consumer <- NULL

  # Check inputs

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame.", call. = FALSE)
  }

  if (!is.data.frame(cat_combo_list)) {
    stop("`cat_combo_list` must be a data.frame.", call. = FALSE)
  }

  required_cols <- c(
    "trait_type_resource",
    "trait_resource",
    "trait_type_consumer",
    "trait_consumer"
  )

  missing_cols <- setdiff(required_cols, colnames(cat_combo_list))
  if (length(missing_cols) > 0) {
    stop(
      paste0(
        "`cat_combo_list` is missing required columns: ",
        paste(missing_cols, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  if (!col_taxon %in% colnames(data)) {
    stop(
      paste0("Column `", col_taxon, "` not found in `data`."),
      call. = FALSE
    )
  }

  if (!is.null(col_num_size)) {
    if (!col_num_size %in% colnames(data)) {
      stop(
        paste0("Column `", col_num_size, "` not found in `data`."),
        call. = FALSE
      )
    }

    if (is.null(num_size_rule)) {
      stop(
        "`num_size_rule` must be provided when `col_num_size` is specified.",
        call. = FALSE
      )
    }

    if (!is.function(num_size_rule)) {
      stop("`num_size_rule` must be a function.", call. = FALSE)
    }
  }

  if (!is.null(cat_trait_types)) {
    if (!all(cat_trait_types %in% colnames(data))) {
      stop(
        "All `cat_trait_types` must be columns present in `data`.",
        call. = FALSE
      )
    }
  }

  if (!(certainty_req == "all" || is.numeric(certainty_req))) {
    stop("`certainty_req` must be 'all' or a numeric value.", call. = FALSE)
  }

  if (is.numeric(certainty_req) && certainty_req <= 0) {
    stop("`certainty_req` must be greater than 0.", call. = FALSE)
  }

  names(data)[names(data) == col_taxon] <- "taxon"
  col_taxon <- "taxon"

  trait_cats <- tolower(unique(c(cat_combo_list[, c("trait_type_resource")], cat_combo_list[, c("trait_type_consumer")])))
  trait_cats_cons <- tolower(unique(c(cat_combo_list[, c("trait_type_consumer")])))
  col_taxon <- tolower(col_taxon)

  if (is.null(cat_trait_types)) {
  } else {
    trait_cats <- cat_trait_types
    trait_cats_cons <- cat_trait_types
  }

  fd <- as.data.frame(data)
  colnames(fd) <- tolower(colnames(fd))


  # Run for all trait types
  fw_match_traits <- c()
  for (i in trait_cats_cons) {
    col_combo_list_mini <- cat_combo_list %>% dplyr::filter(trait_type_consumer == i)

    res_cols <- unique(col_combo_list_mini$trait_type_resource)

    res_taxa <- fd %>%
      dplyr::select(dplyr::all_of(c(col_taxon, res_cols)))
    con_taxa <- fd %>%
      dplyr::select(dplyr::all_of(c(col_taxon, i))) %>%
      filter_all(any_vars(!is.na(.)))
    con_taxa <- con_taxa[Reduce(`&`, lapply(con_taxa, function(x) !(is.na(x) | x == ""))), ]

    res_taxa_longer <- res_taxa %>%
      dplyr::mutate_all(., as.character) %>%
      tidyr::pivot_longer(-dplyr::all_of(col_taxon), names_to = "trait_type", values_to = "trait") %>%
      dplyr::filter(trait_type %in% col_combo_list_mini[, c("trait_type_resource")])

    con_taxa_longer <- con_taxa %>%
      dplyr::mutate_all(., as.character) %>%
      tidyr::pivot_longer(-dplyr::all_of(col_taxon), names_to = "trait_type", values_to = "trait") %>%
      dplyr::filter(trait != "primary")

    # create crossing table
    crossing_taxa <- tidyr::crossing(
      res_taxa_longer %>% dplyr::rename_with(~paste0(.x, "_resource")),
      con_taxa_longer %>% dplyr::rename_with(~paste0(.x, "_consumer"))
    )

    # first join (trait type feasibility)
    crossing_taxa <- dplyr::left_join(
      crossing_taxa,
      col_combo_list_mini %>%
        dplyr::select(trait_type_resource, trait_type_consumer, trait_consumer) %>%
        dplyr::mutate(trait_type_pres = 1),
      by = c(
        "trait_type_resource",
        "trait_type_consumer",
        "trait_consumer"
      ),
      relationship = "many-to-many"
    )

    # filter valid types
    crossing_taxa <- crossing_taxa %>%
      dplyr::filter(trait_type_pres == 1) %>%
      dplyr::distinct()

    # second join (trait value feasibility)
    crossing_taxa <- dplyr::left_join(
      crossing_taxa,
      col_combo_list_mini %>%
        dplyr::mutate(trait_value_pres = 1),
      by = c(
        "trait_type_resource",
        "trait_type_consumer",
        "trait_consumer",
        "trait_resource"
      ),
      relationship = "many-to-many"
    )

    # final filtering
    crossing_taxa <- crossing_taxa %>%
      dplyr::filter(trait_value_pres == 1) %>%
      dplyr::mutate(trait_type_interaction = i) %>%
      dplyr::select(
        taxon_resource,
        taxon_consumer,
        trait_type_interaction,
        trait_value_pres
      )


    fw_match_traits <- rbind(fw_match_traits, crossing_taxa)
    if (!hide_printout) print(i)
  }

  # If feasibility of interaction also defined by a numerical size rule, then utilize
  if (is.null(col_num_size)) {

  } else {
    fw_size_pastes <- unique(paste(fd[, c(col_taxon)], fd[, c(col_num_size)], sep = "SEP"))
    fw_size_expand <- as.data.frame(expand.grid(fw_size_pastes, fw_size_pastes)) %>%
      tidyr::separate(Var1, c("taxon_resource", "size_resource"), sep = "SEP", convert = TRUE) %>%
      tidyr::separate(Var2, c("taxon_consumer", "size_consumer"), sep = "SEP", convert = TRUE) %>%
      dplyr::mutate(trait_value_pres = num_size_rule(size_resource, size_consumer), trait_type_interaction = col_num_size) %>%
      dplyr::filter(trait_value_pres == 1) %>%
      dplyr::select(taxon_resource, taxon_consumer, trait_value_pres, trait_type_interaction)
    fw_match_traits <- bind_rows(fw_match_traits, fw_size_expand)
    if (!hide_printout) print(col_num_size)
  }


  fw_match_traits2 <- fw_match_traits %>%
    dplyr::distinct() %>%
    tidyr::pivot_wider(names_from = trait_type_interaction, values_from = trait_value_pres)
  fw_match_traits2$pres_sum <- fw_match_traits2 %>%
    dplyr::select(all_of(unique(fw_match_traits$trait_type_interaction))) %>%
    rowSums(na.rm = TRUE)

  # How many trait combinations need to be matched in order for an interaction to be viable
  if (certainty_req == "all") {
    certainty_val <- length(unique(fw_match_traits$trait_type_interaction))
  } else {
    certainty_val <- certainty_req
    certainty_val <- ifelse(certainty_val > length(unique(fw_match_traits$trait_type_interaction)), length(unique(fw_match_traits$trait_type_interaction)), certainty_val)
  }

  # remove cannibalism if allow_self is set to false
  if (!allow_self) {
    fw_match_traits3 <- fw_match_traits3 %>%
      dplyr::filter(taxon_resource != taxon_consumer)
  }

  # Return full matrix with trait feasibility indicated or not
  if (return_full_matrix == TRUE) {
    fw_match_traits3 <- fw_match_traits2 %>% dplyr::distinct()
    # print(paste(length(setdiff(unique(fd$taxon), unique(c(fw_match_traits3$taxon_resource, fw_match_traits3$taxon_consumer)))), "taxa dropped from web"))

    return(tibble::as_tibble(fw_match_traits3))
  } else {
    fw_match_traits3 <- fw_match_traits2 %>%
      dplyr::filter(pres_sum >= certainty_val) %>%
      dplyr::distinct()
    if (!hide_printout) print(paste(length(setdiff(unique(fd$taxon), unique(c(fw_match_traits3$taxon_resource, fw_match_traits3$taxon_consumer)))), "taxa dropped from web"))

    if (print_dropped_taxa == TRUE) {
      if (!hide_printout) print(setdiff(unique(fd$taxon), unique(c(fw_match_traits3$taxon_resource, fw_match_traits3$taxon_consumer))))
    } else {
    }

    return(tibble::as_tibble(fw_match_traits3[, c("taxon_resource", "taxon_consumer")]))
  }
}
