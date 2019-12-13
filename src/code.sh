#!/bin/bash
#

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

### Set up parameters
# split project name to get the NGS run number
run=${project_name##*_}

#read the DNA Nexus api key as a variable
API_KEY=$(dx cat project-FQqXfYQ0Z0gqx7XG9Z2b4K43:mokaguys_nexus_auth_key)

#make output dir
mkdir -p /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/
# make folder to hold downloaded files
mkdir to_test


#
# Download inputs
#
dx download "$bedfile"


# make and cd to test dir
cd to_test

# $bamfile_pannumbers is a comma seperated list of pannumbers that should be analysed together.
# split this into an array and loop through to download BAM and BAI files
IFS=',' read -ra pannum_array <<<  $bamfile_pannumbers
for panel in ${pannum_array[@]}
do 
	#download all the BAM and BAI files for this project/pan number
	dx download $project_name:output/*$panel*001.ba* --auth $API_KEY
done

#count the files. make sure there are at least 3 samples for this pan number, else stop
filecount="$(ls *001.ba* | grep . -c)"
if (( $filecount < 6 )); then
	echo "LESS THAN THREE BAM FILES FOUND FOR THIS ANALYSIS" 1>&2
	exit 1
fi

# cd out of to_test
cd ..

# install Anaconda
bash ~/Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/Miniconda

#export to path
export PATH="$HOME/Miniconda/bin:$PATH"

# use conda to install required packages
conda config --add channels r
conda config --add channels bioconda
conda install zlib=1.2.8 pysam=0.8.3 matplotlib=2.0.0 numpy=1.11.3 pytables=3.3.0 -y

# run the RPKM wrapper script. --bamlist is a folder containing deduplicated bams. 
python RPKM/rpkmanalysis.py --bamlist /home/dnanexus/to_test/ --output /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/ --probes /home/dnanexus/$bedfile_prefix.bed

# convert the spaces to tabs in the summary.txt 
sed "s/ \+/\t/g" /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/summary.txt > summary_tab.txt

#convert bed file to correct line endings
dos2unix -n /home/dnanexus/$bedfile_prefix.bed $bedfile_prefix.converted.bed

#add a empty header line to bed to ensure the two files match up
echo -e "\t\t\t" | cat - $bedfile_prefix.converted.bed > $bedfile_prefix.converted_header.bed

#write the bed file and conifer summary output side by side.
pr -t -m -J $bedfile_prefix.converted_header.bed summary_tab.txt > /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/combined_bed_summary_${run}_${bedfile_prefix}.txt 

# Upload results
dx-upload-all-outputs
