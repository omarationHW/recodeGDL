# Casos de Prueba para Observaciones de Comprobante

## Caso 1: Consulta exitosa de observación
- **Entrada:** { "action": "get_observa_comprobante", "payload": { "cvecuenta": 12345 } }
- **Esperado:** success=true, data contiene campos feccap, capturista, axocomp, nocomp, observacion

## Caso 2: Actualización exitosa de observación
- **Entrada:** { "action": "update_observa_comprobante", "payload": { "cvecuenta": 12345, "observacion": "ACTUALIZACION TEST" } }
- **Esperado:** success=true, data.message='Observación actualizada correctamente'
- **Verificación:** Consultar nuevamente y observar el cambio

## Caso 3: Consulta de histórico existente
- **Entrada:** { "action": "get_historico_comprobante", "payload": { "cvecuenta": 12345, "axocomp": 2024, "nocomp": 1001, "feccap": "2024-06-01" } }
- **Esperado:** success=true, data contiene campos cvecuenta, axocomp, nocomp, feccap, observacion

## Caso 4: Consulta con cuenta inexistente
- **Entrada:** { "action": "get_observa_comprobante", "payload": { "cvecuenta": 999999 } }
- **Esperado:** success=false, message='Comprobante no encontrado'

## Caso 5: Actualización con datos inválidos
- **Entrada:** { "action": "update_observa_comprobante", "payload": { "cvecuenta": null, "observacion": "" } }
- **Esperado:** success=false, message indica error de validación
