test_that("infer_edgelist runs without error", {

  expect_no_error(
    infer_edgelist(
      data = traits,
      cat_combo_list = feeding_rules,
      col_taxon = "species",
      hide_printout = TRUE,
      allow_self = FALSE
    )
  )

})

test_that("infer_edgelist returns expected interactions", {

  result <- infer_edgelist(
    data = traits,
    cat_combo_list = feeding_rules,
    col_taxon = "species",
    hide_printout = TRUE
  )

  result <- dplyr::arrange(result, taxon_consumer, taxon_resource)
  expected <- dplyr::arrange(edgelist, taxon_consumer, taxon_resource)

  expect_equal(result, expected)

})

test_that("certainty_req filters interactions correctly", {

  strict <- infer_edgelist(
    data = traits,
    cat_combo_list = feeding_rules,
    col_taxon = "species",
    certainty_req = "all",
    hide_printout = TRUE
  )

  relaxed <- infer_edgelist(
    data = traits,
    cat_combo_list = feeding_rules,
    col_taxon = "species",
    certainty_req = 1,
    hide_printout = TRUE
  )

  expect_true(nrow(strict) <= nrow(relaxed))

})

test_that("return_full_matrix returns expanded matrix", {

  full <- infer_edgelist(
    data = traits,
    cat_combo_list = feeding_rules,
    col_taxon = "species",
    return_full_matrix = TRUE,
    hide_printout = TRUE
  )

  expect_true("pres_sum" %in% colnames(full))
  expect_true(nrow(full) > 0)

})

test_that("missing taxon column throws error", {

  bad_data <- traits
  names(bad_data)[1] <- "wrong"

  expect_error(
    infer_edgelist(
      data = bad_data,
      cat_combo_list = feeding_rules,
      col_taxon = "species"
    ),
    "not found"
  )

})

test_that("invalid certainty_req errors", {

  expect_error(
    infer_edgelist(
      data = traits,
      cat_combo_list = feeding_rules,
      certainty_req = "invalid"
    )
  )

})

test_that("numeric size rule requires function", {

  expect_error(
    infer_edgelist(
      data = traits,
      cat_combo_list = feeding_rules,
      col_num_size = "size"
    )
  )

})

test_that("infer_edgelist correctly applies numeric size rules", {

  # 1. Create a simplified numeric dataset
  numeric_traits <- data.frame(
    species = c("Lion", "Zebra", "Grass"),
    diet = c("carnivore", "herbivore", "producer"),
    body_mass = c(190, 300, 1) # Note: Zebra is heavier than Lion
  )

  # 2. Create a basic categorical rule (Carnivores eat Herbivores)
  simple_rules <- data.frame(
    trait_type_resource = "diet",
    trait_resource = "herbivore",
    trait_type_consumer = "diet",
    trait_consumer = "carnivore"
  )

  # 3. Define a numeric rule: Consumer must be at least 50% of resource mass
  # Using your required syntax: function(res_size, con_size)
  mass_rule <- function(res_size, con_size) {
    ifelse(con_size >= (res_size * 0.5), 1, 0)
  }

  # 4. Run the function
  result <- infer_edgelist(
    data = numeric_traits,
    cat_combo_list = simple_rules,
    col_taxon = "species",
    col_num_size = "body_mass",
    num_size_rule = mass_rule,
    certainty_req = "all", # Must satisfy diet rule AND mass rule
    hide_printout = TRUE
  )

  # 5. Assertions
  # In this scenario:
  # Lion (190) eating Zebra (300) is feasible (190 >= 150)
  # If we changed the rule to con_size > res_size, it would return 0 rows.

  expect_s3_class(result, "tbl_df")
  expect_true(any(result$taxon_consumer == "Lion" & result$taxon_resource == "Zebra"))

  # Test that it fails if the rule is not met
  strict_rule <- function(res_size, con_size) {
    ifelse(con_size > res_size, 1, 0)
  }

  result_strict <- infer_edgelist(
    data = numeric_traits,
    cat_combo_list = simple_rules,
    col_taxon = "species",
    col_num_size = "body_mass",
    num_size_rule = strict_rule,
    certainty_req = "all",
    hide_printout = TRUE
  )

  # Lion is NOT larger than Zebra, so no links should be found
  expect_equal(nrow(result_strict), 0)
})
