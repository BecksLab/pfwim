# PFIM Workflow

## Introduction

This vignette demonstrates how to use the PFIM package to infer
consumer–resource interactions from trait data, and generate
hypothetical realized food webs using a power-law link distribution.

This workflow demonstrates:

1.  Inferring feasible interactions with
    [`infer_edgelist()`](https://beckslab.github.io/pfim/reference/infer_edgelist.md).
2.  Downsampling interactions into hypothetical realized webs with
    [`powerlaw_prey()`](https://beckslab.github.io/pfim/reference/powerlaw_prey.md).
3.  Customizing link distributions via the `func` argument.

Users can now use these realised webs for **network analyses**,  
simulation studies, or **comparisons to fossil and modern food webs**.

``` r
library(dplyr)
library(tidyr)
library(pfim)

# Load example data included in the package
data("traits", package = "pfim")
data("feeding_rules", package = "pfim")
data("interactions", package = "pfim")  # internal edgelist for tests
```

### Infer Edgelist

Infer interactions using categorical trait rules

``` r
edgelist <- infer_edgelist(
  data = traits,
  cat_combo_list = feeding_rules,
  col_taxon = "species",
  certainty_req = "all",
  hide_printout = TRUE
)

head(edgelist)
```

    ## # A tibble: 6 × 2
    ##   taxon_resource taxon_consumer
    ##   <chr>          <chr>         
    ## 1 cod            orca          
    ## 2 cod            polar_bear    
    ## 3 deer           lynx          
    ## 4 deer           polar_bear    
    ## 5 lynx           lynx          
    ## 6 lynx           polar_bear

### Generate Realised Webs with Power-Law

Generate 5 hypothetical realised webs

``` r
realised_webs <- powerlaw_prey(
  el = edgelist,
  n_samp = 5,
  y = 2.5
)

# Inspect first realised web
realised_webs[[1]]
```

    ##      resource   consumer
    ## 9    plankton        cod
    ## 14    plant_2       deer
    ## 11    plant_1       deer
    ## 20       seal       lynx
    ## 3        deer       lynx
    ## 16 polar_bear       orca
    ## 7        orca       orca
    ## 2         cod polar_bear
    ## 22       seal polar_bear
    ## 4        deer polar_bear
    ## 19        rat polar_bear
    ## 12    plant_1        rat
    ## 10   plankton       seal

### Customizing the Power-Law Distribution

``` r
# Define a custom in-degree distribution function
custom_func <- function(r, M, y) (M - r + 1)^(-y)

realised_webs_custom <- powerlaw_prey(
  el = edgelist,
  n_samp = 5,
  y = 2,
  func = custom_func
)

# First custom web
realised_webs_custom[[1]]
```

    ##      resource   consumer
    ## 9    plankton        cod
    ## 14    plant_2       deer
    ## 18        rat       lynx
    ## 5        lynx       lynx
    ## 1         cod       orca
    ## 7        orca       orca
    ## 16 polar_bear       orca
    ## 21       seal       orca
    ## 4        deer polar_bear
    ## 19        rat polar_bear
    ## 2         cod polar_bear
    ## 8        orca polar_bear
    ## 6        lynx polar_bear
    ## 22       seal polar_bear
    ## 12    plant_1        rat
    ## 15    plant_2       seal
