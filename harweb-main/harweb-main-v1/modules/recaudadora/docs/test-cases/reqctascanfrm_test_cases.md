## Casos de Prueba para reqctascanfrm

### Caso 1: Consulta exitosa de cuentas canceladas
- **Entrada:**
  - recaud: 2
  - fini: '2024-02-01'
  - ffin: '2024-02-28'
- **Acción:**
  - Enviar petición a /api/execute con eRequest 'reqctascanfrm.get_cancelled_accounts' y los parámetros anteriores.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un registro con campos cvecuenta, recaud, cuenta, cuenta_utm.

### Caso 2: Validación de recaudadora no seleccionada
- **Entrada:**
  - recaud: ''
  - fini: '2024-01-01'
  - ffin: '2024-01-31'
- **Acción:**
  - Enviar petición a /api/execute sin recaudadora.
- **Resultado esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'Parámetros requeridos'

### Caso 3: Consulta de folios para cuenta sin folios vigentes
- **Entrada:**
  - cvecuenta: 99999 (sin folios vigentes)
- **Acción:**
  - Enviar petición a /api/execute con eRequest 'reqctascanfrm.get_folios_by_cvecuenta'.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío

### Caso 4: Consulta de folios para cuenta con folios vigentes
- **Entrada:**
  - cvecuenta: 12345 (con folios vigentes)
- **Acción:**
  - Enviar petición a /api/execute con eRequest 'reqctascanfrm.get_folios_by_cvecuenta'.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un objeto con campo folioreq

### Caso 5: Fechas fuera de rango
- **Entrada:**
  - recaud: 1
  - fini: '1900-01-01'
  - ffin: '1900-01-31'
- **Acción:**
  - Enviar petición a /api/execute con fechas donde no existen datos.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío
