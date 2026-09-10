#!/bin/bash

function get_classroom() {
    correcto=0
    while [ $correcto -eq 0 ]
    do
        classroom=$(zenity --title="Número de aula" --cancel-label="Salir de la configuración" --entry --text "Introduce el numero de aula (tiene que ser mayor a 0, menor que 254 y no puede ser 10):")
        if [ $? -ne 0 ]; then
        	zenity --no-wrap --info --title="Saliendo (3)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
            echo "Se sale de la configuración (3): `date`"
            exit 0
        fi

        # check the answer

        re='^[0-9]+$'
        if ! [[ $classroom =~ $re ]] ; then
            zenity --error --no-wrap --title="ERROR" --text "Alguno de los carácteres que has introducido no es un número. \nValor introducido: $classroom.\nVuelve a intentarlo "  2> /dev/null
    	elif [ $classroom -gt 253 ]; then
            zenity --error --no-wrap --title="ERROR" --text "El número debe ser menor que 254. \nValor introducido: $classroom.\nVuelve a intentarlo "  2> /dev/null
        elif [ $classroom -eq 0 ]; then
            zenity --error --no-wrap --title="ERROR" --text "El numero debe ser mayor que 0. \nValor introducido: $classroom.\nVuelve a intentarlo "  2> /dev/null
        elif [ $classroom -eq 10 ]; then
            zenity --error --no-wrap --title="ERROR" --text "El número no puede ser 10 ya que es la red del centro. \nValor introducido: $classroom.\nVuelve a intentarlo "  2> /dev/null       
        else
            # Remove leading zeros converting to base10
            classroom=$((10#$classroom))
            correcto=1    
        fi
    done

    echo $classroom
}

function get_pc_number() {
    correcto=0
    while [ $correcto -eq 0 ]
    do
        pc_number=$(zenity --title="Número de PC" --cancel-label="Salir de la configuración" --entry --text "Introduce el número de PC donde va estar el PC en el aula $aula (0 para el PC del profesor y el valor debe ser menor a 100)::")
        if [ $? -ne 0 ]; then
            zenity --no-wrap --info --title="Saliendo (4)" --text "Saliendo de la configuración del equipo. No se ha efectuado ningún cambio. \nRevise el log /scripts/configurar_equipo.log"  2> /dev/null
            echo "Se sale de la configuración (4): `date`"
            exit 0
        fi

        re='^[0-9]+$'
        if ! [[ $pc_number =~ $re ]] ; then
            zenity --error --no-wrap --title="ERROR" --text "Alguno de los carácteres que has introducido no es un número. \nValor introducido: $pc_number.\nVuelve a intentarlo "  2> /dev/null
        elif [ $pc_number -gt 99 ]; then
            zenity --error --no-wrap --title="ERROR" --text "El número debe ser menor que 100. \nValor introducido: $pc_number.\nVuelve a intentarlo "  2> /dev/null  
        else
            # Remove leading zeros converting to base10
            pc_number=$((10#$pc_number))
            correcto=1        
        fi
    done

    echo $pc_number
}