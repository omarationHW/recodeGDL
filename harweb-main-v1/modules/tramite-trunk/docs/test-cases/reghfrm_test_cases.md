# Casos de Prueba para Formulario reghfrm

## Caso 1: Consulta básica de historial
- **Entrada**: { "eRequest": { "action": "list", "params": { "cvecuenta": 123456 } } }
- **Esperado**: eResponse.success = true, eResponse.data contiene lista de movimientos históricos

## Caso 2: Consulta de detalle de movimiento
- **Entrada**: { "eRequest": { "action": "show", "params": { "cvecuenta": 123456, "axocomp": 2022, "nocomp": 15 } } }
- **Esperado**: eResponse.success = true, eResponse.data contiene un solo registro con todos los campos

## Caso 3: Búsqueda avanzada por capturista y fechas
- **Entrada**: { "eRequest": { "action": "filter", "params": { "filters": { "capturista": "jdoe", "feccap_from": "2022-01-01", "feccap_to": "2022-12-31" } } } }
- **Esperado**: eResponse.success = true, eResponse.data contiene sólo los movimientos del capturista y fechas indicadas

## Caso 4: Error por falta de parámetros
- **Entrada**: { "eRequest": { "action": "show", "params": { "cvecuenta": 123456 } } }
- **Esperado**: eResponse.success = false, eResponse.message indica parámetros faltantes

## Caso 5: Consulta de historial de cuenta inexistente
- **Entrada**: { "eRequest": { "action": "list", "params": { "cvecuenta": 999999 } } }
- **Esperado**: eResponse.success = true, eResponse.data es array vacío
