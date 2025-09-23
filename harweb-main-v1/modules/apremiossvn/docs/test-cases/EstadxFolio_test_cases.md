## Casos de Prueba para EstadxFolio

### 1. Consulta exitosa de estadísticas
- **Entrada:**
  - modulo: 11
  - rec: 1
  - fol1: 1000
  - fol2: 1100
- **Acción:** POST /api/execute con eRequest.action = 'estadxfolio.getStats'
- **Resultado esperado:**
  - Código 200
  - eResponse.status = 'ok'
  - eResponse.data es un array con al menos una fila con campos: vigencia, clave_practicado, cuantos, gastos_pago, gastos_gasto, adeudo, recargos, vigencia_str, pract_str

### 2. Exportar a Excel
- **Entrada:**
  - Igual a la consulta exitosa
- **Acción:** POST /api/execute con eRequest.action = 'estadxfolio.exportExcel'
- **Resultado esperado:**
  - Código 200
  - eResponse.status = 'ok'
  - eResponse.data igual a la consulta
  - eResponse.excel_url es null (demo) o una URL de descarga

### 3. Validación de rango de folios
- **Entrada:**
  - modulo: 11
  - rec: 1
  - fol1: 2000
  - fol2: 1990
- **Acción:** POST /api/execute con eRequest.action = 'estadxfolio.getStats'
- **Resultado esperado:**
  - Código 200
  - eResponse.status = 'error'
  - eResponse.errors contiene mensaje sobre el rango de folios

### 4. Catálogo de recaudadoras
- **Acción:** POST /api/execute con eRequest.action = 'estadxfolio.getRecaudadoras'
- **Resultado esperado:**
  - Código 200
  - eResponse.status = 'ok'
  - eResponse.data es un array de objetos con id_rec y recaudadora

### 5. Acción desconocida
- **Acción:** POST /api/execute con eRequest.action = 'unknown.action'
- **Resultado esperado:**
  - Código 400
  - eResponse.status = 'error'
  - eResponse.message = 'Unknown action'
