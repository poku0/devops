#!/bin/bash

set -e

input_file="task2.yml"

yq '.name = "Tom"' $input_file > tmp && mv tmp $input_file
