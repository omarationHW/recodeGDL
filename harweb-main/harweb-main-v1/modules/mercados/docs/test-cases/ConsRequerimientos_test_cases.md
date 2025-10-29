# Casos de Prueba para ConsRequerimientos

## Caso 1: Consulta exitosa de requerimientos
- **Precondición:** El local existe y tiene requerimientos.
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getLocalesByMercado", "params": { "oficina": 1, "num_mercado": 5, "categoria": 2, "seccion": "SS", "local": 123, "letra_local": "A", "bloque": "1" } }
- **Esperado:** Respuesta success=true, data con al menos un local.

## Caso 2: Consulta de requerimientos por local
- **Precondición:** El local existe y tiene requerimientos.
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getRequerimientosByLocal", "params": { "modulo": 11, "control_otr": 12345 } }
- **Esperado:** Respuesta success=true, data con lista de requerimientos.

## Caso 3: Consulta de periodos por requerimiento
- **Precondición:** El requerimiento existe.
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getPeriodosByRequerimiento", "params": { "control_otr": 456 } }
- **Esperado:** Respuesta success=true, data con lista de periodos.

## Caso 4: Error por parámetros faltantes
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getLocalesByMercado", "params": { "oficina": 1 } }
- **Esperado:** success=false, message indicando parámetros faltantes.

## Caso 5: Error por local inexistente
- **Acción:**
  - POST /api/execute
  - Body: { "action": "getLocalesByMercado", "params": { "oficina": 1, "num_mercado": 5, "categoria": 2, "seccion": "XX", "local": 99999, "letra_local": "Z", "bloque": "9" } }
- **Esperado:** success=true, data vacía.
