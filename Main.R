###############################################################################################
#Bayesian estimation of a 1D tidal river model and assessment of observational data influence # 
###############################################################################################
#                                                                                             #   
# Main author:   Felipe Alberto MENDEZ RIOS                                                   #
# Institute:     INRAE Lyon UR RiverLy, France                                                #
# Year:          2023                                                                         #
# version:       v.1.0.0                                                                      #
#                                                                                             #
#                                                                                             #
#---------------------------------------------------------------------------------------------#
#                             Main objective of the program                                   #
#---------------------------------------------------------------------------------------------#
# This program performs the automatic calibration of a 1D hydraulic model taking as parameters#
# the friction coefficients by reach, along with uncertainties                                #
#---------------------------------------------------------------------------------------------#
#                                   Acknowledgements                                          #
#---------------------------------------------------------------------------------------------#
# This program has been written under the supervision of:                                     #
#                            Benjamin Renard (INRAE)                                          #
#                            Jerome Le Coz (INRAE)                                            #
# The code makes use of:                                                                      #
#                            "DMSL" package of prof. Dmitri Kavetski                          #
#                            "BaM.exe" software developed by Benjamin Renard, INRAE           #
#                            Mage 1D hydraulic model developed by Jean-Baptiste Faure, INRAE  #
#                                                                                             #
# Project funded by:                                                                          #
#                            SCHAPI (France)                                                  #
#                            INRAE (France)                                                   #
#                                                                                             #
#---------------------------------------------------------------------------------------------#
#                             This is the "Main" program file!                                #
#---------------------------------------------------------------------------------------------#
# For any question or feedback please contact us at one of the following e-mails:            #
# - felipe-alberto.mendez-rios@inrae.fr                                                       #
# - jerome.lecoz@inrae.fr                                                                     #
# - benjamin.renard@inrae.fr                                                                  #
###############################################################################################





##############################################################################################
#                               INITIALIZATION    (just run the following lines)             #
##############################################################################################
# Get the main directory folder automatically:         
if(!is.null(dev.list())) dev.off() # Clear plots
cat("\014") # Clear console
rm(list=ls())# Clean workspace

#Libraries used  (it automatically detects and installs missing packages):
# options(repos = c(CRAN = "https://cran.rstudio.com"))
#Packages:
pack = c("data.table",
         "ggplot2", "RColorBrewer", "plotly", "dplyr","htmlwidgets", "tidyr", 
         "stringr",  "ggExtra", "gridExtra", "cowplot",  "grid",  "RBaM", 
         "xlsx",  "stringr", "ggpubr", "psych","svDialogs"
)
# for future versions add: "airGR", "rmarkdown"

install_pack <- function(x){
  for( i in x ){
    #  require returns TRUE invisibly if it was able to load package
    if( ! require( i , character.only = TRUE ) ){
      #  If package was not able to be loaded then re-install
      install.packages( i , dependencies = TRUE )
      #  Load package after installing
      require( i , character.only = TRUE )
    }
  }
}
#  Then try/install packages:
install_pack( pack ) 

# First use RBaM library : install the package from GitHub
# devtools::install_github('BaM-tools/RBaM') 

# set the directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))  
dir_code <- getwd()
setwd(dir_code)
# define the directory with the modules files:
dir.modules = paste0(dir_code, "/Modules")



###########################################################################
# Define the case study name (the same name of the case study folder !!!): 
# select the index of the case study folder that will appear in the popup 
# R window:
all_case_studies = list.files(paste0(dir_code, "/Case_studies"))
case_study_name <- all_case_studies[ as.numeric(
  dlgInput(c("Insert the name of case study folder: \n",
             paste0(seq(1, length(all_case_studies), 1), " = ",
                    all_case_studies)), 
           Sys.info()[" "])$res)]
# or insert the folder name manually:
#case_study_name = "Seine_aval"     
##########################################################################

##############################################################################################
#                            SOURCE ALL FUNCTIONS AVAILABLE TO CALCUL                        #
##############################################################################################   
source(paste0(dir.modules,"/Functions.R"))

dir.case_study =  paste0(dir_code,"/Case_studies/", case_study_name)  # Read folder with the case study. 

##############################################################################################
#                            READ INPUTS DATA FOR THE CASE STUDY                             #
##############################################################################################           
# Read all input data and options
source(paste0(dir.modules,"/module_read_input.R"))


##############################################################################################
#                             1) SEGMENTATION OF GAUGINGS                                    #
##############################################################################################
# Author: Matteo Darienzo, Inrae
# Last update: 15/02/2021
# Objective: detection of ruptures in the time series of residuals between gaugings and base RC
# Procedure: 
# - 1) Estimation of RC0 (rating curve of reference with quantitative uncertainty)
# - 2) Computation of residuals between gaugings and RC0
# - 3) Segmentation of the residuals time series (call of Bam-segmentation)
# - 4) Adjustment of detected shift times and determination of sub-periods
# - 5) Iterative re-estimation of RC0 and re-segmentation of residuals (steps 1-4) 
#      for each sub-period
# For a detailed description of each step see Darienzo et al., 2021.
# Please, be sure to have completely filled the input files in the case study folder:
# - "Options_Segment_gauging.R"
# - "Options_General.R"
# - "Options_BaRatinSPD.R" (for estimating multiperiod RC with the results of segmentation)
###############################################################################################
dir.segment.g        =  paste0(dir.case_study,"/Results/segmentation_gaugings")
file.options.general =  paste0(dir.case_study,"/Options_General.R")
file.options.segment =  paste0(dir.case_study, "/Options_Segment_gaugings.R")
file.options.SPD     =  paste0(dir.case_study,"/Options_BaRatinSPD.R")
dir.create(dir.segment.g)