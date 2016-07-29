
<!-- README.md is generated from README.Rmd. Please edit that file -->
Quick start
-----------

Welcome to the `peakRAM` GitHub page!

When working with big datasets, RAM conservation is critically important. However, it is not always enough to just monitor the size of the objects created. So-called "copy-on-modify" behavior, characteristic of *R*, means that some expressions or functions may require an unexpectedly large amount of RAM overhead. For example, replacing a single value in a matrix (e.g., with '\[&lt;-') duplicates that matrix in the backend, making this task require twice as much RAM as that used by the matrix itself. The `peakRAM` package makes it easy to monitor the total and peak RAM used so that developers can quickly identify and eliminate RAM hungry code. You can get started with `peakRAM` by installing the most up-to-date version of this package directly from GitHub.

``` r
library(devtools)
devtools::install_github("tpq/peakRAM")
library(peakRAM)
```

### Monitoring RAM overhead

The `peakRAM` package, inspired by the very elegant `microbenchmark` package, offers an easy way to monitor the total and peak RAM used by any number of *R* expressions or functions, including anonymous functions. Simply call `peakRAM` with any number of comma-separated expressions or functions provided as arguments. This function will execute each argument piecewise, recording the amount of RAM allocated as a result of that call (i.e., "Total RAM Used") as well as the maximum amount of RAM allocated at any point during that call (i.e., "Peak RAM Used"). Note that throughout this package, all RAM use is measured in mebibytes (MiB).

``` r
peakRAM(function() 1:1e7,
        1:1e7,
        1:1e7 + 1:1e7,
        1:1e7 * 2)
```

    ##        Function_Call Elapsed_Time_sec Total_RAM_Used_MiB Peak_RAM_Used_MiB
    ## 1 function() 1:1e+07            0.110               38.2              38.2
    ## 2            1:1e+07            0.087               38.2              38.2
    ## 3  1:1e+07 + 1:1e+07            0.211               38.2              76.3
    ## 4        1:1e+07 * 2            0.142               76.3             114.5

### Discussion

What happened here? Well, we see that initializing the vector `1:1e7` requires ~38 MiB of RAM, whether done through an anonymous function or not. Also, as we might expect, we see that adding `1:1e7` to `1:1e7` requires ~72 MiB of RAM, even though the result only occupies ~38 MiB of RAM, because the vector `1:1e7` is initialized twice.

When RAM is valuable and the object is large, we want to avoid this kind of overhead. To achieve this, we might try instead to double the vector `1:1e7`, avoiding addition altogether. But wait, this uses *even more* RAM. Why? Well, multiplying by `2` in this case first copies the *integer* vector to a *double* vector, then multiplies the *double* vector by `2`. For an instant, the original *integer* vector and new *double* vector exists simultaneously, occupying ~38 MiB plus ~72 MiB of RAM.

Alas, *R* is a most precarious lover. To conserve the maximum amount of RAM, we need an approach that makes no needless copies. In this case, we just need to force `2` to exist as an integer.

``` r
peakRAM(1:1e7 * 2:2)
```

    ##   Function_Call Elapsed_Time_sec Total_RAM_Used_MiB Peak_RAM_Used_MiB
    ## 1 1:1e+07 * 2:2            0.099               38.1              38.1

Now, we have a solution that we can scale confidently, knowing for sure that we will not unwittingly exceed memory capacity through superfluous RAM overhead.
