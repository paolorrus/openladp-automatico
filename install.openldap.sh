#!/bin/bash

# Comprobar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root."
  exit 1
fi

# Verificar si OpenLDAP ya está instalado
if dpkg -l | grep -q slapd; then
  echo "OpenLDAP ya está instalado."
  exit 0
fi

# Actualizar paquetes e instalar OpenLDAP
echo "Instalando OpenLDAP..."
apt update && apt install slapd ldap-utils -y

# Configurar el nombre de dominio
read -p "Introduce el nombre de dominio (ej. example.com): " DOMAIN_NAME
echo "Dominio configurado como $DOMAIN_NAME"

# Definir estructura LDAP
cat <<EOF > estructura.ldif
dn: dc=$(echo "$DOMAIN_NAME" | sed 's/\./,dc=/g')
objectClass: top
objectClass: dcObject
objectClass: organization
o: $DOMAIN_NAME
dc: $(echo "$DOMAIN_NAME" | cut -d '.' -f 1)

dn: ou=usuarios,dc=$(echo "$DOMAIN_NAME" | sed 's/\./,dc=/g')
objectClass: organizationalUnit
ou: usuarios
EOF

# Aplicar configuración LDAP
ldapadd -x -D "cn=admin,dc=$(echo "$DOMAIN_NAME" | sed 's/\./,dc=/g')" -w admin -f estructura.ldif

echo "Instalación y configuración de OpenLDAP completada."
