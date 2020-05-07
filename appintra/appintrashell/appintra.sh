#!/bin/bash

#appintra.sh
#program do przechowywania danych
#autor: Krzysztof Lipa-Izdebski
#kwiecien 2016
Version=5.1

pathFunction=/opt/appintra/appintrafunctions

source $pathFunction/appintrabasicfunctions.sh
source $pathFunction/passver.sh

func_pass_verification

applicationName=appintra

#funkcja func_info_program
#Przechowuje dane prezentowane w czo³ówce programu
function func_info_program(){

echo -e -n '\E[36;43m '; tput sgr0;
echo -e  " uzytkownik: $USER"
echo -e -n '\E[30;41m '; tput sgr0;
echo -e  " appintra"
echo -e -n  '\E[37;42m '; tput sgr0
echo -e " version: $Version"
echo -e -n '\E[37;44m ';tput sgr0;
echo -e " programowanie:"
echo -e -n  '\E[37;44m ';tput sgr0;
echo -e "Nachszon"
echo -e -n '\E[34;45m ';tput sgr0;
echo -e " 2005 - 2016"
echo -e -n '\E[37;47m ';tput sgr0;
echo -e " Strona domowa aplikacji:"
echo -e -n '\E[37;47m ';tput sgr0;
echo -e
echo -e

}

#funkcja func_env
#Zadaniem funkcji jest prezentacja opcji wybranego œrodowiska (PRD/INS/UAT)
#Wybór œrodowiska nastêpuje w funkcji func_main()
#Funkcja wywo³uje funkcjê func_system, do której dodaje drugi parametr 
#nazwê systemu/subsystemu: shell/windows/db/smsc/another
#w ten sposób funkcja func_system uruchamiania jest z dwoma parametrami
#Exemplum:
#func_system prd shell 
#Subsystem jest zmienn¹, której wartoœæ podaje u¿ytkownik
function func_env(){

clear
printf "Environment: $1\n\n"

main_action_from_requester=0

while [ "$main_action_from_requester" != "z" ]

do

clear

printf "##########################\n\n"
printf "opcje dla srodowiska $1\n\n"
printf "##########################\n\n"
printf "Wybierz opcje:\n\n"

echo "1) Uzytkownicy shella ($1)
2) Uzytkownicy windows ($1)
3) Uzytkownicy baz danych ($1)
4) Uzytkownicy smsc ($1)
5) Uzytkownicy inni ($1)
m) Powrot do menu glownego
z) zamknij"

printf "\nWybierasz:"

read main_action_from_requester

case $main_action_from_requester in
1) func_system $1 shell 
;;
2) func_system $1 windows
;;
3) func_system $1 db
;;
4) func_system $1 smsc
;;
5) func_system $1 another
;;
m) func_main
;;
z) exit

esac

done

}

#funkcja func_main()
#prezentuje œrodowiska do wyboru
#nazwa œrodowiska staje siê parametrem dla "ni¿szych" funkcji
function func_main(){

env_from_requester=0

while [ "$env_from_requester" != "z" ]

do

clear

func_info_program

echo -e "Wybierz srodowisko:\n"

echo "1) PRD
2) UAT
3) INS
4) PREPROD
c) Zmien haslo do bazy $applicationName
z) Zamknij aplikacje $applicationName
"

printf "\nWybor:"

read env_from_requester

case $env_from_requester in

1) func_env prd 
;;
2) func_env uat
;;
3) func_env ins
;;
4) func_env preprod
;;
c) func_change_password 
;;
z) exit

esac

done

}


func_main

#KONIEC
