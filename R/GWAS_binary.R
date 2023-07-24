#' GWAS_binary function
#' This function performs GWAS using plink2 and outputs the GWAS summary statistics with additive SNP effects. It is recommended to save the output in a user-specified file (see example).
#' @param plink_path Path to the PLINK executable application
#' @param b_file Prefix of the binary files, where all .fam, .bed and .bim files have a common prefix
#' @param Bphe_discovery Name (with file extension) of the phenotype file containing family ID, individual ID and phenotype of the discovery dataset as columns, without heading
#' @param Bcov_discovery Name (with file extension) of the covariate file containing family ID, individual ID, standardized covariate, square of standardized covariate, and/or confounders of the discovery dataset as columns, without heading
#' @param thread Number of threads used
#' @keywords gwas
#' @export 
#' @importFrom stats binomial fitted.values glm lm 
#' @importFrom utils read.table 
#' @return This function will perform GWAS and output
#' \item{B_out.trd.sum}{GWAS summary statistics with additive SNP effects}
#' @examples \dontrun{
#' x <- GWAS_binary(plink_path, DummyData, Bphe_discovery, Bcov_discovery, 
#' thread = 20)
#' sink("B_out.trd.sum") #to create a file in the working directory
#' write.table(x, sep = " ", row.names = FALSE, quote = FALSE) #to write the output
#' sink() #to save the output
#' head(x) #to obtain the head of GWAS summary statistics of additive SNP effects
#' x$V1 #to extract the chromosome number (CHROM)
#' x$V2 #to extract the base pair position (POS)
#' x$V3 #to extract the SNP ID (ID)
#' x$V4 #to extract the reference allele (REF)
#' x$V5 #to extract the alternate allele (ALT)
#' x$V6 #to extract the minor allele (A1)
#' x$V7 #to extract whether firth regression is used (FIRTH?)
#' x$V8 #to extract the type of test performed (TEST)
#' x$V9 #to extract the nmber of allele observations (OBS_CT)
#' x$V10 #to extract the odds ration of the SNP effect (OR)
#' x$V11 #to extract the standard error of log odds (LOG(OR)_SE)
#' x$V12 #to extract the test statistic (Z_STAT)
#' x$V13 #to extract the p value (P)
#' x$V14 #to extract the error code (ERRCODE)
#' }
GWAS_binary <- function(plink_path, b_file, Bphe_discovery, Bcov_discovery, thread = 20){  
  cov_file <- read.table(Bcov_discovery)
  n_confounders = ncol(cov_file) - 4
  if(n_confounders > 0){
    parameters <- c(1, (1:n_confounders)+3)
  }
  else{
    parameters <- 1
  }
  param_vec <- paste0(parameters, collapse = ", ")
  runPLINK <- function(PLINKoptions = "") system(paste(plink_path, PLINKoptions))
  log_file <- runPLINK(paste0(" --bfile ", b_file, 
                  " --glm --pheno ", 
                  Bphe_discovery, 
                  " --covar ", Bcov_discovery, 
                  " --parameters ", param_vec, 
                  " --allow-no-sex --threads ", 
                  thread,
                  " --out ", tempdir(),"/B_gwas"))
  plink_output <- read.table(paste0(tempdir(), "/B_gwas.PHENO1.glm.logistic.hybrid"), header = FALSE)
  filtered_output <- plink_output[(plink_output$V8=="ADD"),]
  filtered_output$V10 = log(filtered_output$V10)
  B_out.trd.sum <- filtered_output
  return(B_out.trd.sum)
}