#!/bin/bash

# Get a picture of a cat + a joke by calling an API! 
# more at https://free-apis.github.io/#/browse


curl -s https://cataas.com/cat --output cat.png | jq
curl -s https://official-joke-api.appspot.com/jokes/random | jq '"\(.setup) \(.punchline)"'

