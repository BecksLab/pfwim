# pfwim: Paleo Food Web Inference Model

`pfrim` is an R package for inferring predator–prey interactions using
trait-based rules and generating hypothetical realised food webs. It
implements the **Paleo Food-web Inference Model** ([Shaw
2024](https://doi.org/10.1101/2024.01.30.578036)) and includes tools for
categorical trait matching, numerical predator–prey size rules, and
power-law downsampling of realised webs.

## Installation

Install from CRAN

``` r

install.packages("pfwim")
```

You can install the development version of `pfwim` from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("BecksLab/pfwim")
```

## Examples

    library(pfwim)

    # Trait data
    data("traits", package = "pfwim")

    # Trait combination rules
    data("feeding_rules", package = "pfwim")

    head(traits)
    head(feeding_rules)

### Inferring a consumer–resource edgelist

Use
[`infer_edgelist()`](https://beckslab.github.io/pfwim/reference/infer_edgelist.md)
to infer feasible interactions:

    edgelist <- infer_edgelist(
      data = traits,
      cat_combo_list = feeding_rules,
      col_taxon = "species",
      certainty_req = "all",
    )

    # Show first few interactions
    head(edgelist)

### Generate hypothetical realised webs

Create a series of hypothetical webs using
[`powerlaw_prey()`](https://beckslab.github.io/pfwim/reference/powerlaw_prey.md)

    webs <- powerlaw_prey(
      el = edgelist,
      n_samp = 5,
      y = 2.5
    )

    # Inspect first web
    webs[[1]]

Each element of `webs` is a matrix representing a realised food web
generated from the inferred interactions

## Citation

If you use `pfwim` in your research, please cite the associated
manuscript:

Shaw, Jack O., Alexander M. Dunhill, Andrew P. Beckerman, Jennifer A.
Dunne, and Pincelli M. Hull. 2024. A Framework for Reconstructing
Ancient Food Webs Using Functional Trait Data. bioRxiv.
<https://doi.org/10.1101/2024.01.30.578036>.
