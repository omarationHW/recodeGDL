## Casos de Prueba para Facturación

### Caso 1: Consulta exitosa de facturación
- **Entrada:**
  - modulo: 11
  - rec: 1
  - fol1: 100
  - fol2: 105
- **Acción:** POST /api/execute { action: 'facturacionList', params: { ... } }
- **Resultado esperado:**
  - Código 200
  - success: true
  - data: Array con folios 100 a 105, campos completos

### Caso 2: Validación de rango de folios
- **Entrada:**
  - modulo: 11
  - rec: 1
  - fol1: 200
  - fol2: 100
- **Acción:** POST /api/execute { action: 'facturacionList', params: { ... } }
- **Resultado esperado:**
  - Código 422
  - success: false
  - errors: contiene mensaje sobre rango inválido

### Caso 3: Consulta sin resultados
- **Entrada:**
  - modulo: 16
  - rec: 2
  - fol1: 9999
  - fol2: 10000
- **Acción:** POST /api/execute { action: 'facturacionList', params: { ... } }
- **Resultado esperado:**
  - Código 200
  - success: true
  - data: []

### Caso 4: Exportación a Excel (manual)
- **Precondición:** Hay resultados en pantalla
- **Acción:** Click en 'Exportar a Excel'
- **Resultado esperado:** Descarga de archivo Excel con los datos

### Caso 5: Consulta de recaudadoras
- **Acción:** POST /api/execute { action: 'getRecaudadoras' }
- **Resultado esperado:**
  - Código 200
  - success: true
  - data: Array de recaudadoras (id_rec, recaudadora)
