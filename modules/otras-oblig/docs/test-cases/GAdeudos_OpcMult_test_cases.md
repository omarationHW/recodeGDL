# Casos de Prueba: GAdeudos_OpcMult

## Caso 1: Pago exitoso de adeudo
- **Entrada:** localNum='123', letra='A', fechaPagado='2024-06-10', idRecaudadora=1, caja='1', consecOper='1001', folioRcbo='RCB12345', opción='P', adeudo seleccionado
- **Acción:** Ejecutar pago
- **Resultado esperado:** Mensaje de éxito, adeudo desaparece de la lista de adeudos vigentes, aparece en pagos realizados.

## Caso 2: Intentar ejecutar sin seleccionar adeudo
- **Entrada:** Buscar local válido, no seleccionar ningún adeudo
- **Acción:** Ejecutar opción
- **Resultado esperado:** Mensaje de error 'No existen Adeudos Seleccionados, intenta con otro'.

## Caso 3: Buscar local inexistente
- **Entrada:** localNum='999', letra='Z'
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'No existe REGISTRO ALGUNO con este dato, intentalo de nuevo'.

## Caso 4: Condonar adeudo
- **Entrada:** numExpN='456789', opción='S', adeudo seleccionado
- **Acción:** Ejecutar opción
- **Resultado esperado:** Mensaje de éxito 'Adeudo condonado correctamente.'

## Caso 5: Consultar pagos realizados
- **Entrada:** Buscar localNum='321', letra='B'
- **Acción:** Click en 'Pagados'
- **Resultado esperado:** Tabla con historial de pagos realizados para el local.
