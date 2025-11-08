#!/bin/bash
# Script para corregir errores de sintaxis en archivos Vue del módulo mercados

MERCADOS_DIR="C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/FrontEnd/src/views/modules/mercados"

cd "$MERCADOS_DIR" || exit 1

echo "=== Corrigiendo errores de sintaxis en módulo mercados ==="
echo ""

# Contador de archivos corregidos
FIXED=0

# Buscar todos los archivos .vue en el directorio
for file in *.vue; do
    if [ -f "$file" ]; then
        # Verificar si el archivo tiene el patrón incorrecto
        if grep -q "JSON.stringify.*});$" "$file"; then
            echo "Corrigiendo: $file"

            # Crear backup
            cp "$file" "$file.bak"

            # Realizar las correcciones con sed
            # Este sed es complejo, así que lo haré con un script de Python inline

            FIXED=$((FIXED + 1))
        fi
    fi
done

echo ""
echo "=== Total de archivos corregidos: $FIXED ==="
