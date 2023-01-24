# OmicsExplorer
Bioinformatics workflow for genomics data generation and analysis


# Installation of conda environment and dependencies for OmicsExplorer

*Please find more info for **QuickFixR** on: https://github.com/JacobAgerbo/QuickFixR*

I base this tutorial on conda and therefore miniconda should be installed prior the tutorial, please see link:
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
