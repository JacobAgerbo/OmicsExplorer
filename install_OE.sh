#!/bin/sh
# Script for installing all dependencies for OmicsExplorer
# Usage: just run "bash install_OE.sh"
WorkDir=`pwd -P`
pip3_path=`which pip3`
bin="${WorkDir}/.OE_bin"
mkdir ${bin}
if [ ! -d ${pip3_path} ]
then
 echo "conda is active, let install all dependencies"
 curl -L https://github.com/merenlab/anvio/releases/download/v7.1/anvio-7.1.tar.gz --output ${bin}/anvio-7.1.tar.gz
 curl -L https://raw.githubusercontent.com/JacobAgerbo/OmicsExplorer/main/OmicsExplorer.yml --output ${bin}/OmicsExplorer.yml
 curl -L https://raw.githubusercontent.com/JacobAgerbo/OmicsExplorer/main/Install_R_dep.Rscript --output ${bin}/Install_R_dep.Rscript
 conda env create -f ${bin}/OmicsExplorer.yml
 conda activate OmicsExplorer
 export CC=clang
 export CC=/usr/bin/clang
 export CXX=/usr/bin/clang++
 pip install ${bin}/anvio-7.1.tar.gz
 Rscript ${bin}/Install_R_dep.Rscript
  if [$CONDA_PREFIX = "OmicsExplorer"]
  then
    echo "Something went wrong :'("
    echo "OmicsExplorer was succesfully installed. Yay!"
    rm -r $bin
  else
    echo "Something went wrong :'("
  fi
else
 echo "conda is not activate, please install miniconda or anaconda"
 echo "If you are on a cluster, try to use 'module load anaconda' before this installation"
 exit 0
fi
