# Using Continuous Variables

## Introduction

In many food webs, a consumer’s ability to eat a resource is limited by
their relative body sizes. The
[`infer_edgelist()`](https://beckslab.github.io/pfwim/reference/infer_edgelist.md)
function allows you to layer a numerical rule (like a predator-prey mass
ratio) on top of your categorical trait matching.

## Prepare Numerical Data

First, ensure your taxon data includes a numeric column for size (e.g.,
body mass in kg or length in cm). Here we will modify our traits
dataframe

``` r
library(pfwim)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
# Adding body mass to our traits
traits_numeric <- traits %>%
  mutate(body_mass = case_when(
    species == "polar_bear" ~ 450,
    species == "seal"       ~ 100,
    species == "orca"       ~ 3000,
    species == "cod"        ~ 5,
    species == "plankton"   ~ 0.0001,
    TRUE                    ~ 10 # Default for others
  ))

head(traits_numeric)
```

    ##      species motility      habitat   feeding   size body_mass
    ## 1 polar_bear   motile semi_aquatic  tertiary  large   4.5e+02
    ## 2       seal   motile semi_aquatic secondary medium   1.0e+02
    ## 3       orca   motile      aquatic  tertiary  large   3.0e+03
    ## 4        cod   motile      aquatic secondary medium   5.0e+00
    ## 5   plankton   motile      aquatic   primary  small   1.0e-04
    ## 6    plant_1  sessile  terrestrial   primary  small   1.0e+01

## Define the Size Rule Function

The num_size_rule argument requires a function that takes two inputs
(res_size, con_size) and returns 1 (feasible) or 0 (not feasible).

``` r
my_size_rule <- function(res_size, con_size) {
  ratio <- con_size / res_size
  ifelse(ratio >= 2 & ratio <= 100, 1, 0)
}
```

## Run Inference with Size Constraints

When `col_num_size` is provided, the function treats it as an additional
trait type. If `certainty_req = "all"`, the interaction must satisfy all
categorical matches AND the numerical size rule.

``` r
edgelist_size <- infer_edgelist(
  data = traits_numeric,
  cat_combo_list = feeding_rules,
  col_taxon = "species",
  col_num_size = "body_mass",    # Point to the numeric column
  num_size_rule = my_size_rule,   # Apply our custom logic
  certainty_req = "all",
  hide_printout = TRUE
)

head(edgelist_size)
```

    ## # A tibble: 6 × 2
    ##   taxon_resource taxon_consumer
    ##   <chr>          <chr>         
    ## 1 cod            polar_bear    
    ## 2 deer           polar_bear    
    ## 3 lynx           polar_bear    
    ## 4 plant_1        seal          
    ## 5 plant_2        seal          
    ## 6 polar_bear     orca
