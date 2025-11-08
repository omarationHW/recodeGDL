# Casos de Prueba TramiteBajaLic

## Caso 1: Consulta de Licencia Existente
- **Entrada**: { "eRequest": { "action": "consultar", "params": { "licencia": 123456 } } }
- **Esperado**: eResponse.success = true, eResponse.data.propietarionvo no vacío, eResponse.adeudos es array

## Caso 2: Consulta de Licencia Inexistente
- **Entrada**: { "eRequest": { "action": "consultar", "params": { "licencia": 999999 } } }
- **Esperado**: eResponse.success = false, eResponse.message = 'Licencia no encontrada'

## Caso 3: Tramitar Baja con Datos Completos
- **Entrada**: { "eRequest": { "action": "tramitar_baja", "params": { "licencia": 123456, "motivo": "Cierre", "baja_admva": "2024-07-01", "usuario": "jlopezv" } } }
- **Esperado**: eResponse.success = true, eResponse.folio > 0, eResponse.total > 0

## Caso 4: Tramitar Baja con Datos Incompletos
- **Entrada**: { "eRequest": { "action": "tramitar_baja", "params": { "licencia": 123456, "motivo": "", "baja_admva": "", "usuario": "" } } }
- **Esperado**: eResponse.success = false, eResponse.message = 'Datos incompletos para tramitar baja'

## Caso 5: Recalcular Proporcional
- **Entrada**: { "eRequest": { "action": "recalcular", "params": { "licencia": 123456 } } }
- **Esperado**: eResponse.success = true, eResponse.message = 'Recalculo realizado'

## Caso 6: Imprimir Orden de Pago sin Folio
- **Entrada**: { "eRequest": { "action": "imprimir_orden", "params": { "folio": null } } }
- **Esperado**: eResponse.success = false, eResponse.message = 'Folio requerido para impresión'
