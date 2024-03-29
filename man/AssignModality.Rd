% Generated by roxygen2: do not edit by hand
% Please edit documentation in
%   R/Script_PLATE_06_MODALITY_ANALYSIS_1_AssignModality.R
\name{AssignModality}
\alias{AssignModality}
\title{Assign modalities}
\usage{
AssignModality(
  MarvelObject,
  sample.ids,
  min.cells = 25,
  sigma.sq = 0.001,
  bimodal.adjust = TRUE,
  bimodal.adjust.fc = 3,
  bimodal.adjust.diff = 50,
  seed = 1,
  tran_ids = NULL
)
}
\arguments{
\item{MarvelObject}{Marvel object. S3 object generated from \code{TransformExpValues} function.}

\item{sample.ids}{Vector of character strings. Sample IDs that constitute the cell group.}

\item{min.cells}{Numeric value. The minimum no. of cells expressing the splicing event for the event to be included for modality assignment.}

\item{sigma.sq}{Numeric value. The variance threshold below which the included/excluded modality will be defined as primary sub-modality, and above which it will be defined as dispersed sub-modality.}

\item{bimodal.adjust}{Logical. When set to \code{TRUE}, MARVEL will identify false bimodal modalities and reassign them as included/excluded modality.}

\item{bimodal.adjust.fc}{Numeric value. The ratio between the proportion of cells with >0.75 PSI vs <0.25 PSI (and vice versa) below which the splicing event will be classified as bimodal. Only applicable when \code{bimodal.adjust} set to \code{TRUE}. To be used in conjunction with \code{bimodal.adjust.diff}.}

\item{bimodal.adjust.diff}{Numeric value. The difference between the percentage of cells with >0.75 PSI vs <0.25 PSI (and vice versa) below which the splicing event will be classified as bimodal. Only applicable when \code{bimodal.adjust} set to \code{TRUE}. To be used in conjunction with \code{bimodal.adjust.fc}.}

\item{seed}{Numeric value. Ensure the \code{fitdist} function returns the same values for alpha and beta paramters each time this function is executed using the same random number generator.}

\item{tran_ids}{Character strings. Specific vector of transcript IDs for modality assignment. This will be a subset of all transcripts expressed in sufficient number of cells as defined in \code{min.cells} option.}
}
\value{
An object of class S3 containing with new slot \code{MarvelObject$Modality$Results}.
}
\description{
Assigns modalities to each splicing event for a specified group of cells.
}
\examples{
marvel.demo <- readRDS(system.file("extdata/data", "marvel.demo.rds", package="MARVEL"))

df.pheno <- marvel.demo$SplicePheno
sample.ids <- df.pheno[which(df.pheno$cell.type=="iPSC"), "sample.id"]

# Assign modality
marvel.demo <- AssignModality(MarvelObject=marvel.demo,
                              sample.ids=sample.ids,
                              min.cells=5
                              )

# Check output
head(marvel.demo$Modality$Results)
}
\author{
Sean Wen <sean.wenwx@gmail.com>
}
