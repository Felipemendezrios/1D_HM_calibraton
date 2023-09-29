############################################################################################
#                              Input Data Reading ...
############################################################################################
# author: Felipe MENDEZ, INRAE
# purpose: 
# read gauging campaigns and stage record for calibration and validation process


#********************************************************************************************
#Read the directories:
#********************************************************************************************
dir.observations = paste0(dir.case_study, "Observations")             # Place folder with all observations
dir.calibration =  paste0(dir.observations, "Calibration")            # Read all observations for calibration process
dir.valibration = paste0(dir.observations, "Validation")              # Read all observations for validation process

message("
#####################################
# This program allows doing         #
# automatic calibration for a       #
# 1D hydraulic model                #
#                                   #
# Developed by:                     #
# Felipe MENDEZ (INRAE Lyon).       #
# Under supervision of:             #
# B. Renard, J. Le Coz              # 
# Version v1. 2023                  #
# Funded by SCHAPI                  #   
#####################################
# References:                       #
# Faure, J., 2007                   #  
# Renard, B., 2017                  #
#####################################
# Case study:                        ")

#********************************************************************************************
#                        Include all modules for computation:                               *
#********************************************************************************************
source(paste0(dir.case_study,"/General_options.R"))    

print(station.name)
message("Period of study:           ")
print(data.period.calibration)
message("
- Reading input data and general options. 
  Please, wait ..."); flush.console()

