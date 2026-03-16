# Infer trophic interactions using PFWIM trait rules

Infers a consumer–resource edgelist using categorical trait matching
rules based on the PFWIM (Paleo Food Web Inference Model) described in
Shaw (2024). Interactions are inferred by comparing resource and
consumer trait combinations against a set of allowed trait rules.

## Usage

``` r
infer_edgelist(
  data,
  cat_combo_list,
  col_taxon = "taxon",
  col_num_size = NULL,
  cat_trait_types = NULL,
  num_size_rule = NULL,
  certainty_req = "all",
  allow_self = TRUE,
  return_full_matrix = FALSE,
  print_dropped_taxa = FALSE,
  hide_printout = FALSE,
  ...
)
```

## Arguments

- data:

  A `data.frame` containing taxa and associated trait values. Each row
  represents a taxon and each column represents a trait.

- cat_combo_list:

  A `data.frame` defining allowed consumer–resource trait combinations.
  Must contain columns:

  trait_type_resource

  :   Resource trait category

  trait_resource

  :   Resource trait value

  trait_type_consumer

  :   Consumer trait category

  trait_consumer

  :   Consumer trait value

- col_taxon:

  Character string indicating the column containing taxon names in
  `data`. Default `"taxon"`.

- col_num_size:

  Optional column name containing numerical size values for taxa. Used
  when applying a numeric predator–prey size rule.

- cat_trait_types:

  Optional character vector specifying a subset of categorical trait
  columns to use. If `NULL`, all traits appearing in `cat_combo_list`
  are used.

- num_size_rule:

  Optional function defining the predator–prey size feasibility rule.
  The function must accept two numeric vectors:
  `(resource_size, consumer_size)` and return `1` for feasible
  interactions and `0` otherwise.

  Example:

  `function(res_size, con_size) { ifelse(res_size <= con_size, 1, 0) }`

- certainty_req:

  Defines how many trait rules must be satisfied for an interaction to
  be considered feasible.

  "all"

  :   All trait types must match

  numeric

  :   Minimum number of matching trait types required

- allow_self:

  Logical. If TRUE, allows interactions where the resource and consumer
  are the same taxon (self-loops). Default is FALSE.

- return_full_matrix:

  Logical. If `TRUE`, returns the full matrix of taxon pairs and the
  number of matching trait rules. If `FALSE`, returns only inferred
  interactions as an edgelist.

- print_dropped_taxa:

  Logical. If `TRUE`, prints taxa that were removed from the inferred
  food web because they have no feasible interactions.

- hide_printout:

  Logical. If `TRUE`, suppresses progress messages.

- ...:

  Additional arguments reserved for future extensions.

## Value

If `return_full_matrix = FALSE`:

A two-column matrix containing:

- taxon_resource:

  Resource taxon

- taxon_consumer:

  Consumer taxon

If `return_full_matrix = TRUE`:

A matrix containing all taxon pairs and the number of trait rules
satisfied.

## Details

Trait matching is performed across all trait types present in
`cat_combo_list`. For each potential taxon pair, the number of satisfied
trait rules is calculated. An interaction is inferred when the number of
satisfied rules meets the required threshold defined by `certainty_req`.

Optionally, a numerical predator–prey size rule can also be applied
using `num_size_rule`.

The function evaluates all possible consumer–resource taxon pairs and
determines interaction feasibility using categorical trait rules and,
optionally, a numerical size constraint. The final edgelist includes
only interactions meeting the certainty requirement.

## References

Shaw, J. (2024). PFWIM: Paleo Food web Inference Model. *Preprint*.

## Examples

``` r
infer_edgelist(
  data = traits,
  cat_combo_list = feeding_rules,
  col_taxon = "species",
  certainty_req = "all"
)
#> [1] "feeding"
#> [1] "motility"
#> [1] "habitat"
#> [1] "size"
#> [1] "0 taxa dropped from web"
#> # A tibble: 22 × 2
#>    taxon_resource taxon_consumer
#>    <chr>          <chr>         
#>  1 cod            orca          
#>  2 cod            polar_bear    
#>  3 deer           lynx          
#>  4 deer           polar_bear    
#>  5 lynx           lynx          
#>  6 lynx           polar_bear    
#>  7 orca           orca          
#>  8 orca           polar_bear    
#>  9 plankton       cod           
#> 10 plankton       seal          
#> # ℹ 12 more rows
```
