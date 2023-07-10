#!/bin/bash

for i in result-*.txt; do
    echo $i
    Rscript ../plot_focus.R $i
    done

