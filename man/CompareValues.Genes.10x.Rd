% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Script_DROPLET_04_DE_2_Gene.R
\name{CompareValues.Genes.10x}
\alias{CompareValues.Genes.10x}
\title{Differential gene expression analysis}
\usage{
CompareValues.Genes.10x(
  MarvelObject,
  log2.transform = TRUE,
  show.progress = TRUE,
  method = "wilcox",
  mast.method = "bayesglm",
  mast.ebayes = TRUE
)
}
\arguments{
\item{MarvelObject}{Marvel object. S3 object generated from \code{CompareValues.SJ.10x} function.}

\item{log2.transform}{Logical value. If set to \code{TRUE} (default), normalised gene expression values will be off-set by 1 and then log2-transformed prior to analysis. This option is automatically set to \code{TRUE} if \code{method} option is set to \code{"mast"}.}

\item{show.progress}{Logical value. If set to \code{TRUE} (default), the progress bar will appear.}

\item{method}{Character string. Statistical test to compare the 2 groups of cells. Default is \code{"wilcox"} as recommended by Seurat. Another option is \code{"mast"}. If \code{"mast"} is specified, the log2fc and p-values will be corrected using the gene detection rate as per the \code{MAST} package tutorial.}

\item{mast.method}{Character string. As per the \code{method} option of the \code{zlm} function from the \code{MAST} package. Default is \code{"bayesglm"}, other options are \code{"glm"} and \code{"glmer"}.}

\item{mast.ebayes}{Logical value. As per the \code{ebayes} option of the \code{zlm} function from the \code{MAST} package. Default is \code{TRUE}.}
}
\value{
An object of class S3 with a updated slot \code{MarvelObject$DE$SJ$Table}.
}
\description{
Performs differential gene expression analysis between two groups of cells. Only among cells and genes previously included for splice junction analysis.
}
\examples{

marvel.demo.10x <- readRDS(system.file("extdata/data",
                               "marvel.demo.10x.rds",
                               package="MARVEL")
                               )

marvel.demo.10x <- CompareValues.Genes.10x(
                        MarvelObject=marvel.demo.10x,
                        show.progress=FALSE
                        )

# Check output
head(marvel.demo.10x$DE$SJ$Table)
}
