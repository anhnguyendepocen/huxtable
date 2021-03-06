
context("Object manipulation")


test_that("Object subsetting and replacement examples unchanged", {
  test_ex_same("extract-methods")
  test_ex_same("add_colnames")
  test_ex_same("cbind.huxtable")
  test_ex_same("t.huxtable")
})


test_that("Subsetting preserves rownames", {
  ht <- huxtable(a = 1:3, b = 1:3)
  rownames(ht) <- letters[1:3]
  expect_equal(rownames(ht[1:2, ]), letters[1:2])
})


test_that("Subsetting cuts rowspan and colspan", {
  ht <- hux(a = 1:3, b = 1:3, d = 1:3)
  rowspan(ht)[1, 1] <- 3
  colspan(ht)[1, 2] <- 2
  ss <- ht[1:2, 1:2]
  expect_equivalent(rowspan(ss)[1, 1], 2)
  expect_equivalent(colspan(ss)[1, 2], 1)
})


test_that("Multirow/multicol cells cannot shadow other multirow/multicol cells", {
  ht <- hux(a = 1:3, b = 1:3, d = 1:3)
  colspan(ht)[1, 2] <- 2
  expect_error(colspan(ht)[1, 1] <- 2)

  # going diagonally
  ht <- hux(a = 1:3, b = 1:3, d = 1:3)
  colspan(ht)[1, 2] <- 2
  rowspan(ht)[1, 2] <- 2
  expect_error(colspan(ht)[2, 1] <- 2)
})


test_that("Subsetting works with multirow/multicolumn cells", {
  ht <- hux(a = 1:3, b = 1:3)
  rowspan(ht)[1, 1] <- 2
  expect_silent(ht[c(1, 3), ])
})


test_that("Subset assignment of hux into hux preserves attributes", {
  ht <- hux(a = 1:3, b = 1:3, d = 1:3)
  ht2 <- hux(1:2, 3:4)
  font(ht2) <- "italic"
  expect_silent(ht[2:3, 2:3] <- ht2)
  expect_equivalent(font(ht), matrix(c(rep(NA, 4), rep("italic", 2), NA, rep("italic", 2)), 3, 3))

  ht3 <- hux(1, 1, 1)
  row_height(ht3) <- "40px"
  ht[1, ] <- ht3
  expect_equivalent(row_height(ht)[1], "40px")

  ht4 <- hux(1:3)
  col_width(ht4) <- "20px"
  ht[, 2] <- ht4
  expect_equivalent(col_width(ht)[2], "20px")

  ht5 <- hux(a = 1:3, b = 1:3, d = 1:3)
  font(ht5) <- "times"
  expect_silent(ht[] <- ht5)
  expect_equivalent(font(ht), matrix("times", 3, 3))

  ht6 <- hux(1, 2, 3)
  font(ht6) <- c("times", "arial", "times")
  expect_silent(ht[] <- ht6) # assignment with repetition
  expect_equivalent(font(ht)[1, ], c("times", "arial", "times"))
})


test_that("rbind and cbind work and copy properties", {
  ht <- hux(1:2, 1:2)
  italic(ht) <- TRUE
  bold(ht) <- TRUE
  row_height(ht) <- c("1in", "2in")
  col_width(ht) <- c("2cm", "1cm")

  expect_silent(ht_rbind <- rbind(ht, c(3, 3), copy_cell_props = TRUE))
  expect_equivalent(row_height(ht_rbind), c("1in", "2in", "2in"))
  expect_equivalent(italic(ht_rbind), matrix(TRUE, 3, 2))

  ht_rbind <- rbind(ht, c(3, 3), copy_cell_props = FALSE)
  expect_equivalent(row_height(ht_rbind), c("1in", "2in", NA))
  expect_equivalent(italic(ht_rbind)[3, ], c(FALSE, FALSE))

  ht_rbind <- rbind(ht, c(3, 3), copy_cell_props = "bold")
  expect_equivalent(italic(ht_rbind)[3, ], c(FALSE, FALSE))
  expect_equivalent(bold(ht_rbind)[3, ], c(TRUE, TRUE))

  expect_silent(ht_cbind <- cbind(ht, 1:2, copy_cell_props = TRUE))
  expect_equivalent(col_width(ht_cbind), c("2cm", "1cm", "1cm"))
  expect_equivalent(italic(ht_cbind), matrix(TRUE, 2, 3))

  ht_cbind <- cbind(ht, 1:2, copy_cell_props = FALSE)
  expect_equivalent(col_width(ht_cbind), c("2cm", "1cm", NA))
  expect_equivalent(italic(ht_cbind)[, 3], c(FALSE, FALSE))

  ht_cbind <- cbind(ht, 1:2, copy_cell_props = "bold")
  expect_equivalent(italic(ht_cbind)[, 3], c(FALSE, FALSE))
  expect_equivalent(bold(ht_cbind)[, 3], c(TRUE, TRUE))
})


