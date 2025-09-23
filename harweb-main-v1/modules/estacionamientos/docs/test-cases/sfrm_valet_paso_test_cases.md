# Casos de Prueba

## Caso 1: Carga de archivo válido
- Subir un archivo CSV con 5 filas y 3 columnas.
- Esperar que la vista previa muestre las 5 filas correctamente.
- El botón 'Pasar datos de valet' debe habilitarse.

## Caso 2: Procesamiento exitoso
- Procesar el archivo subido en el caso anterior.
- Verificar que el mensaje indique éxito y que el resumen muestre todas las filas como 'OK'.
- Consultar la tabla valet_data y verificar que los registros fueron insertados.

## Caso 3: Archivo con formato incorrecto
- Subir un archivo CSV con columnas faltantes o datos corruptos.
- Procesar el archivo.
- Verificar que el mensaje indique error y que el resumen muestre las filas con 'ERROR' y el mensaje de excepción.

## Caso 4: Archivo no encontrado
- Intentar procesar un archivo cuyo path no existe en el servidor.
- Verificar que el mensaje indique 'Archivo no encontrado'.

## Caso 5: Archivo demasiado grande
- Subir un archivo mayor al límite permitido.
- Verificar que el sistema rechace el archivo y muestre un mensaje de error adecuado.
