#!/usr/bin/env Rscript

#WStrimR.R

#This script will take a table structured file and trim the white space on a data frame.

##################
#
# USAGE
#
##################

#Run the following command in a terminal where R is installed for help.

#Rscript --vanilla WStrimR.R --help


##################
#
# Env. Setup
#
##################

#List of needed packages
list_of_packages=c("readr","openxlsx","stringi","readxl","optparse","tools")

#Based on the packages that are present, install ones that are required.
new.packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
suppressMessages(if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org"))

#Load libraries.
suppressMessages(library(readr,verbose = F))
suppressMessages(library(readxl,verbose = F))
suppressMessages(library(openxlsx, verbose = F))
suppressMessages(library(stringi,verbose = F))
suppressMessages(library(optparse,verbose = F))
suppressMessages(library(tools,verbose = F))


#remove objects that are no longer used.
rm(list_of_packages)
rm(new.packages)


##################
#
# Arg parse
#
##################

#Option list for arg parse
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="A validated dataset file (.xlsx, .tsv, .csv) based on the template CDS_submission_metadata_template.xlsx", metavar="character"),
  make_option(c("-s", "--sheet"), type="character", default="Metadata", 
              help="For xlsx files, a sheet name will need to be provided. It will default to 'Metadata', if none is given.", metavar="character")
)

#create list of options and values for file input
opt_parser = OptionParser(option_list=option_list, description = "\nWStrimR v2.0.0")
opt = parse_args(opt_parser)

#If no options are presented, return --help, stop and print the following message.
if (is.null(opt$file)){
  print_help(opt_parser)
  cat("Please supply the input file (-f).\n\n")
  suppressMessages(stop(call.=FALSE))
}


#Data file pathway
file_path=file_path_as_absolute(opt$file)

sheet_name=trimws(opt$sheet)

###########
#
# File name rework
#
###########


#Rework the file path to obtain a file extension.
file_name=stri_reverse(stri_split_fixed(stri_reverse(basename(file_path)),pattern = ".", n=2)[[1]][2])
ext=tolower(stri_reverse(stri_split_fixed(stri_reverse(basename(file_path)),pattern = ".", n=2)[[1]][1]))
path=paste(dirname(file_path),"/",sep = "")

#Output file name based on input file name and date/time stamped.
output_file=paste(file_name,
                  "_wsTrim",
                  stri_replace_all_fixed(
                    str = Sys.Date(),
                    pattern = "-",
                    replacement = ""),
                  sep="")


NA_bank=c("NA","na","N/A","n/a")

#Read in file with trim_ws=TRUE
if (ext == "tsv"){
  df=suppressMessages(read_tsv(file = file_path, trim_ws = TRUE, na=NA_bank, guess_max = 1000000, col_types = cols(.default = col_character())))
}else if (ext == "csv"){
  df=suppressMessages(read_csv(file = file_path, trim_ws = TRUE, na=NA_bank, guess_max = 1000000, col_types = cols(.default = col_character())))
}else if (ext == "xlsx"){
  df=suppressMessages(read_xlsx(path = file_path, trim_ws = TRUE, na=NA_bank, sheet = sheet_name, guess_max = 1000000, col_types = "text"))
}else{
  stop("\n\nERROR: Please submit a data file that is in either xlsx, tsv or csv format.\n\n")
}

                 
#Write out file
if (ext == "tsv"){
  suppressMessages(write_tsv(df, file = paste(path,output_file,".tsv",sep = ""), na=""))
}else if (ext == "csv"){
  suppressMessages(write_csv(df, file = paste(path,output_file,".csv",sep = ""), na=""))
}else if (ext == "xlsx"){
  wb=openxlsx::loadWorkbook(file = file_path)
  openxlsx::deleteData(wb, sheet = sheet_name,rows = 1:(dim(df)[1]+1),cols=1:(dim(df)[2]+1),gridExpand = TRUE)
  openxlsx::writeData(wb=wb, sheet=sheet_name, df, keepNA = FALSE)
  openxlsx::saveWorkbook(wb = wb,file = paste(path,output_file,".xlsx",sep = ""), overwrite = T)
}

cat(paste("\n\nProcess Complete.\n\nThe output file can be found here: ",path,"\n\n",sep = "")) 
