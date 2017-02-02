#!/bin/bash
#

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download inputs
#
dx-download-all-inputs

#
#make output dir
#
mkdir -p /home/dnanexus/out/conifer_output/

#
# Download RPKM from github
#
GITHUB_KEY=$(cat '/home/dnanexus/github_key')
git clone https://$GITHUB_KEY@github.com/moka-guys/RPKM.git
cd RPKM
git checkout dnanexus_production
cd ..

#
# export miniconda to PATH
#
export PATH="/home/dnanexus/miniconda2/bin:$PATH"

#
# use conda to install required packages
#
conda config --add channels r
conda config --add channels bioconda
conda install pysam=0.8.3 matplotlib=2.0.0 numpy=1.11.3 pytables -y

#
# run the RPKM wrapper script. --bamlist is a folder containing deduplicated bams. 
#
python RPKM/rpkmanalysis.py --bamlist /home/dnanexus/in/bamfiles/ --output /home/dnanexus/out/conifer_output/conifer_output/ --probes /home/dnanexus/in/bedfile/$bedfile_prefix.bed

#
# Upload results
#
dx-upload-all-outputs
