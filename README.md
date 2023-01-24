# OmicsExplorer

OmicsExplo is a bioinformatics workflow for genomics data generation and analysis an this GitHub contains a workflow for generating and exploring usefull data derived from 'omics'.

The aim of this workflow is to make knowledge out of data and the end point of this workflow should be to have a usable workflow for multiple kinds of omics layers, which a normally used to understand host-microbe interactions, as described in Limborg et al., 2017.
![alt text](misc/Hologenomics.jpg){width=200 height=200}

But please behold! This workflow is still under construction.

## Installation of conda environment and dependencies for OmicsExplorer

I base this workfol on conda and therefore miniconda should be installed prior the installation, please see link:
*https://docs.conda.io/en/latest/miniconda.html*

First thing we need to do is, creating a conda environment.
For this you will a config file with all dependencies. This file has already been made and can be downloaded [**here**](https://https://github.com/JacobAgerbo/OmicsExplorer/OmicsExplorer.yml). It is called **OmixExplorer.yml**.

But else this code chunk should work for most people.

```{sh, eval == FALSE}
wget https://raw.githubusercontent.com/JacobAgerbo/OmicsExplorer/main/install_OE.sh
bash install_OE.sh
```

This environment has installed dependencies for for processing genomic data. Furthermore, it contains R (>4.1) with several packages, which are dependencies for shiny package, which are great for a fast overview of multivariate analysis.

After this you should be golden! And should be able launch the shiny app **within R** simply by typing:

```
QuickFixR::QuickFix()
```
*QuickFixR* can be used for any multivariate analysis, so please don't hesitate to use it for any analysis.
*Please find more info for **QuickFixR** on: https://github.com/JacobAgerbo/QuickFixR*
