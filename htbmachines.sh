#!/bin/bash

# Instalar: js-beautify & sponge (moreutils - official packet for debian)

#Colours
redColor="\e[0;31m\033[1m"
redBackground="\e[0;41m\033[1m"
grayColor="\e[0;37m\033[1m"
grayBackground="\e[0;47m\033[1m"
blueColor="\e[0;34m\033[1m"
blueBackground="\e[0;44m\033[1m"
greenColor="\e[0;32m\033[1m"
greenBackground="\e[0;42m\033[1m"
cyanColor="\e[0;36m\033[1m"
cyanBackground="\e[0;46m\033[1m"
purpleColor="\e[0;35m\033[1m"
purpleBackground="\e[0;45m\033[1m"
yellowColor="\e[0;33m\033[1m"
yellowBackground="\e[0;43m\033[1m"

endColor="\033[0m\e[0m"

function ctrl_c(){
  echo -e "\n\n${redColor}[!] Exiting... ${endColor}\n"
  tput cnorm && exit 1
}

# ctrl+C
trap ctrl_c INT

# Variables Globales
main_url="https://htbmachines.github.io/bundle.js"


function helpPanel(){
	echo -e "\n${yellowColor}[+]${endColor}${grayColor} Uso: ${endColor}"
	echo -e "\t${yellowColor}u)${endColor} ${grayColor}Descargar o actualizar archivos necesarios${endColor}"
	echo -e "\t${yellowColor}m)${endColor} ${grayColor}Buscar por un nombre de máquina${endColor}"
	echo -e "\t${yellowColor}i)${endColor} ${grayColor}Buscar por dirección IP${endColor}"
	echo -e "\t${yellowColor}h)${endColor} ${grayColor}Mostrar panel de ayuda${endColor}"
}

function updateFiles(){
#ocultar cursor
tput civis
	echo -e "\n${yellowColor}[+]${endColor} Comprobando repositorios..."
	sleep 2

	if [ ! -f bundle.js ]; then
		echo -e "\n${yellowColor}[+]${endColor} Descargando archivos necesarios..."
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${yellowColor}[+]${endColor} ${cyanColor}Hecho!${endColor}"
	else
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')
	
			if [ $md5_temp_value == $md5_original_value ]; then
				echo -e "\n${yellowColor}[+]${endColor} ${cyanColor}No hay actualizaciones pendientes${endColor}"
				rm bundle_temp.js
			else
				echo -e "\n${yellowColor}[+]${endColor} ${cyanColor}Actualizando...${endColor}"
				rm bundle.js && mv bundle_temp.js bundle.js
				sleep 1
				echo -e "\n${yellowColor}[+]${endColor} ${cyanColor}Todo actualizado!${endColor}"
			fi
	fi
tput cnorm
}

function searchMachine(){
	machineName="$1"

	echo -e "\n${yellowColor}[+]${endColor} Listando propiedades de la máquina ${cyanColor}$machineName${endColor}:\n"

	cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

# Indicadores
declare -i parameter_counter=0

while getopts "m:uh" arg; do
	case $arg in
		m) machineName=$OPTARG; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
else
	helpPanel
fi


