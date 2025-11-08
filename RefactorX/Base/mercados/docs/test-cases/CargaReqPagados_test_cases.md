# Casos de Prueba para CargaReqPagados

## Caso 1: Carga exitosa de pagos
- **Entrada**: Archivo TXT con 3 líneas válidas, cada una con folios de requerimientos existentes.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=ok, grabados=3, importe_multa y importe_gastos sumados correctamente, sin errores.

## Caso 2: Archivo con folio inexistente
- **Entrada**: Archivo TXT con una línea cuyo folio de requerimiento no existe en la base de datos.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=error, mensaje de error indicando el folio inexistente, no se actualiza ese registro.

## Caso 3: Archivo con campos vacíos
- **Entrada**: Archivo TXT con una línea donde el campo 'id_local' o 'folio' está vacío.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=error, mensaje de error de validación, no se procesa ese registro.

## Caso 4: Archivo con formato incorrecto
- **Entrada**: Archivo TXT con líneas de longitud menor a la esperada.
- **Acción**: Procesar pagos.
- **Resultado esperado**: status=error, mensaje de error de parseo, no se procesa ese registro.

## Caso 5: Consulta de totales después de carga
- **Entrada**: Realizar una carga válida y luego consultar los totales.
- **Acción**: Llamar a getTotals con los datos de la última carga.
- **Resultado esperado**: status=ok, totales coinciden con los datos procesados.
