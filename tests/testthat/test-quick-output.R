
context("quick_xxx functions")


test_that("Quick output functions create files", {
  skip_if_not_installed("openxlsx")
  skip_if_not_installed("flextable")

  ht <- hux(a = 1:2, b = 1:2)
  m <- matrix(1:4, 2, 2)
  dfr <- data.frame(a = 1:5, b = 1:5)

  tf <- tempfile(fileext = ".htm")
  expect_silent(quick_html(m, dfr, ht, file = tf, open = FALSE))
  expect_true(file.exists(tf))

  tf <- tempfile(fileext = ".docx")
  expect_silent(quick_docx(m, dfr, ht, file = tf, open = FALSE))
  expect_true(file.exists(tf))

  tf <- tempfile(fileext = ".xlsx")
  expect_silent(quick_xlsx(m, dfr, ht, file = tf, open = FALSE))
  expect_true(file.exists(tf))

  tf <- tempfile(fileext = ".pptx")
  expect_silent(quick_pptx(m, dfr, ht, file = tf, open = FALSE))
  expect_true(file.exists(tf))

  tf <- tempfile(fileext = ".rtf")
  expect_silent(quick_rtf(m, dfr, ht, file = tf, open = FALSE))
  expect_true(file.exists(tf))
})


test_that("quick_pdf works", {
  skip_on_appveyor()
  ht <- hux(a = 1:2, b = 1:2)
  m <- matrix(1:4, 2, 2)
  dfr <- data.frame(a = 1:5, b = 1:5)
  tf <- tempfile(fileext = ".pdf")
  expect_silent(quick_pdf(m, dfr, ht, file = tf))
  expect_true(file.exists(tf))
})


test_that("quick_pdf works with height and width options", {
  skip_on_appveyor()
  ht <- hux(a = 1:2, b = 1:2)
  m <- matrix(1:4, 2, 2)
  dfr <- data.frame(a = 1:5, b = 1:5)

  tf <- tempfile(fileext = ".pdf")
  expect_silent(quick_pdf(m, dfr, ht, file = tf, height = "4in"))
  expect_true(file.exists(tf))

  tf <- tempfile(fileext = ".pdf")
  expect_silent(quick_pdf(m, dfr, ht, file = tf, width = "4in"))
  expect_true(file.exists(tf))

  tf <- tempfile(fileext = ".pdf")
  expect_silent(quick_pdf(m, dfr, ht, file = tf, height = "4in", width = "4in"))
  expect_true(file.exists(tf))
})

test_that("Quick output functions stop if called non-interactively with no `file` argument", {
  skip_if(interactive())

  ht <- hux(a = 1:2, b = 1:2)
  expect_error(quick_html(ht))
  expect_false(file.exists("huxtable-output.html"))
})
