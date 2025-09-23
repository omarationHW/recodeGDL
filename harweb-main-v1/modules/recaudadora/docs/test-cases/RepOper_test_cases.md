## Casos de Prueba para RepOper

### Caso 1: Consulta de Totales Correcta
- **Entradas:** fecha = '2024-06-01', recaud = '1', caja = 'A'
- **Acción:** Solicitar totales vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - Los campos `canceladas`, `cheques`, `doc_cero`, `tot_total`, etc. tienen valores numéricos coherentes.

### Caso 2: Consulta de Desglose Correcta
- **Entradas:** fecha = '2024-06-01', recaud = '2', caja = 'B'
- **Acción:** Solicitar desglose vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - El array `data` contiene objetos con los campos: folio, cvecuenta, importe, mensaje, etc.

### Caso 3: Carga de Cajas Dinámica
- **Entradas:** fecha = '2024-06-01', recaud = '3'
- **Acción:** Solicitar cajas vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - El array `data` contiene objetos con campo `caja`.

### Caso 4: Parámetros Faltantes
- **Entradas:** recaud = '1', caja = 'A' (sin fecha)
- **Acción:** Solicitar totales vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `false`.
  - El campo `error` indica parámetro faltante.

### Caso 5: Sin Resultados
- **Entradas:** fecha = '2099-01-01', recaud = '1', caja = 'Z'
- **Acción:** Solicitar totales o desglose vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - El campo `data` es null (totales) o array vacío (desglose).
