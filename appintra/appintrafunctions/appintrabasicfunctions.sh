#!/bin/bash
#appintrafunctions
#Wersja: 5.1
#plik zawieraj�cy funkcje aplikacji appintra

#Dzi�ki parametryzacji funkcji oraz jednolitej nomenklaturze funkcji po stronie baz danych
#jedna funkcja okre�laj�ca dan� akcj� (INSERT, SELECT,UPDATE,DELETE)
#wykorzystywana jest dla ka�dego �rodowiska i dla ka�dego subsystemu/systemu
#w wersji 5.1 obs�uguje wi�c trzy �rodowiska i w ka�dym z nich pi�� subsystem�w
#w wersji 5.1 jedn� funkcj� obs�ugiwane jest a� 15 zdarze�
#W przypadku rozwoju czy to liczby �rodowisk czy to liczby system�w/subsystem�w
#liczba funkcji pozostaje bez zmian 


#################################
#Opis parametr�w funkcji $1 i $2#
#################################
#$1 (Env) 
#Zmienna $1 to �rodowisko, kt�re wczytywane jest w funkcji func_main() (funkcja func_main() znajduje si� w pliku g��wnym aplikacji)
#Warto�� $1 przekazywana jest zmiennej $Env, kt�ra nast�pnie wykorzystywana jest w funkcjach
#W wersji 5.1 �rodowiskiem s�: prd/uat/ins

#$2 (SystemName)
#Zmienna $2 to system/subsystem, kt�ry wczytywany jest w funkcji fun_env() (funkcja fun_env() znajduje si� w pliku g��wnym aplikacji)
#Warto�� $2 przekazywana jest zmiennej $SystemName, kt�ra nast�pnie wykorzystywana jest w funkcjach
#W wersji 5.1 system/subsystem to: shell/windows/db/smsc/another

#Nazwa bazy danych
DbName=appintradb


#Funkcja func_insert()
#funkcja wywo�uje funkcj� bazodanow� func_sql_insert_$SystemName_$Env(text, text, text)
#zadaniem funkcji func_insert() jest wprowadzenie u�ytkownika i parametr�w do bazy DbName
#oraz zaprezentowanie u�ytkownikowi zmodyfikowanego wiersza w bazie danych
#obydwa zadania (insert oraz select) realizowane s� w tym przypadku jedn� funkcj� bazodanow�
function func_insert()

{
	Env=$1
	SystemName=$2

	clear
	echo "Podaj uzytkownika ($SystemName $Env)"
	read -r insert_user 
	echo "Podaj haslo dla uzytkownika  $insert_user ($SystemName $Env)"
	read -r insert_pass
	echo "Podaj nazwe hosta ($SystemName $Env)"
	read -r insert_host
	clear

	psql -c "select distinct user"_"$SystemName"_"$Env AS \"uzytkownik ($SystemName $Env)\"  ,pass_$SystemName"_"$Env AS haslo, host"_"$SystemName"_"$Env AS host \
	 from func_sql_insert"_"$SystemName"_"$Env('$insert_user','$insert_pass','$insert_host')" $DbName

	printf "Powyzej dane ktore wprowadziles\n"
	printf "\n<enter>\n"
	read


}


#Funkcja func_select()
#funkcja wywo�uje funkcj� bazodanow� func_sql_select_$SystemName_$Env (text)
#funkcja prezentuje dane wybranego u�ytkownika (nazwa jest wczytana przez u�ytkownika programu appintra)
function func_select(){

	Env=$1
	SystemName=$2
	clear
	echo "Podaj nazwe uzytkownika ($SystemName $Env)"
	read -r select_user
	
	
	clear
	 psql -c "select user"_"$SystemName"_"$Env AS \"uzytkownik ($SystemName $Env)\",pass"_"$SystemName"_"$Env AS haslo ,host"_"$SystemName"_"$Env AS host, moddate"_"$SystemName"_"$Env AS \"data modyfikacji rekordu\" \
	 from func_sql_select"_"$SystemName"_"$Env ('$select_user')" $DbName
	 printf "\n<enter>\n"
	read
	

}

#Funkcja func_select_all()
#funkcja wywo�uje funkcj� bazodanow� func_sql_select_$SystemName_$Env (text)
#funkcja prezentuje dane wszystkich u�ytkownik�w
function func_select_all(){

	Env=$1
	SystemName=$2
	
	
    clear
	 psql -c "select *from view"_"sql"_"$SystemName"_"$Env" $DbName
	 printf "\n<enter>\n"
	read
	

}


