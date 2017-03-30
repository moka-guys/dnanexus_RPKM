#!/bin/bash
#

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download inputs
#
dx-download-all-inputs

#make test dir
mkdir to_test

#move all files from the input to test dir
for input in /home/dnanexus/in/bamfiles/*; do if [ -d "$input" ]; then mv $input/* to_test/; fi; done

#make output dir
mkdir -p /home/dnanexus/out/conifer_output/conifer_output/

# Download RPKM from github
GITHUB_KEY=$(cat '/home/dnanexus/github_key')
git clone https://$GITHUB_KEY@github.com/moka-guys/RPKM.git
cd RPKM
git checkout dnanexus
#git checkout dnanexus_production
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
python RPKM/rpkmanalysis.py --bamlist /home/dnanexus/to_test/ --output /home/dnanexus/out/conifer_output/conifer_output/ --probes /home/dnanexus/in/bedfile/$bedfile_prefix.bed

# convert the spaces to tabs in the summary.txt 
sed "s/ \+/\t/g" /home/dnanexus/out/conifer_output/conifer_output/summary.txt > summary_tab.txt

#convert bed file to correct line endings
dos2unix -n /home/dnanexus/in/bedfile/$bedfile_prefix.bed $bedfile_prefix.converted.bed

#write the bed file and conifer summary output side by side.
pr -t -m -J $bedfile_prefix.converted.bed summary_tab.txt > /home/dnanexus/out/conifer_output/conifer_output/combined_bed_summary.txt 

# Upload results
dx-upload-all-outputs
