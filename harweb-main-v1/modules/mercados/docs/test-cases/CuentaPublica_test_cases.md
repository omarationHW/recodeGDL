# Casos de Prueba para Cuenta Pública

## Caso 1: Consulta exitosa de adeudos
- **Input:** { "action": "getEstadAdeudo", "params": { "oficina": 1, "axo": 2024, "periodo": 6 } }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=""

## Caso 2: Consulta de totales exitosa
- **Input:** { "action": "getTotalAdeudo", "params": { "oficina": 1, "axo": 2024, "periodo": 6 } }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=""

## Caso 3: Generación de reporte
- **Input:** { "action": "getCuentaPublicaReport", "params": { "oficina": 1, "axo": 2024 } }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=""

## Caso 4: Parámetros inválidos
- **Input:** { "action": "getEstadAdeudo", "params": { "oficina": 1, "axo": 1800, "periodo": 6 } }
- **Resultado esperado:** HTTP 200, success=false, data=null, message contiene error de validación

## Caso 5: Usuario no autenticado
- **Input:** { "action": "getEstadAdeudo", "params": { "oficina": 1, "axo": 2024, "periodo": 6 } } (sin token de autenticación)
- **Resultado esperado:** HTTP 401 Unauthorized

## Caso 6: Acción no soportada
- **Input:** { "action": "unknownAction", "params": {} }
- **Resultado esperado:** HTTP 200, success=false, message='Acción no soportada'