test_that("rbind and cbind make numeric row_height/col_width sum to 1", {
  ht <- hux(1:2, 1:2)
  ht2 <- hux(1:2, 1:2)
  row_height(ht) <- c(.5, .5)
  row_height(ht2) <- c(.5, .5)
  col_width(ht) <- c(.5, .5)
  col_width(ht2) <- c(.5, .5)

  ht_cbind <- cbind(ht, ht2)
  expect_equivalent(col_width(ht_cbind), rep(.25, 4))
  ht_rbind <- rbind(ht, ht2)
  expect_equivalent(row_height(ht_rbind), rep(.25, 4))
})


test_that("Column names are not uglified", {
  ht <- hux("A long column name" = 1:3, "Another name" = 1:3, add_colnames = TRUE)
  expect_match(to_screen(ht), "A long column name", fixed = TRUE, all = FALSE)
  ht <- hux("A long column name" = 1:3, "Another name" = 1:3, add_colnames = FALSE)
  ht <- huxtable::add_colnames(ht)
  expect_match(to_screen(ht), "A long column name", fixed = TRUE, all = FALSE)
})


test_that("Huxtables can be transposed", {
  ht <- huxtable(Alphabet = LETTERS[1:4], Month = month.name[1:4])
  rowspan(ht)[1, 1] <- 2
  colspan(ht)[3, 1] <- 2
  font(ht)[2, 1] <- "italic"
  caption(ht) <- "A caption"
  expect_silent(trans <- t(ht))
  expect_equivalent(rowspan(trans)[1, 1], 1)
  expect_equivalent(colspan(trans)[1, 1], 2)
  expect_equivalent(rowspan(trans)[1, 3], 2)
  expect_equivalent(colspan(trans)[1, 3], 1)
  expect_equivalent(font(trans), matrix(c(rep(NA, 2), "italic", rep(NA, 5)), 2, 4))
  expect_equivalent(caption(trans), "A caption")
})


test_that("add_colnames works with as_hux for matrices", {
  mat <- matrix(1:4, 2, 2, dimnames = list(letters[1:2], LETTERS[1:2]))
  ht <- as_hux(mat, add_colnames = TRUE, add_rownames = TRUE)
  expect_equivalent(ht[1, 2:3], colnames(mat))
  expect_equivalent(ht$rownames[2:3], rownames(mat))
})


test_that("add_colnames does not screw up dates and similar", {
  date_str <- rep("2015/05/05 12:00", 2)
  dfr <- data.frame(
          date    = as.Date(date_str),
          POSIXct = as.POSIXct(date_str),
          POSIXlt = as.POSIXlt(date_str)
        )
  ht <- as_hux(dfr, add_colnames = TRUE)
  ht2 <- add_colnames(as_hux(dfr, add_colnames = FALSE))
  for (h in list(ht, ht2)) for (col in colnames(dfr)) {
    expect_match(to_screen(h[, col]), "2015-05-05")
  }
})

test_that("add_footnote works", {
  ht_orig <- hux(a = 1:2, b = 1:2)
  ht_orig <- add_footnote(ht_orig, "Some footnote text", italic = TRUE)
  expect_equivalent(nrow(ht_orig), 3)
  expect_equivalent(colspan(ht_orig)[3, 1], ncol(ht_orig))
  expect_true(italic(ht_orig)[3, 1])
})


