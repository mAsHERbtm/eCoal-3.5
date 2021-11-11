#!/bin/bash
# Skrypt sprawdzający czy w sterowniku eCoal 3.5 wystąpił alarm. Wynik sprawdzenia zostaje wyświetlony w konsoli oraz zapisany do pliku 'alarm.log'
# Skrypt sprawdza 24 możliwe do wystąpienia alarmy np. alarm_tkot, alarm_tpow, alarm_tpod, alarm_tcwu etc.
#   - jeżeli alarm wystąpił: wyświetla wartość "1"
#   - jeżeli alarm nie wystąpił: wyświetla wartość "0"
# dodatkowo każde wywołanie skryptu zapisuje stan wszystkich alarmów do pliku  'alarm_status_historia.log' - można zweryfikować historię sprawdzeń.
#
# UWAGA: Przed pierwszym uruchomieniem należy uzupełnić zmienne: login, haslo, ip
# 
# --- WYMAGANIA ----
#   - curl: sudo apt-get install curl
#
# ---- LOKALIZACJA PLIKÓW ---- 
# Lokalizacja pliku:    /config/scripts/odczytAlarmuLocal.sh
# Aktualny status:      /config/alarm_status.txt
# Historia sprawdzeń:   /config/alarm_status_historia.log
#
# ---- OZNACZENIA ALARMÓW ----
# 0 - brak alarmu 
# 1 - alarm (ogólna informacja)
# 2 - otwarty zasobnik
# 3 - zerwana zawleczka podajnika
# 4 - pusty zasobnik

#DANE LOGOWANIA
login='root';
haslo='twoje_haslo';
ip='adres_ip_pieca';

#POBIERANIE DANYCH
rm -f alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tkot' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tpow' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tpod' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tcwu' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_twew' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tzew' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_t1' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_t2' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tsp' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_termik' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tkot_90' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_wyg_grz' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_wyg_pod' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_zabr' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tsp_hi' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tpod_hi' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_pod_zaplon' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_zew' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_zasobnik' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_stb' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_out_pod' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_otw_zasob' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_uszk_pod' >> alarm.log && echo >> alarm.log
curl --silent -X GET 'http://'$login':'$haslo'@'$ip'/getregister.cgi?device=0&alarm_tco1_hi' >> alarm.log && echo >> alarm.log

# WERYFIKACJA POBRANYCH DANYCH Z CZUJNIKÓW
if [ -s alarm.log ]; then
        > null &&  rm null
else
    echo "Brak danych. Sprawdź poprawność adresu, loginu lub hasła"
    exit 1;
fi

# OBRÓBKA WYNIKÓW
while read f; do
    parametr=$(echo $f | awk '{ print $5 }' | cut -f2 -d'=');
    parametr="${parametr#?}";
    parametr="${parametr%?}";
    wartosc=$(echo $f | awk '{ print $6 }' | cut -f2 -d'=' | cut -f2 -d '"');

    OUTPUT=$OUTPUT"${parametr}:${wartosc}; "

    if [ $wartosc == "1" ] ; then

    # ZAPISANIE ODCZYTU DO  HISTORII
    echo $(date '+%Y-%m-%d %H:%M:%S') - "$parametr":"$wartosc" >> alarm_status_historia.log
        
        if [ $parametr == "alarm_otw_zasob" ]; then
            echo "2" > alarm_status.log
            break;
        elif [ $parametr == "alarm_uszk_pod" ]; then
            echo "3" > alarm_status.log
            break;
        elif [ $parametr == "alarm_zasobnik" ]; then
            echo "4" > alarm_status.log
            break;    
        else
            echo $wartosc > alarm_status.log
            break;
        fi
    else 
        echo $wartosc > alarm_status.log  
    fi

done <alarm.log

# USUWANIE PLIKU POMOCNICZEGO
rm -f alarm.log

# WYŚWIETLNIE WYNIKU 
echo `cat alarm_status.log `