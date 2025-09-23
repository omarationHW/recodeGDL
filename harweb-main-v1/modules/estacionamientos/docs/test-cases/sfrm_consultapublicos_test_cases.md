# Casos de Prueba

## Caso 1: Consulta de lista de estacionamientos públicos
- **Entrada:**
  - POST /api/execute
  - Body: { "eRequest": "getPublicParkingList", "params": {} }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un objeto con campos: id, nombre, numesta, etc.

## Caso 2: Consulta de adeudos de estacionamiento
- **Entrada:**
  - POST /api/execute
  - Body: { "eRequest": "getPublicParkingDebts", "params": { "pubid": 1234 } }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con campos: concepto, axo, mes, adeudo, recargos

## Caso 3: Consulta de multas de estacionamiento
- **Entrada:**
  - POST /api/execute
  - Body: { "eRequest": "getPublicParkingFines", "params": { "numlicencia": 56789 } }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con campos: id_multa, axo_acta, num_acta, etc.

## Caso 4: Consulta de datos generales de licencia
- **Entrada:**
  - POST /api/execute
  - Body: { "eRequest": "getLicenseGeneral", "params": { "numlicencia": 56789 } }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un objeto con campos: id, licencia, propietario, etc.

## Caso 5: Consulta de totales de licencia
- **Entrada:**
  - POST /api/execute
  - Body: { "eRequest": "getLicenseTotals", "params": { "id_licencia": 123, "tipo_l": "L", "redon": "N" } }
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con campos: concepto, importe, obliga, etc.

## Caso 6: Parámetro faltante
- **Entrada:**
  - POST /api/execute
  - Body: { "eRequest": "getPublicParkingDebts", "params": {} }
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message contiene 'pubid is required'
