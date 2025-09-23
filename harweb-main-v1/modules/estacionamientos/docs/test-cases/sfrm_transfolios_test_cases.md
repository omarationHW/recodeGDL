# Casos de Prueba

## Caso 1: Alta de Multas de Estacionómetros
- **Entrada**: Archivo TXT con 3 líneas válidas de multas.
- **Acción**: Altas de Multas de Estacionómetros.
- **Resultado esperado**: Los 3 registros se insertan en ta14_folios_adeudo y la respuesta muestra 'OK' para cada uno.

## Caso 2: Baja de Multas con Folio Inexistente
- **Entrada**: Archivo TXT con 1 folio que no existe en la base de datos.
- **Acción**: Bajas de Multas de Estacionómetros.
- **Resultado esperado**: El resultado muestra 'error' y mensaje 'No se encontró el folio'.

## Caso 3: Alta de Calcomanías con Fecha Inválida
- **Entrada**: Archivo TXT con una línea donde la fecha no es válida (ejemplo: '32132024').
- **Acción**: Altas de Calcomanías.
- **Resultado esperado**: El resultado muestra 'error' y mensaje de error de conversión de fecha.

## Caso 4: Archivo TXT vacío
- **Entrada**: Archivo TXT sin líneas.
- **Acción**: Cualquier acción.
- **Resultado esperado**: El sistema no permite enviar y muestra mensaje de error.

## Caso 5: Archivo con líneas duplicadas
- **Entrada**: Archivo TXT con dos líneas idénticas.
- **Acción**: Altas de Multas.
- **Resultado esperado**: El primer registro se inserta, el segundo muestra error de duplicidad (si la tabla tiene restricción).
