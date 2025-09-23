## Casos de Prueba

### Caso 1: Visualización de reporte para tipo de aseo válido
- **Entrada:**
  - procedure: sp_get_cn
  - parameters: { ctrol_a: 1 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene registros numéricos y suma de importes

### Caso 2: Cambio de tipo de aseo
- **Acción:**
  - Seleccionar tipo de aseo ctrol_aseo=2 en el frontend
- **Esperado:**
  - Todos los datos de las tablas cambian y corresponden al nuevo tipo

### Caso 3: Error por SP inexistente
- **Entrada:**
  - procedure: sp_inexistente
  - parameters: {}
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene texto 'does not exist' o similar

### Caso 4: Sin datos para tipo de aseo
- **Entrada:**
  - procedure: sp_get_cn
  - parameters: { ctrol_a: 9999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data = [ { registros: 0, importe: 0 } ]

### Caso 5: Seguridad (no autenticado)
- **Acción:**
  - Llamar /api/execute sin token (si aplica autenticación)
- **Esperado:**
  - HTTP 401 Unauthorized o mensaje de error de autenticación
