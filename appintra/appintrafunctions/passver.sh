#!/bin/bash
#appintraauthfunction.lib
#funkcje s�u��ce autoryzacji u�ytkownika w bazie danych $DbName
#Autor: Nachszon
#Kwiecie� 206

#Opis dzia�ania:
#Program wczytuje podane przez u�ytkownika has�o
#Nast�puje pr�ba wykonania instrukcji select count na bazie danych, 
#kt�rej wynik w przypadku powodzenia zostanie przypisany zmiennej logCounter

#Powodzenie lub niepowodzenie autoryzacji jest sprawdzane przez weryfikacj� warto�ci kodu
#zwracanego przez polecenie psql (w funkcji

#Zmienna logCounter przechowuje liczb� logowa� poszczeg�lnych u�ytkownik�w do bazy appintradb
#Je�eli $logCounter==0, w�wczas u�ytkownik jest proszony o zmian� has�a

DbName=appintradb



function func_basic_authorization()
{
clear
echo "Podaj haslo do bazy appintra"
stty -echo
read -r pass_from_requester
export PGPASSWORD=$pass_from_requester
stty echo

#Sprawdzamy, ktory raz u�ytkownik sie loguje
logCounter=$(psql -A -t -c "select count(*) from login_data where login='$USER'" 2>/dev/null $DbName)
StartPassword=$(psql -A -t -c "select start_password from tab_authorization" $DbName)  


#weryfikacja poprawnosci hasla
if [ "$?" != 0 ]
then
clear 
printf "|##################################|
|++++++++++++++++++++++++++++++++++|
|##################################|
|++++++++++NO ENTRANCE!++++++++++++| 
|##################################|
|++++++++++++++++++++++++++++++++++|
|#######INCORRECT PASSWORD#########|
|++++++++++++++++++++++++++++++++++|
|##################################|
|++++++++++++++++++++++++++++++++++|
|##################################|\n"

printf "\n<enter>\n"
read
exit
fi
}

#Funkcj� prefunc_verification_identity_passwords
#mo�na wywo�a� tylko w obr�bie funkcji
#func_check_number_of_logins
function prefunc_verification_identity_passwords()
{
stty echo
#weryfikacja identycznosci hasel
if [ "$new_pass_from_requester" = "$StartPassword" ]
then
clear 
printf '\E[2;31;47mnowe haslo nie moze byc identyczne z haslem startowym'; tput sgr0;
printf "\n\n<enter>\n"
read
exit
fi

#request o powt�rzenie nowego has�a
clear
echo -e '\E[1;33;40mPowtorz haslo do bazy appintra\n';tput sgr0;
stty -echo
read -r repeated_new_pass_from_requester
stty echo

#weryfikacja zgodno�ci nowego has�a z has�em powt�rzonym
if [ ! "$new_pass_from_requester" ==  "$repeated_new_pass_from_requester" ]
then
clear
printf '\E[2;31;47mmiszmasz: hasla nie pasuja do siebie\n'; tput sgr0;
printf "\n<enter>\n"
read
exit
fi

psql -c "ALTER USER \"$USER\" ENCRYPTED PASSWORD '$new_pass_from_requester'" 1>/dev/null $DbName;
export PGPASSWORD=$new_pass_from_requester



}

function func_check_number_of_logins()
{
#weryfikacja liczby logowan
if [ "$logCounter" == 0 ]
then
clear
echo -e '\E[1;33;40mwymagana zmiana hasla\n
Podaj nowe haslo do bazy appintra';tput sgr 0;
stty -echo
read -r new_pass_from_requester
prefunc_verification_identity_passwords
stty echo
fi

psql -c "insert into login_data (login,login_date) values ('$USER','now')" 1>/dev/null $DbName;

}


function func_pass_verification(){
func_basic_authorization
func_check_number_of_logins
#func_verification_identity_passwords
}

#funkcja zmiany has�a na request u�ytkownika
function func_change_password(){

clear
printf "Podaj nowe haslo do bazy danych\n"
stty -echo
read -r change_pass_from_requester
stty echo
clear
printf "Powtorz nowe haslo do bazy danych\n"
stty -echo
read -r repeated_change_pass_from_requester
stty echo

#weryfikacja zgodno�ci nowego has�a z has�em powt�rzonym
if [ ! "$change_pass_from_requester" ==  "$repeated_change_pass_from_requester" ]
then
clear
printf '\E[2;31;47mmiszmasz: hasla nie pasuja do siebie\n'; tput sgr0;
printf "\n<enter>\n"
read
return 1
fi

psql -c "ALTER USER \"$USER\" ENCRYPTED PASSWORD '$change_pass_from_requester'" 1>/dev/null $DbName;
export PGPASSWORD=$change_pass_from_requester
clear
printf "Haslo zostalo zmienione\n"
printf "\n<enter>\n"
read
}