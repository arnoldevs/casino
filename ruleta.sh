#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

ctrl_c ()
{
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  # Recuperar el cursor antes de salir
  tput cnorm; exit 1
}
trap ctrl_c INT
helpPanel ()
{
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso: $0${endColour}\n"
  echo -e "\t${turquoiseColour}-m)${endColour}${yellowColour} Cantidad de dinero con el que se desea jugar${endColour}${purpleColour} (${endColour}USD${purpleColour})${endColour}"
  echo -e "\t${turquoiseColour}-t)${endColour}${purpleColour} Técnica a utilizar${endColour} \"-t <option(1/2)>\""
  echo -e "\t\t${purpleColour}1 = Martingala \n\t\t2 = Inverse Labrouchere${endColour}\n"
  exit 1
}

while getopts "m:t:h" args; do
  case $args in
    m) money=$OPTARG;;
    t) technique=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ ! "$1" ]; then
  helpPanel
fi

martingala ()
{
  echo -e "\n${yellowColour}[+] ${endColour}${grayColour}Dinero actual: ${endColour}${yellowColour}$money${endColour}\$\n"
  echo -ne "${yellowColour}[+] ${endColour}${grayColour}¿Cuál es la cantidad a apostar? -> ${endColour}" && read initial_bet
  echo -ne "${yellowColour}[+] ${endColour}${grayColour}¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar
# Ocultar el cursor
tput civis 
backup_initial_bet=$initial_bet
play_counter=0
bad_plays=""
while true; do
  money="$(($money-$initial_bet))"
  #echo -e "\n${yellowColour}[+] ${endColour}Acabas de apostar${blueColour} $initial_bet${endColour}\$ y en total tienes${yellowColour} $money${endColour}\$"
  random_number="$(($RANDOM % 37))"
  if [ $money -ge 0 ]; then
    case "$par_impar" in
      par)
        if [ "$random_number" -eq 0 ]; then
         #echo -e "${yellowColour}[+] ${endColour}${redColour}Ha salido${endColour}${blueColour} 0${endColour}${redColour}, por lo tanto has perdido${endColour}"
          initial_bet=$((initial_bet*2))
          bad_plays+="$random_number "
          #echo -e "${yellowColour}[+] ${endColour}Tu saldo es: ${blueColour}$money\$${endColour}"
        else
          #echo -e "${yellowColour}[+] ${endColour}Ha salido el número${blueColour} $random_number${endColour}"
          if [[ "(($random_number % 2))" -eq 0 ]]; then
            #echo -e "${yellowColour}[+] ${endColour}${greenColour}El número que ha salido es par${endColour}"
            reward="$(($initial_bet*2))"
            money="$(($money+$reward))"
            bad_plays=""
            #echo -e "${yellowColour}[+] ${endColour}¡Has ganado${greenColour} $reward${endColour}\$!, tu nuevo saldo es:${blueColour} $money${endColour}\$"
            initial_bet=$backup_initial_bet
          elif [[ "(($random_number % 2))" -ne 0 ]]; then
            #echo -e "${yellowColour}[+] ${endColour}${redColour}El número que ha salido es impar${endColour}"
            initial_bet=$((initial_bet*2))
            bad_plays+="$random_number "
            #echo -e "${yellowColour}[+] ${endColour}Tu saldo es: ${blueColour}$money\$${endColour}"
          fi
        fi
      ;;
      impar)
        if [ "$random_number" -eq 0 ]; then
         #echo -e "${yellowColour}[+] ${endColour}${redColour}Ha salido${endColour}${blueColour} 0${endColour}${redColour}, por lo tanto has perdido${endColour}"
          initial_bet=$((initial_bet*2))
          bad_plays+="$random_number "
          #echo -e "${yellowColour}[+] ${endColour}Tu saldo es: ${blueColour}$money\$${endColour}"
        else
          #echo -e "${yellowColour}[+] ${endColour}Ha salido el número${blueColour} $random_number${endColour}"
          if [[ ! "(($random_number % 2))" -eq 0 ]]; then
            #echo -e "${yellowColour}[+] ${endColour}${greenColour}El número que ha salido es impar${endColour}"
            reward="$(($initial_bet*2))"
            money="$(($money+$reward))"
            bad_plays=""
            #echo -e "${yellowColour}[+] ${endColour}¡Has ganado${greenColour} $reward${endColour}\$!, tu nuevo saldo es:${blueColour} $money${endColour}\$"
            initial_bet=$backup_initial_bet
          elif [[ "(($random_number % 2))" -eq 0 ]]; then
            #echo -e "${yellowColour}[+] ${endColour}${redColour}El número que ha salido es par${endColour}"
            initial_bet=$((initial_bet*2))
            bad_plays+="$random_number "
            #echo -e "${yellowColour}[+] ${endColour}Tu saldo es: ${blueColour}$money\$${endColour}"
          fi
        fi
      ;;
    esac
  else
    echo -e "\n${yellowColour}[!]${endColour}${redColour} Te has quedado sin saldo${endColour}"
    echo -e "\t${yellowColour}[+]${endColour} Ha habido un total de ${yellowColour}$play_counter${endColour} jugada(s)"
    echo -e "\t${yellowColour}[+]${endColour} A continuación se representarán las malas jugadas concecutivas que provocaron tu derrota:"
    echo -e "\t${redColour}$bad_plays${endColour}"
    tput cnorm; exit 0
  fi

  tput cnorm
  let play_counter+=1
done
}

if [ $money ] && [ $technique ]; then
  if [ $technique -eq 1 ]; then
    martingala
  else
    echo -e "\n${yellowColour}[!]${endColour}${redColour} La técnica introducida no existe${endColour}" 
  helpPanel
  fi
fi
