## Casos de Prueba para repavance

### Caso 1: Reporte Municipal Enero 2024
- **Entrada:**
  - mes: 0
  - anio: 2024
  - recaudadora_id: 1
  - tipo: 'M'
- **Acción:** POST /api/execute con eRequest.action = 'repavance_generate_report'
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.report.detalle es un array con al menos un elemento
  - Los campos cuantos1, total1, etc. son numéricos

### Caso 2: Reporte Federal Febrero 2024 (Año Bisiesto)
- **Entrada:**
  - mes: 1
  - anio: 2024
  - recaudadora_id: 2
  - tipo: 'F'
- **Acción:** POST /api/execute con eRequest.action = 'repavance_generate_report'
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.report.detalle es un array
  - Las fechas mínimo y máximo consideran 29 días para febrero

### Caso 3: Parámetros insuficientes
- **Entrada:**
  - mes: 0
  - anio: null
  - recaudadora_id: 1
  - tipo: 'M'
- **Acción:** POST /api/execute con eRequest.action = 'repavance_generate_report'
- **Esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'Parámetros insuficientes'

### Caso 4: Validación de totales
- **Entrada:**
  - mes: 2
  - anio: 2023
  - recaudadora_id: 1
  - tipo: 'M'
- **Acción:** POST /api/execute
- **Esperado:**
  - La suma de los campos en el frontend coincide con los totales calculados en el backend

### Caso 5: Reporte sin resultados
- **Entrada:**
  - mes: 5
  - anio: 2022
  - recaudadora_id: 99 (no existe)
  - tipo: 'M'
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.report.detalle es un array vacío o todos los campos en cero
