# Casos de Prueba para RptEmisionLocales

## Caso 1: Previsualización exitosa
- **Entrada:**
  ```json
  { "eRequest": { "action": "get", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 5 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un local
  - Cada local tiene campos: id_local, renta, adeudo, recargos, subtotal, meses

## Caso 2: Emisión exitosa
- **Entrada:**
  ```json
  { "eRequest": { "action": "emit", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 5, "usuario_id": 10 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.message contiene 'Emisión realizada correctamente'
  - eResponse.data es un array con status 'inserted' o 'exists' por local

## Caso 3: Error por parámetros faltantes
- **Entrada:**
  ```json
  { "eRequest": { "action": "emit", "params": { "oficina": 2, "axo": 2024, "periodo": 6 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.errors contiene los campos faltantes

## Caso 4: Consulta de mercados
- **Entrada:**
  ```json
  { "eRequest": { "action": "get-mercados", "params": { "oficina": 2 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array de mercados con campos id, descripcion

## Caso 5: Emisión duplicada (ya existe adeudo)
- **Entrada:**
  ```json
  { "eRequest": { "action": "emit", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 5, "usuario_id": 10 } } }
  ```
- **Precondición:** Ya se ejecutó la emisión para ese periodo/mercado/oficina.
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene status 'exists' para los locales ya emitidos
