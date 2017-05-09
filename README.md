# dnanexus_RPKM v1.1

## What does this app do?
This app uses conifer to perform RPKM analysis.

## What are typical use cases for this app?
CNV analysis of custom panels

## What data are required for this app to run?
* An array of BAM and index (.bai) files
* A BED file for the CNV regions 
  * This bedfile must have a header and 'chr' removed eg:
  
      `chr start  stop    name`
      
       `11    108093508    108093963    ATM_Ex01_PM`


## What does this app output?
Within a folder names conifer_output the App produces:
* A text file for each BAM input
* summary.txt - A file with a column containing the RPKM value for each sample
* combined_bed_summary.txt - The summary.txt file merged with the bedfile to give the coordinates for each RPKM value.

## How does this app work?
This app is based on the code in the github repo https://github.com/moka-guys/RPKM.
This code enables a list of BAM files to be fed into conifer, and the outputs summarised into a single file.

1. Clone the github repo
2. Change to the dnanexus_production branch
3. Installs Miniconda and the required packages
4. Runs conifer
5. Converts the bed file and summary.txt into formats which can be merged
6. Merge these files

## Custom modifications
* The app was made by the Viapath Genome Informatics section 