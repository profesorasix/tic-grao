#!/bin/bash
ignorar="administrador admin sudo guest-user admingva admingva2 root remoto alumnom alumnot profesor"
for usuario in $(ls -1 /home/)
do
        borrar="si"
        for ig in $ignorar
        do
                if [ "$ig" == "$usuario" ]; then
                        borrar="no"
                        break
                #else
                        #borrar="si"
                fi
        done
        if [ "$borrar" == "si" ]; then
                rm -r -f /home/$usuario
                if [ $? -eq 0 ]; then
                        echo El usuario ha sido borrado correctamente $usuario
                else
                        echo Error al borrar el usuario $usuario
                fi
        else
                echo Ignorando el borrado del usuario $usuario
        fi
done

