# dnanexus_RPKM v1.5

## What does this app do?
This app uses conifer to perform RPKM analysis.

## What are typical use cases for this app?
This app has been designed to be run in an automated fashion following the end of a sequencing run.

Using the inputs described below BAM files for each panel code are downloaded.
A minimum of three samples must be present in the project. 


## What data are required for this app to run?
* A BED file for the CNV regions 
  * This bedfile must NOT have a header
  *  Each entry must have  'chr' removed eg:
      `11    108093508    108093963    ATM_Ex01_PM`
  *  An app (RPKM_bedfile) has been created which can be used to convert the data.bed bed file produced by mokabed into the desired format (RPKM.bed)
* A project in which to find BAM files
  * BAM files must be found in /output/
  * This version of the app downloads BAM files before they preprocessing has been performed (not the refined.bams)
  * A comma seperated string of Pan number(s) describing which BAM files should be downloaded.
  * The BAMfiles will be named using the variant caling pan number.
  * The RPKM bed file has a different panel number. 
  * The same panel design can be run using multiple pan numbers and analysis benefits from maximising the number of samples in the analysis.
  * Therefore a comma seperated list of pan numbers can be provided
  * All BAM and BAI files contaning one of these pan numbers will be downloaded and included in the analysis.


## What does this app output?
Within a folder named conifer_output a folder is created using the Pannumber of the RPKM bedfile. Within this folder the following files are created:
* A text file for each BAM input
* summary.txt - A file with a column containing the RPKM value for each sample
* combined_bed_summary_NGS999A_Pan1000_RPKM.txt  - The summary.txt file merged with the bedfile to give the coordinates for each RPKM value.

## How does this app work?
This app is based on the code in the github repo https://github.com/moka-guys/RPKM.
This code enables a list of BAM files to be fed into conifer, and the outputs summarised into a single file.

1. Download the BAM files that correspond to the given panel number(s). Check there are at least 3 samples.
2. Clone the github repo
3. Change to the dnanexus_production branch
4. Installs Miniconda and the required packages
5. Runs conifer
6. Converts the bed file and summary.txt into formats which can be merged
7. Merge these files

## Custom modifications
* The app was made by the Viapath Genome Informatics section 