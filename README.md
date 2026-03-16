# PFWIM: Paleo Food Web Inference Model <img src="man/figures/logo.png" align="right" width="120" />

`PFWIM` is an R package for inferring predator–prey interactions using trait-based 
rules and generating hypothetical realised food webs. It implements 
the **Paleo Food-web Inference Model (Shaw 2024)** and includes tools for categorical 
trait matching, numerical predator–prey size rules, and power-law downsampling of 
realised webs.

## Installation

```
# Install from CRAN (when available)
install.packages("pfwim")

# Or install development version from GitHub
# install.packages("devtools")
devtools::install_github("BecksLab/pfwim")
```

## Load Example Data

```
library(pfwim.R)

# Trait data
data("traits", package = "pfwim")

# Trait combination rules
data("feeding_rules", package = "pfwim")

head(traits)
head(feeding_rules)
```

## Inferring a consumer–resource edgelist

Use `infer_edgelist()` to infer feasible interactions:

```
edgelist <- infer_edgelist(
  data = traits,
  cat_combo_list = feeding_rules,
  col_taxon = "species",
  certainty_req = "all",
  allow_self = FALSE
)

# Show first few interactions
head(edgelist)
```

## Generate hypothetical realised webs

Create a series of hypothetical webs using `powerlaw_prey()`

```
webs <- powerlaw_prey(
  el = edgelist,
  n_samp = 5,
  y = 2.5
)

# Inspect first web
webs[[1]]
```

Each element of `webs` is a matrix representing a realised food web generated 
from the inferred interactions
