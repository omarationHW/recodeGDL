# Casos de Prueba para conscentrosfrm migrado

## Caso 1: Consulta general sin filtros
- **Entrada:** POST /api/execute { "action": "get_centros_list" }
- **Esperado:** Respuesta 200, success=true, data contiene lista de registros

## Caso 2: Filtro por fecha válida
- **Entrada:** POST /api/execute { "action": "get_centros_by_fecha", "params": { "fecha": "2024-06-01" } }
- **Esperado:** Respuesta 200, success=true, data sólo con registros de esa fecha

## Caso 3: Filtro por dependencia existente
- **Entrada:** POST /api/execute { "action": "get_centros_by_dependencia", "params": { "id_dependencia": 2 } }
- **Esperado:** Respuesta 200, success=true, data sólo con registros de esa dependencia

## Caso 4: Filtro por acta (año y número)
- **Entrada:** POST /api/execute { "action": "get_centros_by_acta", "params": { "axo_acta": 2024, "num_acta": 12345 } }
- **Esperado:** Respuesta 200, success=true, data sólo con registros coincidentes

## Caso 5: Filtro por fecha inválida
- **Entrada:** POST /api/execute { "action": "get_centros_by_fecha", "params": { "fecha": "2024-99-99" } }
- **Esperado:** Respuesta 422, success=false, errors indica error de validación

## Caso 6: Filtro por dependencia inexistente
- **Entrada:** POST /api/execute { "action": "get_centros_by_dependencia", "params": { "id_dependencia": 999 } }
- **Esperado:** Respuesta 200, success=true, data vacío

## Caso 7: Filtro por acta sin resultados
- **Entrada:** POST /api/execute { "action": "get_centros_by_acta", "params": { "axo_acta": 1900, "num_acta": 1 } }
- **Esperado:** Respuesta 200, success=true, data vacío

## Caso 8: Acción no soportada
- **Entrada:** POST /api/execute { "action": "unknown_action" }
- **Esperado:** Respuesta 400, success=false, message indica acción no soportada
