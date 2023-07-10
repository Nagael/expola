#!/bin/bash

for i in result-*.txt; do
    echo $i
    Rscript ../handle_res_rect_papi.R $i
    done

