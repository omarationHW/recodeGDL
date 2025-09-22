## Casos de Prueba para AdeudosContratos

### Caso 1: Consulta de Adeudos Vigentes
- **Entrada:**
  ```json
  { "eRequest": { "operation": "listado_adeudos", "params": { "colonia": 101, "calle": 5 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.data es un array con al menos un contrato con campo concepto = 'ADE'.

### Caso 2: Listado de Contratos Liquidados por Colonia y Saldo
- **Entrada:**
  ```json
  { "eRequest": { "operation": "listado_liquidados_col", "params": { "colonia": 102, "importe": 100.00 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.data contiene contratos con concepto = 'LIQ' y saldo <= 100.00.

### Caso 3: Listado de Pagos con Descuento
- **Entrada:**
  ```json
  { "eRequest": { "operation": "listado_pagos_descuento", "params": { "colonia": 103 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.data contiene pagos con cve_descuento > 0.

### Caso 4: Error por parámetros faltantes
- **Entrada:**
  ```json
  { "eRequest": { "operation": "listado_adeudos", "params": { "colonia": 101 } } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.error indica que falta el parámetro 'calle'.

### Caso 5: Operación no soportada
- **Entrada:**
  ```json
  { "eRequest": { "operation": "no_existente", "params": {} } }
  ```
- **Esperado:**
  - HTTP 200
  - eResponse.error = 'Operación no soportada'.
