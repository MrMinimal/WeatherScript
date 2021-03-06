#!/bin/bash
#
# Dieses Script gibt die Wetterdaten für eine gewisse Stadt an
# Dazu wird die API von http://openweathermap.org genutzt
#
# Beispiel-Aufruf:
# ./weather.sh -c "London" -twp
#


# ========================================= VARIABLES =========================================

    # Constants
    appid=31c8db3e5477aeac1def817cc0bc66b3      # Die app id für die API
    ServerIP=144.76.83.20                       # Wetter API sever
    fileName=weatherOutput                      # Dateiname für die Datei die die Daten enthält



    # Flags [0=N, 1=J]
    cFlagProvided=0                             # wurde dem Script eine -c Flag übergeben?
    printhelp=0                                 # Soll Hilfe ausgegeben werden?
    showTemp=0                                  # Soll Temperatur ausgegeben werden?
    showWindDir=0                               # Soll Windrichtung ausgegeben werden?
    showWindSpd=0                               # Soll Windgeschwindigkeit ausgegeben werden?
    showPress=0                                 # Soll Luftdruck ausgegeben werden?
    zeigeWetter=0				# soll Wetter (Bewölkt, Sonnig usw.) angezeigt werden?


    # Values
    city=                                       # Wetter für welche Stadt
    response=                                   # Antwort der API

    temperature=                                # der finale Wert für die Temperatur
    temperatureInt=                             # Zahl vor dem Komma
    temperatureFrac=                            # Zahl nach dem Komma (falls vorhanden)

    winddir=                                    # der finale Wert für die Windrichtung
    winddirInt=                                 # Zahl vor dem Komma
    windspeedFrac=                              # Zahl nach dem Komma (falls vorhanden)

    windspeed=                                  # der finale Wert für die Windgeschwindigkeit
    windspeedInt=                               # Zahl vor dem Komma
    windspeedFrac=                              # Zahl nach dem Komma (falls vorhanden)

    pressure=                                   # der finale Werlt für den Luftdruck
    pressureInt=                                # Zahl vor dem Komma
    pressureFrac=                               # Zahl nach dem Komma (falls vorhanden)

    wetter=					                    # Wetter (Bewölkt, Sonnig usw.)

# ========================================= FUNCTIONS =========================================

    # Wird einmalig am Ende des Scripts aufgerufen um ggf. über die Verwendung zu informieren
    usageHint()
    {
        if [[ $printhelp -eq 1 ]]
        then
            echo -e "\nUsage: $0 -c [City] [OPTIONS]\n"
            echo -e "Beispiel:"
            echo -e "$0 -c London -a"
    		echo -e "\n-c Muss angegeben werden und erwartet einen Städtenamen als übergabeparameter"
    		echo -e "-h gibt die Hilfe aus"	
    		echo -e "-a gibt alle Werte aus"
    		echo -e "-t gibt nur die Temperaturdaten aus"
    		echo -e "-w gibt die Winddaten (Windrichtung / Windgeschwindichkeit) aus"
    		echo -e "-p gibt den Umgebungsdruck an"
            echo -e "-z gibt den Wetterzustand in Sprache aus"
        fi
    }

