#!/bin/bash

for i in result-*.txt; do
    echo $i
    Rscript ../plot_all.R $i
    done

