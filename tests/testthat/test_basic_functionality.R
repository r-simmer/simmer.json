context("Basic functionality")

library(magrittr)

test_that("simple definition can be correctly loaded", {
  expect_equal(
    deserialise("definition1.json") %>% run() %>% now(),
    9)
})



test_that("branching definition can be correctly loaded", {
  expect_equal(
    deserialise("definition1.json") %>% run() %>% now(),
    9)
})
