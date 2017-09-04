#!/bin/bash
#

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download inputs
#
dx download "$bedfile"
#set string to remove from bedfile name
to_remove="data.bed"
#capture the pan number for RPKM panel number
pannum=$(echo $bamfile_name | sed "s/$to_remove//")
echo $pannum

# split project name to get the NGS run number
run=${project_name##*_}


#read the DNA Nexus api key as a variable
API_KEY=$(cat '/home/dnanexus/auth_key')

#make and cd to test dir
mkdir to_test
cd to_test

#download all the BAM and BAI files for this project/pan number
dx download $project_name:output/*$pannum*001.ba* --auth $API_KEY

#count the files. make sure there are at least 3 samples for this pan number, else stop
filecount="$(ls *"$pannum"* | grep . -c)"
if (( $filecount < 6 )); then
	echo "LESS THAN THREE BAM FILES FOUND FOR THIS PAN NUMBER" 1>&2
	exit 1
fi

# cd out of to_test
cd ..


#make output dir
mkdir -p /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/

# Download RPKM from github
# capture github API key
GITHUB_KEY=$(cat '/home/dnanexus/github_key')
#clone repo
git clone https://$GITHUB_KEY@github.com/moka-guys/RPKM.git
cd RPKM
#switch to branch containing code to run
git checkout dnanexus_production
cd ..

# install Anaconda
bash ~/Miniconda2-latest-Linux-x86_64.sh -b -p $HOME/Miniconda

#export to path
export PATH="$HOME/Miniconda/bin:$PATH"


# use conda to install required packages
conda config --add channels r
conda config --add channels bioconda
conda install pysam=0.8.3 matplotlib=2.0.0 numpy=1.11.3 pytables -y

# run the RPKM wrapper script. --bamlist is a folder containing deduplicated bams. 
python RPKM/rpkmanalysis.py --bamlist /home/dnanexus/to_test/ --output /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/ --probes /home/dnanexus/$bedfile_prefix.bed

# convert the spaces to tabs in the summary.txt 
sed "s/ \+/\t/g" /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/summary.txt > summary_tab.txt

#convert bed file to correct line endings
dos2unix -n /home/dnanexus/$bedfile_prefix.bed $bedfile_prefix.converted.bed

#add a empty header line to bed to ensure the two files match up
echo -e "\t\t\t" | cat - $bedfile_prefix.converted.bed > $bedfile_prefix.converted_header.bed

#write the bed file and conifer summary output side by side.
pr -t -m -J $bedfile_prefix.converted_header.bed summary_tab.txt > /home/dnanexus/out/conifer_output/conifer_output/$bedfile_prefix/combined_bed_summary_$run_$bedfile_prefix.txt 

# Upload results
dx-upload-all-outputs