test_that("insert_column and insert_row work", {
  ht_orig <- hux(a = 1:2, b = 1:2)
  ht <- insert_row(ht_orig, 8, 9)
  expect_equivalent(nrow(ht), 3)
  expect_equivalent(ht[1, 2], 9)

  ht <- insert_row(ht_orig, 8, 9, after = 1)
  expect_equivalent(nrow(ht), 3)
  expect_equivalent(ht[, 2], huxtable(b = c(1, 9, 2)))

  ht <- insert_column(ht_orig, 8, 9)
  expect_equivalent(ncol(ht), 3)
  expect_equivalent(ht[2, 1], 9)

  ht <- insert_column(ht_orig, 8, 9, after = 1)
  expect_equivalent(ncol(ht), 3)
  expect_equivalent(ht[1, ], huxtable(a = 1, 8, b = 1))

  bold(ht_orig) <- TRUE
  ht <- insert_column(ht_orig, 8, 9, after = 1)
  expect_true(bold(ht)[1, 2])
  ht <- insert_column(ht_orig, 8, 9, after = 1, copy_cell_props = FALSE)
  expect_false(bold(ht)[1, 2])
})


test_that("insert_column works with column names", {
  ht_orig <- hux(a = 1:2, b = 1:2)
  ht <- insert_column(ht_orig, 8, 9, after = "a")
  expect_equivalent(ncol(ht), 3)
  expect_equivalent(ht[, 2], huxtable(8:9))
})


test_that("add_rows and add_columns work", {
  ht <- hux(a = 1:2, b = 1:2, add_colnames = FALSE)
  expect_silent(res <- add_rows(ht, 3:4))
  expect_equivalent(nrow(res), 3)
  expect_equivalent(res[[3, 1]], 3)
  expect_silent(res <- add_rows(ht, 3:4, after = 0))
  expect_equivalent(nrow(res), 3)
  expect_equivalent(res[[1, 1]], 3)

  mx <- matrix(3:6, 2, 2)
  hx2 <- hux(3:4, 5:6)
  for (obj in list(mx, hx2)) {
    expect_silent(res <- add_rows(ht, obj))
    expect_equivalent(res[[4, 2]], 6)
    expect_equivalent(nrow(res), 4)
    expect_silent(res <- add_rows(ht, obj, after = 1))
    expect_equivalent(nrow(res), 4)
    expect_equivalent(res[[3, 2]], 6)
    expect_silent(res <- add_columns(ht, obj, after = "a"))
    expect_equivalent(ncol(res), 4)
    expect_equivalent(res[[1, 2]], 3)
  }

  bold(ht) <- TRUE
  expect_silent(res <- add_rows(ht, mx, copy_cell_props = TRUE))
  expect_true(bold(res)[3, 1])
})


test_that("add_columns and add_rows work with data frames", {
  ht <- hux(a = 1:2, b = 1:2, add_colnames = FALSE)
  bold(ht) <- TRUE
  dfr <- data.frame(a = 1:2, b = 1:2)
  expect_silent(res <- add_rows(ht, dfr))
  expect_equivalent(nrow(res), 4)
  expect_equivalent(bold(res)[3, 1], TRUE)

  dfr <- data.frame(c = 1:2, d = 1:2)
  expect_silent(res <- add_columns(ht, dfr))
  expect_equivalent(ncol(res), 4)
  expect_equivalent(bold(res)[1, 3], TRUE)
})


test_that("Can add a column to a huxtable using standard replacement methods", {
  ht <- hux(a = 1:2, b = 1:2)
  expect_silent(ht$c <- 1:2)
  expect_equivalent(font(ht), matrix(NA, 2, 3))
  expect_equivalent(colnames(ht), c("a", "b", "c"))
  expect_equivalent(col_width(ht), rep(NA, 3))

  ht2 <- hux(a = 1:2, b = 1:2)
  expect_silent(ht2[, "c"] <- 1:2)
  expect_equivalent(font(ht2), matrix(NA, 2, 3))
  expect_equivalent(colnames(ht2), c("a", "b", "c"))
  expect_equivalent(col_width(ht2), rep(NA, 3))

  ht3 <- hux(a = 1:2, b = 1:2)
  expect_silent(ht3[["c"]] <- 1:2)
  expect_equivalent(font(ht3), matrix(NA, 2, 3))
  expect_equivalent(colnames(ht3), c("a", "b", "c"))
  expect_equivalent(col_width(ht3), rep(NA, 3))
})


