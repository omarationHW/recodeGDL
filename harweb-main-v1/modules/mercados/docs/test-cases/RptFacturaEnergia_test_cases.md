## Casos de Prueba: RptFacturaEnergia

### Caso 1: Consulta exitosa de reporte
- **Entrada:**
  - oficina: 1
  - mercado: 2
  - axo: 2024
  - periodo: 6
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getReport
- **Resultado esperado:**
  - success: true
  - data: arreglo con al menos un registro
  - Totales correctos en frontend

### Caso 2: Parámetros faltantes
- **Entrada:**
  - oficina: 1
  - mercado: (vacío)
  - axo: 2024
  - periodo: 6
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getReport
- **Resultado esperado:**
  - success: false
  - message: 'Parámetros requeridos: oficina, axo, periodo, mercado'

### Caso 3: Sin resultados
- **Entrada:**
  - oficina: 99
  - mercado: 99
  - axo: 2020
  - periodo: 1
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getReport
- **Resultado esperado:**
  - success: true
  - data: arreglo vacío
  - Frontend muestra mensaje 'No hay datos para los parámetros seleccionados.'

### Caso 4: Validación de etiquetas de periodo
- **Entrada:**
  - periodo: 3
  - axo: 2023
- **Acción:** POST /api/execute con eRequest=RptFacturaEnergia.getPeriodLabel
- **Resultado esperado:**
  - success: true
  - data: { short: 'MAR. 2023', long: 'MARZO DE 2023' }

### Caso 5: Error de base de datos
- **Simulación:** Forzar error en el stored procedure (ej: eliminar tabla temporalmente)
- **Acción:** POST /api/execute con parámetros válidos
- **Resultado esperado:**
  - success: false
  - message: error técnico de base de datos
