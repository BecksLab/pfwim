# Sample integers according to a discrete probability distribution

Generates random draws from 1:M with probabilities defined by a
user-specified function (default is the PFIM mixed exponential–power law
distribution).

## Usage

``` r
sample_pdf(
  M = 100,
  y = 2.5,
  func = function(r, M, y) exp(-r/(exp((y - 1) * (log(M)/y)))),
  n_samp = 100
)
```

## Arguments

- M:

  Integer. Maximum value to sample (upper bound of 1:M).

- y:

  Numeric. Parameter controlling the distribution shape.

- func:

  Function. Probability function of r (1:M), M, and y. Default is the
  PFIM exponential–power law function:
  `function(r, M, y) exp(-r / (exp((y - 1) * (log(M) / y))))`.

- n_samp:

  Integer. Number of random draws.

## Value

Integer vector of length `n_samp` with values in 1:M.

## Examples

``` r
# Generate 3 replicate webs from a small edgelist
edgelist <- data.frame(
  res_node_node_name_inferred = c("plankton","plant_1","plant_2"),
  con_node_node_name_inferred = c("cod","rat","deer")
)
webs <- powerlaw_prey(edgelist, n_samp = 3, y = 2.5)
```
