% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Script_DROPLET_02_PREPROCESS_4_FilterGenes.R
\name{FilterGenes.10x}
\alias{FilterGenes.10x}
\title{Filter specific gene types}
\usage{
FilterGenes.10x(MarvelObject, gene.type = "protein_coding")
}
\arguments{
\item{MarvelObject}{Marvel object. S3 object generated from \code{AnnotateGenes.10x} function.}

\item{gene.type}{Character string. Gene type to keep. Specification should match that of GTF.}
}
\value{
An object of class S3 containing the updated slots \code{MarvelObject$gene.metadata}, \code{MarvelObject$gene.norm.matrix}, \code{MarvelObject$sj.metadata}, and \code{MarvelObject$sj.count.matrix}.
}
\description{
Retain genes of specific type, e.g., protein-coding genes.
}
\examples{

# Load un-processed MARVEL object
marvel.demo.10x.raw <- readRDS(system.file("extdata/data",
                               "marvel.demo.10x.raw.rds",
                               package="MARVEL")
                               )

# Annotate gene metadata
marvel.demo.10x <- AnnotateGenes.10x(MarvelObject=marvel.demo.10x.raw)

# Annotate junction metadata
marvel.demo.10x <- AnnotateSJ.10x(MarvelObject=marvel.demo.10x)

# Validate junctions
marvel.demo.10x <- ValidateSJ.10x(MarvelObject=marvel.demo.10x)

# Subset CDS genes
marvel.demo.10x <- FilterGenes.10x(MarvelObject=marvel.demo.10x,
                          gene.type="protein_coding"
                          )
}
