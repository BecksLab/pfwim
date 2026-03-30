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

\`\`\`{r-modify_traits}

## Adding body mass (kg) to our traits

traits_numeric \<- traits %\>% mutate(body_mass = case_when( species ==
“polar_bear” ~ 450, species == “seal” ~ 100, species == “orca” ~ 3000,
species == “cod” ~ 5, species == “plankton” ~ 0.0001, TRUE ~ 10 \#
Default for others ))

head(traits_numeric)

    # Define the Size Rule Function

    The num_size_rule argument requires a function that takes two inputs (res_size, con_size) and returns 1 (feasible) or 0 (not feasible).

    ``` {r-size_rule}

    my_size_rule <- function(res_size, con_size) {
      ratio <- con_size / res_size
      ifelse(ratio >= 2 & ratio <= 100, 1, 0)
    }

## Run Inference with Size Constraints

When `col_num_size` is provided, the function treats it as an additional
trait type. If `certainty_req = "all"`, the interaction must satisfy all
categorical matches AND the numerical size rule.

\`\`\`{r-build_list}

edgelist_size \<- infer_edgelist( data = traits_numeric, cat_combo_list
= feeding_rules, col_taxon = “species”, col_num_size = “body_mass”, \#
Point to the numeric column num_size_rule = my_size_rule, \# Apply our
custom logic certainty_req = “all”, hide_printout = TRUE )

head(edgelist_size) \`\`\`
