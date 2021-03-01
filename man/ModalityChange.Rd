% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Script_03_5_CompareValues_ModalityChange.R
\name{ModalityChange}
\alias{ModalityChange}
\title{Classify Modality Changes}
\usage{
ModalityChange(MarvelObject, psi.de.sig, cell.types, n.cells, sigma.sq,
  bimodal.adjust, seed, modality.column)
}
\arguments{
\item{MarvelObject}{S3 object generated from \code{CompareValues} function.}

\item{psi.de.sig}{Numeric value. Adjusted p-value below which the splicing event is considered differentially spliced and included for isoform switching analysis.}

\item{cell.types}{Character string. To indicate which 2 groups of cells that will be used for differential splicing analysis. Group names should match those in \code{cell.type} column of \code{$SplicePheno} slot.}

\item{n.cells}{Numeric value. The minimum no. of cells expressing the splicing event for the event to be included for differential splicing analysis. Please refer to \code{AssignModality} function help page for more details.}

\item{sigma.sq}{Numeric value. The variance threshold below which the included/excluded modality will be defined as primary sub-modality, and above which it will be defined as dispersed sub-modality. Please refer to \code{AssignModality} function help page for more details.}

\item{bimodal.adjust}{Logical. When set to \code{TRUE}, MARVEL will identify false bimodal modalities and reassign them as included/excluded modality. Please refer to \code{AssignModality} function help page for more details.}

\item{seed}{Numeric value. Ensure the \code{fitdist} function returns the same values for alpha and beta paramters each time this function is executed using the same random number generator. Please refer to \code{AssignModality} function help page for more details.}

\item{modality.column}{Character string. Can take the value \code{"modality"}, \code{"modality.var"} or \code{"modality.bimodal.adj"}. Please refer to \code{AssignModality} function help page for more details.}
}
\value{
An object of class S3 containing all the original slots as inputted by the user in addition to three new slots named \code{$DE$Modality*}. \code{$DE$Modality} Original data frame generated from \code{CompareValues} function with an additional columns to indicate the type of modality changes that have taken place between the 2 groups of cells. \code{$DE$ModalityProp} Tabulated proportion for each type of modality change. \code{$DE$ModalityPlot} Doughnut plot representing the values in \code{$DE$ModalityProp}.
}
\description{
\code{ModalityChange} Classifies the type of modality change for each splicing event that has taken place between 2 groups of cells.
}
\details{
This function classifies the type of modality change for each splicing event that has taken place between 2 groups of cells. Explicit: When modality changes between one of the five main modalities, e.g. included to multimodal. Implicit: When modality changes between primary and dispersed sub-modalities, e.g. included-primary to included-dispersed. Restricted: No modality change, e.g. included to included.
}
\examples{
marvel <- readRDS(system.file("extdata/Data", "MarvelObject.rds", package="MARVEL"))

marvel <- ModalityChange(MarvelObject=marvel,
                         psi.de.sig=0.05,
                         cell.types=c("iPSC", "Endoderm"),
                         n.cells=25,
                         sigma.sq=0.001,
                         bimodal.adjust=TRUE,
                         seed=1,
                         modality.column="modality.bimodal.adj"
                         )

marvel$DE$ModalityProp
marvel$DE$ModalityPlot
}
\author{
Sean Wen <sean.wenwx@gmail.com>
}