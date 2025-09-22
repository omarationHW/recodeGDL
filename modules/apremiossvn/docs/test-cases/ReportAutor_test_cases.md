## Casos de Prueba para ReportAutor

### Caso 1: Consulta exitosa de reporte
- **Entrada:**
  - action: getReport
  - params: { rec: 1, fecha1: '2024-01-01', fecha2: '2024-01-31' }
- **Esperado:**
  - status: success
  - data: Array con al menos un registro
  - message: 'Reporte generado correctamente'

### Caso 2: Consulta sin resultados
- **Entrada:**
  - action: getReport
  - params: { rec: 1, fecha1: '1990-01-01', fecha2: '1990-01-02' }
- **Esperado:**
  - status: success
  - data: []
  - message: 'Reporte generado correctamente'

### Caso 3: Parámetros inválidos
- **Entrada:**
  - action: getReport
  - params: { rec: '', fecha1: '', fecha2: '' }
- **Esperado:**
  - status: error
  - message: 'El campo rec es obligatorio.'

### Caso 4: Cancelación de autorizado
- **Entrada:**
  - action: cancelAutorizados
  - params: { id_control: 12345, fecha_alta: '2024-01-15' }
- **Esperado:**
  - status: success
  - data: [{ updated: 1 }]
  - message: 'Autorizados cancelados'

### Caso 5: Actualización de porcentaje a 100%
- **Entrada:**
  - action: set100Porciento
  - params: { id_control: 12345 }
- **Esperado:**
  - status: success
  - data: [{ updated: 1 }]
  - message: 'Porcentaje actualizado a 100%'
