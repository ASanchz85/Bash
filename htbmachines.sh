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
	echo -e "\t${yellowColor}d)${endColor} ${grayColor}Filtrar por dificultad (Fácil, Media, Difícil, Insane)${endColor}"
	echo -e "\t${yellowColor}y)${endColor} ${grayColor}Obtener link de la resolución de la máquina en Youtube${endColor}"
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

	machineChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
	
	if [ "$machineChecker" ]; then

		echo -e "\n${yellowColor}[+]${endColor} Listando propiedades de la máquina ${cyanColor}$machineName${endColor}:\n"
		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'

	else
		echo -e "\n${redColor}[!] La máquina que buscas no existe${endColor}\n"
	fi
}

function searchIP(){
	ipAddress="$1"

	machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk '{print $NF}' | tr -d '"' | tr -d ',')"

	if [ "$machineName" ]; then
		echo -e "\n${yellowColor}[+]${endColor} La máquina que coincide con la IP ${cyanColor}$ipAddress${endColor} es ${redColor}$machineName${endColor}:"
		searchMachine $machineName
	else
		echo -e "\n${redColor}[!] La máquina que buscas no existe${endColor}\n"
	fi
}

function getYoutubeLink(){
	machineName="$1"

	YTLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk '{print $NF}')"

	if [ $YTLink ]; then
		echo -e "\n${yellowColor}[+]${endColor} El video de la maquina ${cyanColor}$machineName${endColor} es ${redColor}$YTLink${endColor}"
		echo -e "\t${yellowColor}[?]${endColor}${grayColor} Tip: Pulsa Ctrl + clic derecho${endColor} ${yellowColor}[?]${endColor}"
	else
		echo -e "\n${redColor}[!] La máquina que buscas no existe${endColor}\n"
	fi
}

function filterByDifficulty(){
	difficulty="$1"
# TO DO: incluir filtrado para acentos
	machineDifficulty="$(cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep name | awk '{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$machineDifficulty" ]; then
		echo -e "\n${yellowColor}[+]${endColor} El listado de máquinas con dificultad ${cyanColor}$difficulty${endColor} son:"
		cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep name | awk '{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColor}[!] No hay máquinas para la dificultad elegida${endColor}\n"
		echo -e "\t${yellowColor}[?]${endColor}${grayColor} Tip: prueba a elegir entre Fácil, Media, Difícil e Insane${endColor} ${yellowColor}[?]${endColor}"
	fi
}

# Indicadores
declare -i parameter_counter=0

while getopts "m:ui:y:d:h" arg; do
	case $arg in
		m) machineName="$OPTARG"; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAddress="$OPTARG"; let parameter_counter+=3;;
		y) machineName="$OPTARG"; let parameter_counter+=4;;
		d) difficulty="$OPTARG"; let parameter_counter+=5;;
		h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	filterByDifficulty $difficulty
else
	helpPanel
fi


