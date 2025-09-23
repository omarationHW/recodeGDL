# Casos de Prueba para SdosFavor_Pagos

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Crear pago válido | reca: '101', caja: '01', folio: '000123', importe: '1500.00', fecha: '2024-06-10' | Pago creado, aparece en la lista |
| 2 | Crear pago duplicado | reca: '101', caja: '01', folio: '000123', importe: '1500.00', fecha: '2024-06-10' | Error: clave duplicada |
| 3 | Localizar pago existente | reca: '101', caja: '01', folio: '000123' | Pago localizado, datos mostrados |
| 4 | Localizar pago inexistente | reca: '999', caja: '99', folio: '999999' | Mensaje: Pago no encontrado |
| 5 | Editar importe de pago | reca: '101', caja: '01', folio: '000123', nuevo importe: '2000.00' | Importe actualizado |
| 6 | Eliminar pago existente | reca: '101', caja: '01', folio: '000123' | Pago eliminado, ya no aparece en la lista |
| 7 | Eliminar pago inexistente | reca: '999', caja: '99', folio: '999999' | Mensaje: Pago no encontrado |
| 8 | Crear pago con importe negativo | reca: '102', caja: '02', folio: '000124', importe: '-100.00', fecha: '2024-06-11' | Error: importe inválido |
| 9 | Crear pago con fecha inválida | reca: '103', caja: '03', folio: '000125', importe: '100.00', fecha: '2024-02-30' | Error: fecha inválida |
| 10 | Listar pagos | - | Lista de pagos mostrada correctamente |