test_that("Can delete columns from a huxtable by setting it to `NULL`", {
  ht <- hux(a = 1:2, b = 1:2)
  expect_silent(ht$a <- NULL)
  expect_equivalent(font(ht), matrix(NA, 2, 1))
  expect_equivalent(col_width(ht), NA)

  ht2 <- hux(a = 1:2, b = 1:2)
  expect_silent(ht2[["a"]] <- NULL)
  expect_equivalent(font(ht2), matrix(NA, 2, 1))
  expect_equivalent(col_width(ht2), NA)

  ht3 <- hux(a = 1:2, b = 1:2)
  expect_silent(ht3["a"] <- NULL)
  expect_equivalent(font(ht3), matrix(NA, 2, 1))
  expect_equivalent(col_width(ht3), NA)

  # this kind of subsetting doesn't seem to work in earlier Rs
  if (getRversion() >= "3.3.3") {
    ht4 <- hux(a = 1:2, b = 1:2, c = 1:2)
    expect_silent(ht4[ c("a", "b")] <- NULL)
    expect_equivalent(font(ht4), matrix(NA, 2, 1))
    expect_equivalent(col_width(ht4), NA)

    ht5 <- hux(a = 1:2, b = 1:2, c = 1:2)
    expect_silent(ht5[, c("a", "b")] <- NULL)
    expect_equivalent(font(ht5), matrix(NA, 2, 1))
    expect_equivalent(col_width(ht5), NA)
  }

})


test_that("Can add row(s) to a huxtable by standard replacement methods", {
  ht <- hux(a = 1:2, b = 1:2)
  expect_silent(ht[3, ] <- c(3, 3))
  expect_equivalent(font(ht), matrix(NA, 3, 2))
  expect_equivalent(row_height(ht), rep(NA, 3))

  expect_silent(ht[4, 1] <- 4)
  expect_equivalent(as.data.frame(ht[4, ]), data.frame(4, NA_real_))
  expect_equivalent(dim(font(ht)), c(4, 2))

  expect_silent(ht[5:6, ] <- 5:6)
  expect_equivalent(as.data.frame(ht[5:6, ]), data.frame(5:6, 5:6))
  expect_equivalent(dim(font(ht)), c(6, 2))

  ht2 <- hux(a = 1:2, b = 1:2)
  expect_silent(ht2[, 3:4] <- 1:2)
  expect_equivalent(as.data.frame(ht2[, 3:4]), data.frame(1:2, 1:2))
  expect_equivalent(dim(font(ht2)), c(2, 4))

  expect_silent(ht2[, 4:5] <- 3:4) # overlapping existing
  expect_equivalent(as.data.frame(ht2[, 4:5]), data.frame(3:4, 3:4))
  expect_equivalent(dim(font(ht2)), c(2, 5))

  ht3 <- hux(a = 1:2, b = 1:2)
  expect_silent(ht3[3:4, 3] <- 1) # new rows and columns simultaneously
  expect_equivalent(as.data.frame(ht3[3:4, ]), data.frame(rep(NA_real_, 2), rep(NA_real_, 2), rep(1, 2)))
  expect_equivalent(dim(font(ht3)), c(4, 3))
})


test_that("cbind and rbind work with 0-dimension objects", {
  ht <- hux(a = 1:2, b = 1:2)
  expect_silent(ht_nrow0 <- ht[FALSE, ])
  expect_silent(ht_ncol0 <- ht[, FALSE])

  expect_silent(res <- cbind(ht, ht_ncol0))
  expect_equivalent(dim(res), c(2, 2))
  expect_silent(res <- cbind(ht_ncol0, ht))
  expect_equivalent(dim(res), c(2, 2))

  expect_silent(res <- rbind(ht, ht_nrow0))
  expect_equivalent(dim(res), c(2, 2))
  expect_silent(res <- rbind(ht_nrow0, ht))
  expect_equivalent(dim(res), c(2, 2))

  mx <- matrix(1:4, 2, 2)
  mx_nrow0 <- mx[FALSE, ]
  mx_ncol0 <- mx[, FALSE]

  expect_silent(res <- cbind(ht, mx_ncol0))
  expect_equivalent(dim(res), c(2, 2))
  expect_silent(res <- cbind(mx_ncol0, ht))
  expect_equivalent(dim(res), c(2, 2))

  expect_silent(res <- rbind(ht, mx_nrow0))
  expect_equivalent(dim(res), c(2, 2))
  expect_silent(res <- rbind(mx_nrow0, ht))
  expect_equivalent(dim(res), c(2, 2))
})