# =========================================== ENTRY ===========================================


    # Sicher gehen, dass die Hilfe am Ende des Scripts einmalig aufgerufen wird
    trap usageHint EXIT

    # Intro
    echo -e "Wetter Script"
    echo -e "von Tom Langwaldt und David Becker\n"

    # Wenn der User dem Script keine Parameter übergibt, Hilfe ausgeben
    if [[ $# -eq 0 ]];
    then
        printhelp=1
        exit 1
    fi

    # Über Parameter iterieren
    while getopts ":c: :h :a :t :w :p :z" opt; do
        case $opt in
        # Stadt
        c)
            city=$OPTARG        # wenn kein Argument folgt, wird der case :) aufgerufen

            if [[ -z "$city" ]]; 
            then
                echo "Fehler: Keine Stadt angegeben -c erwartet einen Städtenamen als übergabeparameter"
                printhelp=1
                exit 1
            fi

            if [[ ${city:0:1} == '-' ]]
            then
                echo "Fehler: Keine Stadt angegeben -c erwartet einen Städtenamen als übergabeparameter"
                printhelp=1
                exit 1
            fi

            cFlagProvided=1
            ;;
        # Hilfe
        h)
            printhelp=1
            exit 1
            ;;

        # Alle Daten
        a)
            showTemp=1
            showPress=1
            showWindSpd=1
            showWindDir=1
            zeigeWetter=1
            ;;
            
        # Temperatur
        t)
            showTemp=1
            ;;

        # Winddaten
        w)
            showWindSpd=1
            showWindDir=1
            ;;

        # Druckdaten
        p)
            showPress=1
            ;;
	
    	# Zustand
    	z)
    	    zeigeWetter=1
    	    ;;

        # Alle anderen Parameter
        \?)
            echo "Fehler: unbekante option: -$OPTARG \n" >&2
            printhelp=1
            exit 1
            ;;
        # Wenn Optionen fehlen, falls ein Argument Befehle erwartet
        :)
            echo "Fehler: die Option -$OPTARG benötigt ein Argument" >&2
            printhelp=1
            exit
            ;;
        esac
    done

    if [[ $cFlagProvided == 0 ]]
    then
        echo "Fehler: Benötigt -c Parameter für eine Stadt" >&2
        exit 1
    fi

    # Wetter API anpingen ob verfügbar und output nicht weiter verwenden
    ping -c 1 $ServerIP > /dev/null

    # Überprüfung ob der ping zum server erfolgreich war
    if [[ $? == 0 ]]
    then
        echo -e "Hole Wetterdaten...\n"
    else
        echo "Fehler: Konnte Wetterserver nicht erreichen" >&2
        exit 1
    fi

    # API Anfrage
    response=`curl -s "api.openweathermap.org/data/2.5/weather?q="$city"&units=metric&lang=de&APPID="$appid""`


# Wetterdaten in Datei schreiben
{
    echo "== Wetter für $city =="

    # WetterZustand
    if [[ $zeigeWetter -eq 1 ]]
    then
        wetter=`sed -n 's/\(.*\)\("description":"\)\(.*\)\(","icon\)\(.*\)/\3/p' <<< $response`

    	#sicher gehen, dass überhaut ein wetter angegeben wurde
    	if [[ $wetter ]]
    	then
    	    echo -e "Wetter: \t$wetter "
    	fi	
    fi


    # Temperatur
    if [[ $showTemp -eq 1 ]]
    then
        temperatureInt=`sed -n 's/\(.*\)\("temp":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
        temperatureFrac=`sed -n 's/\(.*\)\("temp":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

        temperature=$temperatureInt

        if [[ $temperatureFrac ]]
        then
            temperature=$temperature.$temperatureFrac
        fi      

        # Sicher gehen, dass überhaupt eine Temperatur gemessen wurde
        if [[ $temperature ]]; 
        then
            echo -e "Temperatur:\t$temperature Grad Celsius"
        fi
    fi

    # Windgeschwindigkeit
    if [[ $showWindSpd -eq 1 ]]
    then
        windspeedInt=`sed -n 's/\(.*\)\("speed":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
        windspeedFrac=`sed -n 's/\(.*\)\("speed":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

        windspeed=$windspeedInt

        if [[ $windspeedFrac ]]
        then
            windspeed=$windspeed.$windspeedFrac
        fi

        # Sicher gehen, dass überhaupt eine Windgeschwindigkeit gemessen wurde
        if [[ $windspeed ]]; 
        then
            echo -e "Windgeschw:\t$windspeed meters per second"
        fi
    fi

    # Windrichtung
    if [[ $showWindDir -eq 1 ]]
    then
        winddirInt=`sed -n 's/\(.*\)\("deg":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
        winddirFrac=`sed -n 's/\(.*\)\("deg":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

        winddir=$winddirInt

        if [[ $winddirFrac ]]
        then
            winddir=$winddir.$winddirFrac
        fi

        # Sicher gehen, dass überhaupt eine Windrichtung gemessen wurde
        if [[ $winddir ]]; 
        then
            echo -e "Windrichtung:\t$winddir degrees"
        fi
    fi

    # Luftdruck
    if [[ $showPress -eq 1 ]]
    then
        pressureInt=`sed -n 's/\(.*\)\("pressure":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
        pressureFrac=`sed -n 's/\(.*\)\("pressure":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

        pressure=$pressureInt

        if [[ $pressureFrac ]]
        then
            pressure=$pressure.$pressureFrac
        fi

        # Sicher gehen, dass überhaupt ein Luftdruck gemessen wurde
        if [[ $pressure ]]; 
        then
            echo -e "Luftdruck:\t$pressure hPa"
        fi
    fi  


# Jeglichen output in eine Datei pipen (Fehler ausgenommen)
} > $fileName
    
    # Inhalt der Datei ausgeben
    cat ./$fileName

# =========================================== EXIT ============================================
