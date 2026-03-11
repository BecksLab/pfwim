# PFIM: Paleo Food-Web Inference Model

## Introduction

This vignette demonstrates how to use the PFIM package to infer
consumer–resource interactions from trait data, and generate
hypothetical realized food webs using a power-law link distribution.

This workflow demonstrates:

1.  Inferring feasible interactions with
    [`infer_edgelist()`](https://beckslab.github.io/pfim.R/reference/infer_edgelist.md).
2.  Downsampling interactions into hypothetical realized webs with
    [`powerlaw_prey()`](https://beckslab.github.io/pfim.R/reference/powerlaw_prey.md).
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

    ##      res_node_node_name_inferred con_node_node_name_inferred
    ## [1,] "orca"                      "orca"                     
    ## [2,] "deer"                      "polar_bear"               
    ## [3,] "rat"                       "polar_bear"               
    ## [4,] "rat"                       "lynx"                     
    ## [5,] "plankton"                  "cod"                      
    ## [6,] "plankton"                  "seal"                     
    ## [7,] "plant_1"                   "deer"                     
    ## [8,] "plant_1"                   "rat"

### Customizing the Power-Law Distribution

``` r
# Define a custom in-degree distribution function
custom_func <- function(r, M, y) (M - r + 1)^(-y)

realized_webs_custom <- powerlaw_prey(
  el = edgelist,
  n_samp = 5,
  y = 2,
  func = custom_func
)

# First custom web
realized_webs_custom[[1]]
```

    ##       res_node_node_name_inferred con_node_node_name_inferred
    ##  [1,] "orca"                      "orca"                     
    ##  [2,] "polar_bear"                "orca"                     
    ##  [3,] "cod"                       "orca"                     
    ##  [4,] "seal"                      "orca"                     
    ##  [5,] "cod"                       "polar_bear"               
    ##  [6,] "polar_bear"                "polar_bear"               
    ##  [7,] "seal"                      "polar_bear"               
    ##  [8,] "rat"                       "polar_bear"               
    ##  [9,] "deer"                      "polar_bear"               
    ## [10,] "orca"                      "polar_bear"               
    ## [11,] "lynx"                      "polar_bear"               
    ## [12,] "rat"                       "lynx"                     
    ## [13,] "seal"                      "lynx"                     
    ## [14,] "plankton"                  "cod"                      
    ## [15,] "plankton"                  "seal"                     
    ## [16,] "plant_1"                   "seal"                     
    ## [17,] "plant_2"                   "seal"                     
    ## [18,] "plant_1"                   "deer"                     
    ## [19,] "plant_2"                   "deer"                     
    ## [20,] "plant_1"                   "rat"
