## Casos de Prueba para GAdeudosGral

### Caso 1: Consulta de Adeudos Generales - Periodo Actual
- **Entrada:**
  - operation: GAdeudosGral.sp34_adeudototal
  - params: { par_tabla: 3, par_fecha: "2024-06" }
- **Acción:** POST /api/execute
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un registro

### Caso 2: Consulta de Adeudos Generales - Periodo Específico
- **Entrada:**
  - operation: GAdeudosGral.sp34_adeudototal
  - params: { par_tabla: 3, par_fecha: "2023-03" }
- **Acción:** POST /api/execute
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data contiene solo registros con adeudo

### Caso 3: Exportación a Excel
- **Entrada:**
  - operation: GAdeudosGral.exportExcel
  - params: { }
- **Acción:** POST /api/execute
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data.url contiene la URL de descarga

### Caso 4: Error por operación no soportada
- **Entrada:**
  - operation: GAdeudosGral.noExiste
  - params: { }
- **Acción:** POST /api/execute
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message contiene 'Operación no soportada'

### Caso 5: Error por parámetros faltantes
- **Entrada:**
  - operation: GAdeudosGral.sp34_adeudototal
  - params: { }
- **Acción:** POST /api/execute
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message indica error de parámetros
