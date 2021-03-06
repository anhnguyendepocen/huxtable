% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/properties.R
\name{row_height}
\alias{row_height}
\alias{row_height<-}
\alias{set_row_height}
\title{Row heights}
\usage{
row_height(ht)
row_height(ht) <- value
set_row_height(ht, row, value)
}
\arguments{
\item{ht}{A huxtable.}

\item{value}{A vector.}

\item{row}{A row specifier. See \link{rowspecs} for details.}
}
\value{
For \code{row_height}, the \code{row_height} property.
For \code{set_row_height}, the modified huxtable.
}
\description{
Functions to get or set the \emph{row heights} property of huxtable rows.
}
\details{
If character, \code{value} must contain valid CSS or LaTeX lengths. If numeric, in HTML, values are scaled to 1 and treated as proportions of the table height. In LaTeX, they are
treated as proportions of the text height (\code{\\textheight}).
}
\examples{

row_height(jams) <-  c(.2, .1, .1, .1)
row_height(jams)

}
\seealso{
Other row/column heights: \code{\link{col_width}}
}
\concept{row/column heights}
