#' Infer edgelist using pfim fules blah blah blah
#' 
#' valuable for num_size_rule as an example? `function(res_size, con_size) {ifelse(res_size <= con_size, 1, 0)}`
#'
#' @param data dataframe object containing species and relevant traits.
#' @param cat_combo_list dataframe containing trait rules
#' @param col_taxon indicate column containing taxon names.
#' @param col_num_size use "size_select" if using a numerical prey-pred size rule indicate column containing numerical size values
#' @param cat_trait_types if you only want to use a subset of life habit columns enter column names as vector otherwise
#' @param num_size_rule function defining pred-prey size rule, e.g. as long as predator is equal to or larger than prey then an interaction is feasible
#' @param certainty_req state whether an interaction must meet all trait rules or the minimum number of rules that must be met
#' @param return_full_matrix indicate whether the function should return all taxon pairs with a value indicating how many trait rules were met, or whether the function should just return inferred interactions as an edgelist
#' @param print_dropped_taxa print names of any taxa that have been removed
#' @return edgelist showing resource and consumer.
#' @examples
#' TODO
infer_edgelist <- function(data,
                           cat_combo_list,
                           col_taxon = "taxon",
                           col_num_size = NULL,
                           cat_trait_types = NULL,
                           num_size_rule = NULL,
                           certainty_req = "all",
                           return_full_matrix = FALSE,
                           print_dropped_taxa = FALSE,
                           hide_printout = FALSE,
                           ...) {
  
  # Hide "no visible binding for global variable" comment
  . <- Var1 <- Var2 <- pres_sum <- size_consumer <- size_resource <- taxon_consumer <- taxon_resource <- trait <- trait_type <- trait_type_consumer <- trait_type_interaction <- trait_type_pres <- trait_value_pres <- NULL
  
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
    
    res_taxa <- fd %>% dplyr::select(c(col_taxon, unique(col_combo_list_mini[, c("trait_type_resource")])))
    con_taxa <- fd %>%
      dplyr::select(c(col_taxon, i)) %>%
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
    
    crossing_taxa <- tidyr::crossing(as.data.frame(res_taxa_longer) %>% setNames(paste0(names(.), "_resource")), con_taxa_longer %>% setNames(paste0(names(.), "_consumer"))) %>%
      dplyr::left_join(col_combo_list_mini[, c("trait_type_resource", "trait_type_consumer", "trait_consumer")] %>% dplyr::mutate(trait_type_pres = 1), by = c("trait_type_resource", "trait_type_consumer", "trait_consumer"))
    crossing_taxa <- crossing_taxa %>%
      dplyr::filter(trait_type_pres == 1) %>%
      dplyr::distinct() %>%
      dplyr::left_join(col_combo_list_mini %>% dplyr::mutate(trait_value_pres = 1), by = c("trait_type_resource", "trait_type_consumer", "trait_consumer", "trait_resource"))
    crossing_taxa <- crossing_taxa %>%
      dplyr::filter(trait_value_pres == 1) %>%
      dplyr::mutate(trait_type_interaction = i)
    crossing_taxa <- crossing_taxa[, c("taxon_resource", "taxon_consumer", "trait_type_interaction", "trait_value_pres")]
    
    fw_match_traits <- rbind(fw_match_traits, crossing_taxa)
    if (hide_printout == FALSE) print(i)
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
    if (hide_printout == FALSE) print(col_num_size)
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
  
  
  # Return full matrix with trait feasibility indicated or not
  if (return_full_matrix == TRUE) {
    fw_match_traits3 <- fw_match_traits2 %>% dplyr::distinct()
    # print(paste(length(setdiff(unique(fd$taxon), unique(c(fw_match_traits3$taxon_resource, fw_match_traits3$taxon_consumer)))), "taxa dropped from web"))
    
    
    
    return(as.matrix(fw_match_traits3))
  } else {
    fw_match_traits3 <- fw_match_traits2 %>%
      dplyr::filter(pres_sum >= certainty_val) %>%
      dplyr::distinct()
    if (hide_printout == FALSE) print(paste(length(setdiff(unique(fd$taxon), unique(c(fw_match_traits3$taxon_resource, fw_match_traits3$taxon_consumer)))), "taxa dropped from web"))
    
    if (print_dropped_taxa == TRUE) {
      if (hide_printout == FALSE) print(setdiff(unique(fd$taxon), unique(c(fw_match_traits3$taxon_resource, fw_match_traits3$taxon_consumer))))
    } else {
    }
    
    return(as.matrix(fw_match_traits3[, c("taxon_resource", "taxon_consumer")]))
  }
}