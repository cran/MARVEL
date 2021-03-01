% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Script_04_2_RunPCA_Exp.R
\name{RunPCA.Exp}
\alias{RunPCA.Exp}
\title{Principle Component Analysis on Gene Expression Values}
\usage{
RunPCA.Exp(MarvelObject, cell.types, n.cells, features, point.size)
}
\arguments{
\item{MarvelObject}{S3 object generated from \code{CreateMarvelObject} or \code{ComputePSI} function.}

\item{cell.types}{Character string. To indicate which groups of cells that will be used for analysis. Group names should match those in \code{cell.type} column of \code{$GenePheno} slot.}

\item{n.cells}{Numeric value. The minimum no. of cells expressing the splicing event or gene for the event or gene, respectively, to be included for analysis.}

\item{features}{Character string. Vector of \code{gene_id}s for analysis. Should match \code{gene_id} column of \code{$GeneFeature} slot.}

\item{point.size}{Numeric value. Size of data points on reduced dimension space.}
}
\value{
An object of class S3 containing all the original slots as inputted by the user in addition to one new slot named \code{MarvelObject$PCA$Gene}. Contains both 2D scatterplot in \code{MarvelObject$PCA$Gene$Plot} and the corresponding x- and y-coordinates for each sample in \code{MarvelObject$PCA$Gene$Results}.
}
\description{
\code{RunPCA.Exp} performs principle component analysis on gene expression values.
}
\details{
This function performs principle component analysis on gene expression values and visualise cells on a reducted dimension space, i.e. 2D scatterplot.
}
\examples{

marvel <- readRDS(system.file("extdata/Data", "MarvelObject.rds", package="MARVEL"))

features <- marvel$GeneFeature$gene_id

marvel <- RunPCA.Exp(MarvelObject=marvel,
                     cell.types="all",
                     n.cells=3,
                     features=features,
                     point.size=2.5
                     )

marvel$PCA$Gene$Results
marvel$PCA$Gene$Plot
}
\author{
Sean Wen <sean.wenwx@gmail.com>
}