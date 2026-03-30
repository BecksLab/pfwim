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
