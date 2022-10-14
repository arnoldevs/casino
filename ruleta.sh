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
  declare -i random_number="$(($RANDOM % 37))"
  money="$(($money-$initial_bet))"
  #echo -e "\n${yellowColour}[+] ${endColour}Acabas de apostar${blueColour} $initial_bet${endColour}\$ y en total tienes${yellowColour} $money${endColour}\$"
  if [ $money -ge 0 ]; then
    case "$par_impar" in
      par)
        if [ "$random_number" -eq 0 ]; then
         #echo -e "${yellowColour}[!] ${endColour}${redColour}Ha salido${endColour}${blueColour} 0${endColour}${redColour}, por lo tanto has perdido${endColour}"
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
            #echo -e "${yellowColour}[!] ${endColour}${redColour}El número que ha salido es impar${endColour}"
            initial_bet=$((initial_bet*2))
            bad_plays+="$random_number "
            #echo -e "${yellowColour}[+] ${endColour}Tu saldo es: ${blueColour}$money\$${endColour}"
          fi
        fi
      ;;
      impar)
        if [ "$random_number" -eq 0 ]; then
         #echo -e "${yellowColour}[!] ${endColour}${redColour}Ha salido${endColour}${blueColour} 0${endColour}${redColour}, por lo tanto has perdido${endColour}"
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
            #echo -e "${yellowColour}[!] ${endColour}${redColour}El número que ha salido es par${endColour}"
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

inverseLabrouchere ()
{
  echo -e "\n${yellowColour}[+] ${endColour}${grayColour}Dinero actual: ${endColour}${yellowColour}$money${endColour}\$\n"
  echo -ne "${yellowColour}[+] ${endColour}${grayColour}¿A qué deseas apostar continuamente (par/impar)? -> ${endColour}" && read par_impar

  declare -a my_sequence=(1 2 3 4)
  declare -i bet=$((${my_sequence[0]}+${my_sequence[-1]}))
  declare -i total_plays=0
  declare -i limit_to_renew=$(($money+50))
  echo -e "\n${yellowColour}[+] ${endColour}Haz comenzado con la secuencia [${blueColour}${my_sequence[@]}${endColour}]"
  echo -e "${yellowColour}[+]${endColour} El tope a renovar la secuencia está establecido por encima de los ${yellowColour}$limit_to_renew${endColour}\n"
  tput civis

  while true; do 
    declare -i random_number="$(($RANDOM % 37))"
      let total_plays+=1
      money=$(($money - $bet))
      if [ ! "$money" -lt 0 ]; then
        echo -e "${yellowColour}[+]${endColour} Has invertido ${yellowColour}$bet\$${endColour}"
        echo -e "${yellowColour}[+]${endColour} Tienes ${yellowColour}$money${endColour}"

        echo -e "\n${yellowColour}[+]${endColour} Ha salido el número ${purpleColour}$random_number${endColour}"

        case "$par_impar" in
          par)
            if [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ]; then
              echo -e "${yellowColour}[+]${endColour}${greenColour} El numero es par${endColour}"
              reward=$(($bet*2))
              let money+=$reward
              echo -e "${yellowColour}[+]${endColour} Tienes ${yellowColour}$money\$${endColour}"
              
              if [ $money -gt $limit_to_renew ]; then
                 echo -e "${yellowColour}[+]${endColour} Se ha superado el tope establecido de ${yellowColour}$limit_to_renew${endColour}\$ para renovar nuestra secuencia "
                 let limit_to_renew+=50
                 echo -e "${yellowColour}[+]${endColour} El tope se ha establecid en: ${yellowColour}$limit_to_renew${endColour}\$"
                 my_sequence=(1 2 3 4)
                 bet=$((${my_sequence[0]}+${my_sequence[-1]}))
                 echo -e "${yellowColour}[+]${endColour} La secuencia ha sido restablecida a [${blueColour}${my_sequence[@]}${endColour}]"
               else
                  my_sequence+=($bet)
                  my_sequence=(${my_sequence[@]})
                  echo -e "\n${yellowColour}[+] ${endColour}Secuencia actualizada: [${blueColour}${my_sequence[@]}${endColour}]"

                  if [ "${#my_sequence[@]}" -gt 1 ]; then
                    bet=$((${my_sequence[0]}+${my_sequence[-1]}))
                  elif [ "${#my_sequence[@]}" -eq 1 ]; then
                    bet=${my_sequence[0]}
                  fi
              fi
            elif [ "$(($random_number % 2))" -eq 1 ] || [ "$random_number" -eq 0 ]; then
              if [ "$(($random_number % 2))" -eq 1 ]; then
                echo -e "${yellowColour}[!]${endColour}${redColour} El número es impar${endColour}"
              else
                echo -e "${yellowColour}[!]${endColour}${redColour} El número es cero${endColour}"
              fi

               if [ $money -lt $(($limit_to_renew-100)) ]; then
                 echo -e "${redColour}[!]${endColour} Has llegado a un mínimo crítico, procediendo a reajustar el tope"
                 let limit_to_renew-=50
                 echo -e "${yellowColour}[+]${endColour} El tope ha sido renovado a ${yellowColour}$limit_to_renew${endColour}\$"

                 unset my_sequence[0]
                 unset my_sequence[-1] 2>/dev/null
                 my_sequence=(${my_sequence[@]})

                 echo -e "\n${yellowColour}[+] ${endColour}Secuencia actualizada: [${blueColour}${my_sequence[@]}${endColour}]"

                 if [ "${#my_sequence[@]}" -gt 1 ]; then
                   bet=$((${my_sequence[0]}+${my_sequence[-1]}))
                 elif [ "${#my_sequence[@]}" -eq 1 ]; then
                   bet=${my_sequence[0]}
                 fi
               else
                  unset my_sequence[0]
                  unset my_sequence[-1] 2>/dev/null
                  my_sequence=(${my_sequence[@]})
                  echo -e "\n${yellowColour}[+] ${endColour}Secuencia actualizada: [${blueColour}${my_sequence[@]}${endColour}]"
                  
                  if [ "${#my_sequence[@]}" -gt 1 ]; then
                    bet=$((${my_sequence[0]}+${my_sequence[-1]}))
                  elif [ "${#my_sequence[@]}" -eq 1 ]; then
                    bet=${my_sequence[0]}
                  elif [ "${#my_sequence[@]}" -eq 0 ]; then
                    my_sequence=(1 2 3 4)
                    echo -e "${yellowColour}[!]${endColour}${redColour} Has perdido la secuencia${endColour} por lo que será restablecida a [${blueColour}${my_sequence[@]}${endColour}]"
                    bet=$((${my_sequence[0]}+${my_sequence[-1]}))
                  fi
               fi
            fi
          ;;
          impar) echo 2 or 3
          ;;
        esac
    else
      echo -e "\n${yellowColour}[!]${endColour}${redColour} Te has quedado sin saldo${endColour}"
      echo -e "\t${yellowColour}[+]${endColour} Ha habido un total de ${yellowColour}$total_plays${endColour} jugada(s)"
      tput cnorm; exit 0
    fi
  done
}
tput cnorm
if [ $money ] && [ $technique ]; then
  if [ $technique -eq 1 ]; then
    martingala
  elif [ $technique -eq 2 ]; then
    inverseLabrouchere
  else
    echo -e "\n${yellowColour}[!]${endColour}${redColour} La técnica introducida no existe${endColour}" 
  helpPanel
  fi
else
  helpPanel
fi
