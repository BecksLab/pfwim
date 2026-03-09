# Generate hypothetical realised webs using a power-law link distribution

PFIM generates a series of replicate hypothetical realised food webs by
reducing the feasible links for each consumer to match a target link
distribution. The default distribution is a mixed exponential–power law
in-degree distribution as described in Shaw (2024) and Roopnarine
(2006).

## Usage

``` r
powerlaw_prey(
  el,
  n_samp = 50,
  y = 2.5,
  func = function(r, M, y) exp(-r/(exp((y - 1) * (log(M)/y))))
)
```

## Arguments

- el:

  Data frame or matrix containing a feasible consumer–resource edgelist.
  Column 1 = resource, Column 2 = consumer.

- n_samp:

  Integer. Number of replicate realised webs to generate. Default = 50.

- y:

  Numeric. Parameter controlling the shape of the power-law
  distribution. Default = 2.5.

- func:

  Function. Probability function of the in-degree `r`, total prey
  richness `M`, and parameter `y`. Must return a numeric value \> 0.
  Default: `function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / y))))`.

## Value

A list of length `n_samp`, where each element is a realised food web
represented as a 2-column matrix with columns:

- res_node_node_name_inferred:

  Resource taxon name

- con_node_node_name_inferred:

  Consumer taxon name

## Details

For each consumer in `el`, the number of prey links in a realised web is
sampled according to the distribution defined by `func`. The sampled
prey are drawn randomly without exceeding the maximum feasible prey for
that consumer.

## References

Shaw, J. (2024). PFIM: Paleo Food-web Inference Model. *Preprint*.
Roopnarine, P. (2006). *Palaeoecology and food-web structure in fossil
communities*.

## Examples

``` r
# Infer a minimal edgelist
edgelist <- infer_edgelist(
  data = data.frame(
    species = c("plankton","plant_1","plant_2","cod","rat","deer"),
    feeding = c("primary","primary","primary","secondary","secondary","secondary")
  ),
  cat_combo_list = data.frame(
    trait_type_resource = c("feeding","feeding","feeding"),
    trait_resource = c("primary","primary","primary"),
    trait_type_consumer = c("feeding","feeding","feeding"),
    trait_consumer = c("secondary","secondary","secondary")
  ),
  col_taxon = "species",
  certainty_req = "all"
)
#> [1] "feeding"
#> [1] "0 taxa dropped from web"

# Generate realized webs
webs <- powerlaw_prey(edgelist, n_samp = 3, y = 2.5)
```
