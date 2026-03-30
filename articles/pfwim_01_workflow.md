# PFWIM Workflow

## Introduction

This vignette demonstrates how to use the PFWIM package to infer
consumer–resource interactions from trait data, and generate
hypothetical realized food webs using a power-law link distribution.

This workflow demonstrates:

1.  Inferring feasible interactions with
    [`infer_edgelist()`](https://beckslab.github.io/pfwim/reference/infer_edgelist.md).
2.  Downsampling interactions into hypothetical realized webs with
    [`powerlaw_prey()`](https://beckslab.github.io/pfwim/reference/powerlaw_prey.md).
3.  Customizing link distributions via the `func` argument.

Users can now use these realised webs for **network analyses**,  
simulation studies, or **comparisons to fossil and modern food webs**.

``` r
library(dplyr)
library(tidyr)
library(pfwim)

# Load example data included in the package
data("traits", package = "pfwim")
data("feeding_rules", package = "pfwim")
```

### Data Structure Requirements

Before running the inference model, ensure your data is formatted
correctly. The
[`infer_edgelist()`](https://beckslab.github.io/pfwim/reference/infer_edgelist.md)
function requires two specific data.frame objects.

#### Taxon Trait Data (`data`)

This table contains the taxa along with their physical or ecological
characteristics. Each row is a unique taxon, and columns represent
specific traits.

Taxon Column: A unique identifier for each species or group (*e.g.,*
“species”).

Trait Columns: Categorical traits (*e.g.,* habitat, tiering, motility)
or numerical traits (*e.g.,* body size).

``` r
# Preview the input structure
head(traits)
```

    ##      species motility      habitat   feeding   size
    ## 1 polar_bear   motile semi_aquatic  tertiary  large
    ## 2       seal   motile semi_aquatic secondary medium
    ## 3       orca   motile      aquatic  tertiary  large
    ## 4        cod   motile      aquatic secondary medium
    ## 5   plankton   motile      aquatic   primary  small
    ## 6    plant_1  sessile  terrestrial   primary  small

#### Feeding Rules (`cat_combo_list`)

This table acts as the logic engine. It defines which consumer traits
are compatible with which resource traits. It needs to contain both the
broader trait category (column names in the trait data frame) as well as
the specific trait class (the row entries for each trait column)

``` r
# Preview the input structure
head(feeding_rules)
```

    ##   trait_type_resource trait_resource trait_type_consumer trait_consumer
    ## 1             feeding        primary             feeding      secondary
    ## 2             feeding       tertiary             feeding       tertiary
    ## 3             feeding      secondary             feeding       tertiary
    ## 4            motility        sessile            motility        sessile
    ## 5            motility        sessile            motility         motile
    ## 6            motility         motile            motility         motile

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
