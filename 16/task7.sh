#!/bin/bash

set -e

input_file="task1.json"

jq '.name = "Tom"' $input_file > tmp && mv tmp $input_file
