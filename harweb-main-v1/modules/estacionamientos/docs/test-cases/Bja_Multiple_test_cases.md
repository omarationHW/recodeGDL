# Casos de Prueba

## Caso 1: Grabar registros válidos
- **Entrada**: 3 registros completos, archivo='archivo_test_01'
- **Acción**: Grabar
- **Esperado**: 3 registros insertados, mensaje de éxito.

## Caso 2: Grabar con campos obligatorios vacíos
- **Entrada**: 1 registro con placa vacía, archivo='archivo_test_02'
- **Acción**: Grabar
- **Esperado**: Error de validación, no se inserta ningún registro.

## Caso 3: Llenado y Aplicado con registros con anomalia vacía
- **Entrada**: 2 registros, uno con anomalia vacía
- **Acción**: Llenado y Aplicado
- **Esperado**: El registro con anomalia vacía se actualiza a estatus=9.

## Caso 4: Consulta de incidencias sin errores
- **Entrada**: archivo='archivo_test_03' (sin registros con estatus=9)
- **Acción**: Vista
- **Esperado**: Mensaje 'No hay impresión pues no generó errores de validación'.

## Caso 5: Consulta de incidencias con errores
- **Entrada**: archivo='archivo_test_01' (con registros estatus=9)
- **Acción**: Vista
- **Esperado**: Tabla con registros con error de validación.
