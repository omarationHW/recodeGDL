# Casos de Prueba para CMultFolio

## Caso 1: Consulta de Folios por Rango
- **Entrada:**
  ```json
  { "eRequest": { "action": "search_folios", "params": { "modulo": 11, "zona": 2, "folio": 1000 } } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.folios es un array con al menos un folio

## Caso 2: Visualización de Detalle Individual
- **Entrada:**
  ```json
  { "eRequest": { "action": "folio_detail", "params": { "id_control": 12345 } } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.detail contiene los campos del folio

## Caso 3: Carga de Recaudadoras
- **Entrada:**
  ```json
  { "eRequest": { "action": "list_recaudadoras" } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.recaudadoras es un array con al menos una recaudadora

## Caso 4: Validación de Parámetros Faltantes
- **Entrada:**
  ```json
  { "eRequest": { "action": "search_folios", "params": { "modulo": 11 } } }
  ```
- **Esperado:**
  - Código 400
  - eResponse.success = false
  - eResponse.message indica el parámetro faltante

## Caso 5: Acción No Soportada
- **Entrada:**
  ```json
  { "eRequest": { "action": "unknown_action" } }
  ```
- **Esperado:**
  - Código 400
  - eResponse.success = false
  - eResponse.message indica acción no soportada
