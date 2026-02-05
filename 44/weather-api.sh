#!/bin/bash

q="Vilnius"
units="metric"
API_KEY="-"

curl -L https://api.openweathermap.org/data/2.5/weather?q=$q&units=$units&appID=$API_KEY

