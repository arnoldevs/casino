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
