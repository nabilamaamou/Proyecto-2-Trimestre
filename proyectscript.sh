#!/bin/bash

function crear_subdominio {

SUB_DOMAIN="${nombre}.marisma1.local"
ZONE_FILE="/etc/bind/zone/db.marisma1.local"

echo "Actualizando fichero de zona"
echo "\$ORIGIN ${SUB_DOMAIN}."  >>$ZONE_FILE
echo "@ IN  A   ${ip}"  >>$ZONE_FILE
echo "nombre   IN  A   ${ip}"  >>$ZONE_FILE

echo "Reiniciar servicios"

service bind9 reload > /dev/null
service proftpd reload > /dev/null
echo "El subdominio ha creado correctamiente"
sleep 5
clear
menu
}


function crear_host {


USER=$nombre

CONF="${USER}.marisma1.local.conf"

PATH_AVAILABLE="/etc/apache2/sites-available/${CONF}"

PATH_ENABLED="/etc/apache2/sites-enabled/${CONF}"

SUB_DOMAIN="${USER}.marisma.local"

DOCUMENT_ROOT="/var/www/html/$nombre"

INDEX="${DOCUMENT_ROOT}/index.html"

if ! [ -d $DOCUMENT_ROOT ] ; then

echo "Creando documento root"

mkdir -p "$DOCUMENT_ROOT"

fi

touch $PATH_AVAILABLE

if [ -f $PATH_AVAILABLE ] ; then

echo "creando fichero de config"

echo "<VirtualHost *:80>

ServerAdmin admin@$SUB_DOMAIN

ServerName www.$SUB_DOMAIN

DocumentRoot $DOCUMENT_ROOT

<Directory $DOCUMENT_ROOT>

DirectoryIndex index.html

Options Indexes FollowSymLinks MultiViews

AllowOverride all

Require all granted

</Directory>

ErrorLog /var/log/apache2/$SUB_DOMAIN.errorLog.log

LogLevel error

CustomLog /var/log/apache2/$SUB_DOMAIN.customLog.log combined

</VirtualHost>" >>$PATH_AVAILABLE

#index.html

echo "Creando index.html"

echo "<p>Subdominio: $SUB_DOMAIN</p>" >>$INDEX

echo "<p>usuario: $USER</p>" >>$INDEX

a2ensite $CONF

fi
sleep 5
clear
menu
}

function crear_db {

   # Solicita la información necesaria para la creación de la base de datos y el usuario
read -p "Nombre de la nueva base de datos: " db_name
read -p "Nombre del nuevo usuario: " db_user
read -s -p "Contraseña para el nuevo usuario: " db_pass

# Crea la base de datos
mysql -u root -p -e "CREATE DATABASE ${db_name}"

# Crea el usuario y le da todos los privilegios para la nueva base de datos
mysql -u root -p -e "GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'localhost' IDENTIFIED BY '${db_pass}'; FLUSH PRIVILEGES;"

echo "Base de datos '${db_name}' creada con usuario '${db_user}' y contraseña '${db_pass}'."

sleep 5
clear
menu
}

function crear_usuario_ssh {

   # Pedir al usuario que introduzca el nombre del nuevo usuario
echo "Introduce el nombre del usuario:"
read username

# Comprobar si el usuario ya existe
if id "$username" >/dev/null 2>&1; then
    echo "El usuario $username ya existe"
    exit 1
fi

# Crear el usuario con un directorio de inicio y un shell
sudo useradd -m -s /bin/bash $username

# Establecer una contraseña para el usuario
sudo passwd $username

# Dar al nuevo usuario acceso a SSH mediante la adición del usuario al archivo /etc/ssh/sshd_config
sudo bash -c "echo 'AllowUsers $username' >> /etc/ssh/sshd_config"

# Reiniciar el servicio SSH para aplicar los cambios
sudo systemctl restart sshd

# Confirmar que el usuario ha sido creado y que tiene acceso a SSH
echo "El usuario $username ha sido creado y tiene acceso a SSH."

sleep 5
clear
menu
}


function salir {
echo "fin de ejecucion"
exit
}
function error {
sleep 5
clear
menu

}

function menu {
echo -------Servedor de alojamiento---------
echo -------__ opciones ___---------
echo 1.
echo 2.Crear un subdominio en el servidor DNS con las resolución directa e inversa
echo 3.Crear Host virtual en apache
echo 4.Crear base de datos y usuario con todos los privilegios
echo 5.Creación de usuario del sistema para acceso a ssh
echo 6.Salir
read -p "Introduce la opcion que quieres: " opcion
case $opcion in 

2)echo  "Intrudoce el nombre del subdominio que quieres crear: " 
read nombre
echo "Introduce La IP del subdominio: "
read ip
crear_subdominio;;

3)echo  "Intrudoce el nombre del host que quieres crear: " 
read nombre
crear_host;;
4)echo "Crear base de datos y usuario"
crear_db;;
5)crear_usuario_ssh;;
6)salir;;
*) echo Esta circunstancia en la salida estandar
error;;
esac;

}
menu;