#Funkcja func_update()
#funkcja wywo�uje funkcj� bazodanow� func_sql_update_$SystemName_$Env(integer, text)
#Zmiana has�a odbywa si� na podstawie id danego rekordu
#Opr�cz zmiany has�a zadaniem funkcji jest prezntacja zmodyfikowanego wiersza
#Obydwa zadania (update oraz select) realizowane s� w obr�bie tej samej funkcji bazodanowej
function func_update()
{
	Env=$1
	SystemName=$2
	clear
	echo "Podaj uzytkownika, dla ktorego zmieniasz haslo ($SystemName $Env)"
	read -r update_user
	
	psql -c "select id"_"$SystemName"_"$Env AS \"id\",user_$SystemName"_"$Env,pass"_"$SystemName"_"$Env AS \"uzytkownik ($SystemName $Env)\",host"_"$SystemName"_"$Env AS host \
	 from func_sql_select"_"$SystemName"_"$Env ('$update_user')" $DbName

	echo "Podaj id uzytkownika z powyzszej listy, dla ktorego zmieniasz haslo"
	read -r update_id

	echo "Podaj haslo uzytkownika $update_user ($SystemName $Env)"
	read -r update_pass

	clear
	psql -c "select user"_"$SystemName"_"$Env AS \"uzytkownik ($SystemName $Env)\",pass"_"$SystemName"_"$Env AS \"haslo\",host"_"$SystemName"_"$Env AS \"host\" \
	from func_sql_update"_"$SystemName"_"$Env($update_id, '$update_user', '$update_pass')" $DbName

	printf "\nPowyzej dane, ktore wprowadziles\n"
	printf "\n<enter>\n"
	read

}


#Funkcja func_delete()
#Funkcja wywo�uje funkcj� bazodanow� func_sql_delete_$SystemName_$Env(integer)
#Zadaniem funkcji func_delete() jest usuni�cie wybranego rekordu na podsatwie 
#nazwy u�ytkownika oraz id rekordu
#Opr�cz usuni�cia rekordu zadaniem funkcji jest r�wnie� wys�anie komunikatu
#na terminal u�ytkownika
#Obydwa zadania realizowane s� w obr�bie tej samej funkcji bazodanowej 
function func_delete()
{
	Env=$1
	SystemName=$2
	clear
	
	echo "Podaj uzytkownika, ktorego chcesz usunac"
	read -r delete_user

	 psql -c "select id"_"$SystemName"_"$Env AS id,user"_"$SystemName"_"$Env AS \"uzytkownik ($SystemName $Env)\", pass"_"$SystemName"_"$Env AS haslo, host"_"$SystemName"_"$Env \
	 from func_sql_select"_"$SystemName"_"$Env ('$delete_user')" $DbName
	
	echo "Podaj id uzytkownika z powyzszej listy, ktorego chcesz usunac"
        read -r delete_id
	clear
	psql -t -c "select message AS INFO from func_sql_delete"_"$SystemName"_"$Env($delete_id,'$delete_user')" $DbName
	printf "\n<enter>\n"
	read

}

#Funkcja func_system()
#Funkcja prezentuje i realizuje opcje
#dost�pne w obr�bie danego �rodowiska
#W momencie wywo�ania funkcja musi zna� ju� warto�ci parametr�w
#$1 ($Env) oraz $SystemName ($2)
#Warto�� $1 uzyskiwana jest w funkcji func_main() (plik g��wny aplikacji)
#Warto�c $2 uzyskiwana jest w funkcji func_env() (plik g��wny aplikacji)
function func_system()
{
action_from_requester=0
while [ "$action_from_requester" != "q" ] 
do
clear
printf "$2 ($1)\n\n\n"
echo "1) Wprowadz nowego uzytkownika  ($1 $2)
2) Pokaz dane wybranego uzytkownika ($1 $2)
3) Pokaz dane wszystkich uzytkownikow ($1 $2)
4) Zmien haslo wybranego uzytkownika ($1 $2)
5) Usun wybranego uzytkownika ($1 $2)
p) Powrot do srodowiska $1 
m) Powrot do menu glownego 
z) Zamknij program appintra
"
printf "\nWybierasz:"

read action_from_requester
case $action_from_requester in
1)func_insert $1 $2
;;
2)func_select $1 $2
;;
3)func_select_all $1 $2
;;
4)func_update $1 $2
;;
5)func_delete $1 $2
;;
p)func_env $1
;;
m)func_main
;;
z)exit 
esac
done
}

#KONIEC
