## Casos de Prueba para RptAdeudoCorteManzana

### Caso 1: Consulta exitosa de reporte de adeudos vigentes
- **Entrada:**
  - subtipo: 1
  - fechadsd: 2024-01-01
  - fechahst: 2024-06-30
  - rep: 1
  - est: 'A'
- **Acción:** POST /api/execute con eRequest.operation = 'getAdeudoCorteManzana'
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene arreglo de registros con campos: manzana, lote, letracomp, nombre, calle, num_exterior, cantidad_total, pagos, recargos, saldo

### Caso 2: Exportación a Excel
- **Entrada:**
  - subtipo: 1
  - fechadsd: 2024-01-01
  - fechahst: 2024-06-30
  - rep: 1
  - est: 'A'
  - tipo: 'excel'
- **Acción:** POST /api/execute con eRequest.operation = 'exportAdeudoCorteManzana'
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data.url contiene la URL del archivo Excel generado

### Caso 3: Consulta con parámetros inválidos
- **Entrada:**
  - subtipo: null
  - fechadsd: ''
  - fechahst: ''
  - rep: 1
  - est: 'A'
- **Acción:** POST /api/execute con eRequest.operation = 'getAdeudoCorteManzana'
- **Resultado esperado:**
  - eResponse.success = false
  - eResponse.message indica error de validación o parámetros faltantes

### Caso 4: Consulta de saldos a favor
- **Entrada:**
  - subtipo: 2
  - fechadsd: 2024-01-01
  - fechahst: 2024-06-30
  - rep: 2
  - est: 'A'
- **Acción:** POST /api/execute con eRequest.operation = 'getAdeudoCorteManzana'
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene solo contratos con saldo negativo (a favor)

### Caso 5: Exportación a PDF
- **Entrada:**
  - subtipo: 1
  - fechadsd: 2024-01-01
  - fechahst: 2024-06-30
  - rep: 1
  - est: 'A'
  - tipo: 'pdf'
- **Acción:** POST /api/execute con eRequest.operation = 'exportAdeudoCorteManzana'
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data.url contiene la URL del archivo PDF generado
