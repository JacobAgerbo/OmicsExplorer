# OmicsExplorer
Bioinformatics workflow for genomics data generation and analysis


# Installation of conda environment and dependencies for OmicsExplorer

*Please find more info on: https://github.com/JacobAgerbo/QuickFixR*

I base this tutorial on conda and therefore miniconda should be installed prior the tutorial, please see link:
*https://docs.conda.io/en/latest/miniconda.html*

First thing we need to do is, creating a conda environment.

For this you will a config file with all dependencies. This file has already been made and can be downloaded [**here**](https://https://github.com/JacobAgerbo/OmicsExplorer/OmicsExplorer.yml). It is called **OmixExplorer.yml**.

```
conda env create -f OmixExplorer.yml
```

This environment has installed dependencies for for processing R (>4.1) with several packages, but a few more is needed.
These packages are not yet to be found on condas channels and therefore we will install them in R

Launch conda environment and subsequently R, by typing:

```
conda activate OmixExplorer #activating the environment
R #starting R
```

Now install dependencies

```
dependencies <- c("boral","ggboral", "pbkrtest", "ggiraph", "hilldiv")
installed_packages <- dependencies %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(dependencies[!installed_packages])}
#BiocManager
installed_packages <- dependencies %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
BiocManager::install(dependencies[!installed_packages])}
#Github
installed_packages <- dependencies %in% rownames(installed.packages())
if (installed_packages[2] == FALSE) {
  remotes::install_github("mbedward/ggboral")}
```

Now please install the R package *QuickFixR*, which is a shiny package for easy visualisation

```
devtools::install_github("JacobAgerbo/QuickFixR")
```
After this you should be golden! And should be able launch the shiny app **within R** simply by typing:
```
QuickFixR::QuickFix()
```
