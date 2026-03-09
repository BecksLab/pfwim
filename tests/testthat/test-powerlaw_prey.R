test_that("powerlaw_prey runs", {

  expect_no_error(
    powerlaw_prey(edgelist, n_samp = 10)
  )

})

test_that("powerlaw_prey returns list of webs", {

  webs <- powerlaw_prey(edgelist, n_samp = 10)

  expect_true(is.list(webs))
  expect_equal(length(webs), 10)

})

test_that("each replicate web is matrix", {

  webs <- powerlaw_prey(edgelist, n_samp = 5)

  expect_true(all(sapply(webs, is.matrix)))

})

test_that("prey counts do not exceed feasible prey", {

  webs <- powerlaw_prey(edgelist, n_samp = 5)

  max_possible <- table(edgelist$taxon_consumer)

  for (web in webs) {

    web <- as.data.frame(web)
    colnames(web) <- c("resource","consumer")

    realised <- table(factor(web$consumer, levels = names(max_possible)))

    expect_true(all(realised <= max_possible))
  }

})
