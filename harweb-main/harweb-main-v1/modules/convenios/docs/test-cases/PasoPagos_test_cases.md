# Casos de Prueba PasoPagos

## Caso 1: Carga exitosa de pagos de contratos
- **Entrada:** Archivo plano con 3 registros válidos de contratos.
- **Acción:** Cargar, procesar y grabar.
- **Esperado:** Los 3 registros aparecen en la tabla, se graban correctamente, mensaje de éxito.

## Caso 2: Archivo de pagos de convenios con error de llave
- **Entrada:** Archivo plano con 2 registros, uno con llave inexistente.
- **Acción:** Cargar, procesar y grabar.
- **Esperado:** Solo el registro con llave válida se graba, el otro se ignora o se reporta como inconsistente.

## Caso 3: Consulta de estatus después de carga
- **Entrada:** Carga previa de 4 registros, 3 grabados, 1 inconsistente.
- **Acción:** Consultar estatus DS.
- **Esperado:** Se muestran 3 grabados, 0 modificados, 1 inconsistente, total 4.

## Caso 4: Archivo vacío o malformado
- **Entrada:** Archivo plano vacío o con formato incorrecto.
- **Acción:** Cargar y procesar.
- **Esperado:** Mensaje de error, no se permite grabar.

## Caso 5: Intento de grabar sin procesar archivo
- **Entrada:** Sin cargar archivo.
- **Acción:** Presionar 'Grabar'.
- **Esperado:** Mensaje de advertencia, no se ejecuta acción.
