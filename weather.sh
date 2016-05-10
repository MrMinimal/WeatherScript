#!/bin/bash
# Dieses Script gibt die Wetterdaten für eine gewisse Stadt an
# Dazu wird die API von http://openweathermap.org genutzt

# TODO: -c --current
# TODO: -p --predicted
# TODO: --no-intro option
# TODO: --dialog

# Die app id die von der API gefordert wird
APPID=31c8db3e5477aeac1def817cc0bc66b3

# TODO: dynamisch einlesen
CITY=friedrichshafen

# Intro
dialog 	--title "WetterScript" --infobox "von Tom Langwaldt und David Becker" 3 40
sleep 1

# API Anfrage
RESPONSE=$(curl -s "api.openweathermap.org/data/2.5/weather?q="$CITY"&units=metric&APPID="$APPID"")

# Einlesen der interessanten Daten in Variablen
TEMPERATURE=$(sed -n 's/\(.*\)\("temp":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $RESPONSE)
WINDDIR=$(sed -n 's/\(.*\)\("deg":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $RESPONSE)
WINDSPEED=$(sed -n 's/\(.*\)\("speed":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $RESPONSE)

echo "full:"$RESPONSE
echo "temp:"$TEMPERATURE
echo "wind speed:"$WINDSPEED
echo $WINDDIR " degrees"