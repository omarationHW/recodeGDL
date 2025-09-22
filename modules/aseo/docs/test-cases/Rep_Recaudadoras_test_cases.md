## Casos de Prueba para Rep_Recaudadoras

### Caso 1: Consulta exitosa por nombre
- **Precondición:** Existen recaudadoras en la base de datos.
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport", "params": { "order": 2 } }`
- **Resultado esperado:**
  - HTTP 200, campo `success: true`, datos ordenados por nombre ascendente.

### Caso 2: Consulta exitosa por sector
- **Precondición:** Existen recaudadoras con diferentes sectores.
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport", "params": { "order": 4 } }`
- **Resultado esperado:**
  - HTTP 200, campo `success: true`, datos ordenados por sector ascendente y luego id_rec.

### Caso 3: Error de backend
- **Precondición:** El stored procedure no existe o hay error de conexión.
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport", "params": { "order": 1 } }`
- **Resultado esperado:**
  - HTTP 200, campo `success: false`, campo `message` contiene el error.

### Caso 4: Acción no soportada
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "accionInvalida" }`
- **Resultado esperado:**
  - HTTP 200, campo `success: false`, campo `message` = 'Acción no soportada'.

### Caso 5: Consulta sin parámetros (default)
- **Acción:**
  - Enviar POST a /api/execute con `{ "action": "getRecaudadorasReport" }`
- **Resultado esperado:**
  - HTTP 200, campo `success: true`, datos ordenados por id_rec ascendente.
