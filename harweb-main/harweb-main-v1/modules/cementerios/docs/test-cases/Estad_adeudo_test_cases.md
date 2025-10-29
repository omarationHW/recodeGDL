## Casos de Prueba

### Caso 1: Consulta de Resumen de Adeudos
- **Entrada:**
  ```json
  { "eRequest": { "action": "getResumen" } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con campos cementerio, uap, cuenta

### Caso 2: Consulta de Listado de Adeudos > 2 años
- **Entrada:**
  ```json
  { "eRequest": { "action": "getListado", "params": { "axop": 3 } } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con los campos detallados (control_rcm, cementerio, ...)
  - Todos los registros tienen axo_pagado <= 3

### Caso 3: Error por parámetro axop faltante
- **Entrada:**
  ```json
  { "eRequest": { "action": "getListado" } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message contiene 'axop requerido'

### Caso 4: Acción no soportada
- **Entrada:**
  ```json
  { "eRequest": { "action": "noExiste" } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message contiene 'Acción no soportada'

### Caso 5: Consulta de Listado sin resultados
- **Entrada:**
  ```json
  { "eRequest": { "action": "getListado", "params": { "axop": 1 } } }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array vacío si no hay registros con axo_pagado <= 1
