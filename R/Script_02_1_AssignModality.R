#' @title Modality Assignment
#'
#' @description
#' \code{AssignModality} assigns modalities to each splicing event for a specified group of cells.
#'
#' @details
#' This function assigns modalities to each splicing event for a specified group of cells. The five main modalities are included, excluded, bimodal, middle, and multimodal (inspired by Song (2017)). \code{MARVEL} further stratifies included and excluded modalities into primary and dispersed sub-modalities depending on the variance (dispersion).
#'
#' @param MarvelObject S3 object generated from \code{ComputePSI} function.
#' @param cell.type Character string. To indicate which group of cells to analyse. Group name should match that in \code{cell.type} column of \code{$SplicePheno} slot.
#' @param n.cells Numeric value. The minimum no. of cells expressing the splicing event for the event to be included for modality assignment.
#' @param sigma.sq Numeric value. The variance threshold below which the included/excluded modality will be defined as primary sub-modality, and above which it will be defined as dispersed sub-modality.
#' @param bimodal.adjust Logical. When set to \code{TRUE}, MARVEL will identify false bimodal modalities and reassign them as included/excluded modality.
#' @param seed Numeric value. Ensure the \code{fitdist} function returns the same values for alpha and beta paramters each time this function is executed using the same random number generator.
#' @export
#' @return An object of class S3 containing all the original slots as inputted by the user in addition to one new data frame. This data frame is store in \code{$Modality$Results} slot. This data frame contains the modality assignment for each splicing event and is saved into the \code{Modality} slot. \code{modality} column reflects the five main modalities, i.e. included, excluded, bimodal, middle, and multimodal. \code{modality.var} column additional stratifies included and excluded modalities into primary and dispersed sub-modalities. \code{modality.bimodal.adj} column identifies and re-categorizes false bimodals into included or excluded modalities when \code{bimodal.adjust} is set to \code{TRUE}.
#' @author Sean Wen <sean.wenwx@gmail.com>
#' @importFrom fitdistrplus fitdist
#' @import methods
#' @examples
#' marvel <- readRDS(system.file("extdata/Data", "MarvelObject.rds", package="MARVEL"))
#'
#' marvel <- AssignModality(MarvelObject=marvel,
#'                          cell.type=c("iPSC", "Endoderm"),
#'                          n.cells=25,
#'                          sigma.sq=0.001,
#'                          bimodal.adjust=TRUE,
#'                          seed=1)
#'
#' marvel$Modality$Results[1:5, ]

AssignModality <- function(MarvelObject, cell.type, n.cells, sigma.sq, bimodal.adjust, seed) {

    # Define arguments
    psi <- do.call(rbind.data.frame, MarvelObject$PSI)
    psi.feature <- do.call(rbind.data.frame, MarvelObject$SpliceFeatureValidated)
    psi.pheno <- MarvelObject$SplicePheno
    
    #psi <- do.call(rbind.data.frame, marvel$PSI)
    #psi.feature <- do.call(rbind.data.frame, marvel$SpliceFeatureValidated)
    #psi.pheno <- marvel$SplicePheno
    #cell.type <- "Endoderm"
    #n.cells <- 25
    #sigma.sq <- 0.001
    #bimodal.adjust <- TRUE
    #seed <- 1
    
    # Generate row names
    row.names(psi) <- psi$tran_id
    psi$tran_id <- NULL

    # Subset overlapping samples in matrix and pheno file
    psi <- psi[, which(names(psi) %in% psi.pheno$sample.id)]
    
    # Subset sample type
    psi.pheno <- psi.pheno[which(psi.pheno$cell.type %in% cell.type), ]
    psi <- psi[, which(names(psi) %in% psi.pheno$sample.id)]

    # Subset events with sufficient cells
    . <- apply(psi, 1, function(x) {sum(!is.na(x))})
    index.keep <- . >= n.cells
    psi <- psi[index.keep, , drop=FALSE]
    psi.feature <- psi.feature[index.keep, , drop=FALSE]
    
    # Compute num. of cells analysed
    n.cells <- apply(psi, 1, function(x) {sum(!is.na(x))})
    psi.feature$n.cells <- n.cells
    
    # Check if matrix column and rows align with metadata
        # Column
        index.check <- which(unique((names(psi)==psi.pheno$sample.id))==FALSE)
        
        if(length(index.check)==0) {
            
            print("Checking... Matrix column (sample) names match sample metadata")
            
        } else {
            
            print("Checking... Matrix column (sample) names DO NOT match sample metadata")
            
        }
        
        # Row
        index.check <- which(unique((row.names(psi)==psi.feature$tran_id))==FALSE)
        
        if(length(index.check)==0) {
            
            print("Checking... Matrix row (feature) names match feature metadata")
            
        } else {
            
            print("Checking... Matrix row (feature) names DO NOT match feature metadata")
            
        }
       
    # Retrieve parameters
        # Define function
        estbetaParams <- function(x) {

            # Convert to numeric
            values <- as.numeric(x)
            
            # Remove missing values
            values <- values[!is.na(values)]
            
            # Round off values
            #values <- round(values, digits=4)
            
            # Jitter exact values
            set.seed(seed)
            values[values==1 & !is.na(values)] <- runif(sum(values==1, na.rm=TRUE), min=0.98, max=0.9999)
            values[values==0 & !is.na(values)] <- runif(sum(values==0, na.rm=TRUE), min=0.0001, max=0.02)
                                        
            # Build model
            #model <- fitdist(data=values, distr="beta", method="mle")
            model <- tryCatch(fitdist(data=values, distr="beta", method="mle"), error=function(err) "Error")
            
            # Retrieve parameters and log-likelihood
            if(class(model) == "fitdist") {
            
                alpha <- model$estimate[1]
                beta <- model$estimate[2]
                log.likelihood <- summary(model)$loglik
                variance <- var(values)
                params <- list(alpha=alpha, beta=beta, log.likelihood=log.likelihood, variance=variance)
                return(params)
                
            } else  {
            
                alpha <- NA
                beta <- NA
                log.likelihood <- NA
                variance <- NA
                params <- list(alpha=alpha, beta=beta, log.likelihood=log.likelihood, variance=variance)
                return(params)
            
            }
            
        }

        # Retrieve parameters
        param <- apply(psi, 1, estbetaParams)
            
        # For debugging
        #param <- NULL
        
        #for(i in 1:nrow(psi)) {
                   
           #param[[i]] <- estbetaParams(na.omit(as.numeric(psi[i,])))
           
           #print(i)
           
           
        #}
        
        #values <- as.numeric(psi[4397,])

        # Annotate parameters
        psi.feature$alpha <- as.numeric(sapply(param, function(x) {x[1]}))
        psi.feature$beta <- as.numeric(sapply(param, function(x) {x[2]}))
        psi.feature$log.likelihood <- as.numeric(sapply(param, function(x) {x[3]}))
        psi.feature$variance <- as.numeric(sapply(param, function(x) {x[4]}))

    # Assign modalities
        # Create new column
        psi.feature$modality <- NA
        
        # Indicate missing values
        psi.feature$modality[which(is.na(psi.feature$alpha))] <- "Missing"
        
        # Bimodal
        psi.feature$modality[which(is.na(psi.feature$modality) &
                                   (psi.feature$alpha <= 0.4 | psi.feature$beta <= 0.4)
                                   )] <- "Bimodal"
        
        # Included (alpha > 2, beta < 1)
        psi.feature$modality[which(is.na(psi.feature$modality) &
                                   psi.feature$alpha >= 2.0 &
                                   psi.feature$beta <= 1
                                   )] <- "Included"
        
        # Included (by FC)
        psi.feature$modality[which(is.na(psi.feature$modality) &
                                   (psi.feature$alpha/psi.feature$beta) > 2.0
                                   )] <- "Included"
        
        # Included (beta > 2, alpha < 1)
        psi.feature$modality[which(is.na(psi.feature$modality) &
                                   psi.feature$beta >= 2.0 &
                                   psi.feature$alpha <= 1
                                   )] <- "Excluded"
                                   
        # Excluded (by FC)
        psi.feature$modality[which(is.na(psi.feature$modality) &
                                   (psi.feature$beta/psi.feature$alpha) > 2.0
                                   )] <- "Excluded"

            
        # Middle
        psi.feature$modality[which(is.na(psi.feature$modality) &
                                   psi.feature$alpha >= 1.6 &
                                   psi.feature$beta >= 1.6
                                   )] <- "Middle"
                                   
        # Multimodal
        psi.feature$modality[which(is.na(psi.feature$modality))] <- "Multimodal"
        

    # Further stratify included and excluded modalities
        # Create new column for new modality
        psi.feature$modality.var <- NA
        
        # Indicate missing values
        psi.feature$modality.var[which(is.na(psi.feature$alpha))] <- "Missing"
        
        # Included
        psi.feature$modality.var[which(is.na(psi.feature$modality.var) &
                                           psi.feature$variance <= sigma.sq &
                                           psi.feature$modality=="Included"
                                           )] <- "Included.Primary"
        
        
        psi.feature$modality.var[which(is.na(psi.feature$modality.var) &
                                           psi.feature$modality=="Included"
                                           )] <- "Included.Dispersed"
        
        # Excluded
        psi.feature$modality.var[which(is.na(psi.feature$modality.var) &
                                           psi.feature$variance <= sigma.sq &
                                           psi.feature$modality=="Excluded"
                                           )] <- "Excluded.Primary"
        
        
        psi.feature$modality.var[which(is.na(psi.feature$modality.var) &
                                           psi.feature$modality=="Excluded"
                                           )] <- "Excluded.Dispersed"

        # Non-included/excluded
        psi.feature$modality.var[which(is.na(psi.feature$modality.var))] <-
        psi.feature$modality[which(is.na(psi.feature$modality.var))]
        
        ########################################################################
        ############################ BIMODAL ADJUST ############################
        ########################################################################
        
        if(length(which(psi.feature$modality.var=="Bimodal")) != 0) {
        
            if(bimodal.adjust==TRUE) {
            
                # Compute feature
                pct.lower <- apply(psi, 1, function(x) {sum(x[which(!is.na(x))] < 0.25) / length(x[which(!is.na(x))]) * 100})
                pct.higher <- apply(psi, 1, function(x) {sum(x[which(!is.na(x))] > 0.75) / length(x[which(!is.na(x))]) * 100})
                psi.feature$pct.fc <- ifelse(pct.higher > pct.lower, pct.higher/pct.lower, pct.lower/pct.higher)
                psi.feature$pct.diff <- ifelse(pct.higher > pct.lower, pct.higher - pct.lower, pct.lower - pct.higher)
                psi.feature$psi.average <- apply(psi, 1, function(x) {mean(x[which(!is.na(x))])})
                
                # Split into bimodal/non-bimodal
                bi <- psi.feature[which(psi.feature$modality.var=="Bimodal"), ]
                non.bi <- psi.feature[which(psi.feature$modality.var!="Bimodal"), ]
                
                # Annotate true/false bimodal (MOST IMPORTANT STEP)
                bi$bimodal.class <- ifelse( bi$alpha <= 0.4 & bi$beta <= 0.4 &
                                            bi$pct.fc <= 3.0 &
                                            bi$pct.diff <= 45
                                            , "pass", "fail"
                                            )
                
                # Reclassify false bimodals
                if(length(which(bi$bimodal.class=="fail")) != 0) {
                
                    # Subset false bimodals
                    bi.fail <- bi[which(bi$bimodal.class=="fail"), ]
                    
                    # Assign modalities
                    bi.fail$modality.bimodal.adj <- NA
                
                    # Included
                    bi.fail$modality.bimodal.adj[which(bi.fail$psi.average > 0.5 &
                                                       bi.fail$variance <= sigma.sq
                                                       )] <- "Included.Primary"
                    
                    bi.fail$modality.bimodal.adj[which(is.na(bi.fail$modality.bimodal.adj) &
                                                     bi.fail$psi.average > 0.5
                                                     )] <- "Included.Dispersed"
                                                                        
                    # Excluded
                    bi.fail$modality.bimodal.adj[which(is.na(bi.fail$modality.bimodal.adj) &
                                                       bi.fail$psi.average < 0.5 &
                                                       bi.fail$variance <= sigma.sq
                                                       )] <- "Excluded.Primary"
                    
                    bi.fail$modality.bimodal.adj[which(is.na(bi.fail$modality.bimodal.adj) &
                                                     bi.fail$psi.average < 0.5
                                                     )] <- "Excluded.Dispersed"
                                                                                                        
                # Merge bi-pass/fail
                    # Format bi-pass columns to match bi-fail
                    bi.pass <- bi[which(bi$bimodal.class=="pass"), ]
                    bi.pass$modality.bimodal.adj <- bi.pass$modality.var
                    
                    # Merge
                    bi <- rbind.data.frame(bi.pass, bi.fail)
                
            }
            
            # Merge bi/non-bi
                if(nrow(non.bi) != 0) {
                    
                    # Format non-bi columns to match bi
                    non.bi$bimodal.class <- NA
                    non.bi$modality.bimodal.adj <- non.bi$modality.var
                    
                    # Merge
                    psi.feature <- rbind.data.frame(bi, non.bi)
                    
                    # Reorder as per psi data frame
                    row.names(psi.feature) <- psi.feature$tran_id
                    psi.feature <- psi.feature[row.names(psi), ]
                    row.names(psi.feature) <- NULL
                    
                } else {
                    
                    # Merge
                    psi.feature <- bi
                    
                    # Reorder as per psi data frame
                    row.names(psi.feature) <- psi.feature$tran_id
                    psi.feature <- psi.feature[row.names(psi), ]
                    row.names(psi.feature) <- NULL
                    
                }
            
            }
                
        }
    
    # Recode missing values
    if(length(names(psi.feature)[which(names(psi.feature)=="modality.bimodal.adj")]) == 0) {
        
            # Special case: 1 row only, bimodal=pass
            
            psi.feature$modality.bimodal.adj <- psi.feature$modality.var
        
        } else {
            
            # Normal cases
            psi.feature$modality[which(psi.feature$modality=="Missing")] <- NA
            psi.feature$modality.var[which(psi.feature$modality.var=="Missing")] <- NA
            
            if(bimodal.adjust==TRUE & length(which(psi.feature$modality.var=="Bimodal")) == 0) {
            
                psi.feature$modality.bimodal.adj <- psi.feature$modality.var
            
            } else {
                
                psi.feature$modality.bimodal.adj[which(psi.feature$modality.bimodal.adj=="Missing")] <- NA
                
            }
        
    }
    
    # Remove intermediate columns
    psi.feature$alpha <- NULL
    psi.feature$beta <- NULL
    psi.feature$log.likelihood <- NULL
    psi.feature$variance <- NULL
    psi.feature$pct.fc <- NULL
    psi.feature$pct.diff <- NULL
    psi.feature$psi.average <- NULL
    psi.feature$bimodal.class <- NULL
    
    # Save to new slots
    MarvelObject$Modality$Results <- psi.feature
    
    return(MarvelObject)
            
}
