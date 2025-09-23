## Casos de Prueba para Parcialidades Vencidas Convenios Diversos

### Caso 1: Consulta exitosa de convenios vigentes
- **Entrada:**
  - tipo: 1
  - subtipo: 2
  - fechahst: 2024-06-30
  - letras: ZC1
  - est: A
- **Acción:** POST /api/execute con action=getReport
- **Resultado esperado:**
  - status: success
  - data: lista de convenios vigentes con pagos y adeudos
  - message: 'Reporte generado correctamente'

### Caso 2: Exportación a Excel
- **Entrada:**
  - tipo: 3
  - subtipo: 5
  - fechahst: 2024-05-31
  - letras: ZO2
  - est: B
- **Acción:** POST /api/execute con action=exportExcel
- **Resultado esperado:**
  - status: success
  - data: archivo Excel (base64 o URL)
  - message: 'Archivo Excel generado correctamente'

### Caso 3: Parámetros inválidos
- **Entrada:**
  - tipo: null
  - subtipo: null
  - fechahst: ''
  - letras: ''
  - est: ''
- **Acción:** POST /api/execute con action=getReport
- **Resultado esperado:**
  - status: error
  - message: 'Error al obtener el reporte' o mensaje de validación

### Caso 4: Sin resultados
- **Entrada:**
  - tipo: 99
  - subtipo: 99
  - fechahst: 2024-01-01
  - letras: ZC1
  - est: A
- **Acción:** POST /api/execute con action=getReport
- **Resultado esperado:**
  - status: success
  - data: []
  - message: 'Reporte generado correctamente'

### Caso 5: Acción no soportada
- **Entrada:**
  - action: 'deleteReport'
  - params: {}
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - status: error
  - message: 'Acción no soportada: deleteReport'
