## Casos de Prueba para Padrón con Adeudos

### Caso 1: Consulta de padrón con adeudos vigentes
- **Entrada:**
  - action: getPadronConAdeudos
  - params: { par_tabla: 3, par_vigencia: 'TODOS' }
- **Resultado esperado:**
  - success: true
  - data: Array de concesiones con adeudos
  - message: ''

### Caso 2: Consulta de detalle de adeudos de concesión
- **Entrada:**
  - action: getPadronAdeudosDetalle
  - params: { par_tab: 3, par_control: 123, par_rep: 'V', par_fecha: '2024-06' }
- **Resultado esperado:**
  - success: true
  - data: Array de conceptos y montos
  - message: ''

### Caso 3: Consulta de vigencias disponibles
- **Entrada:**
  - action: getVigenciasConcesion
  - params: { par_tab: 3 }
- **Resultado esperado:**
  - success: true
  - data: Array de vigencias (ej: [{descripcion: 'VIGENTE'}, ...])
  - message: ''

### Caso 4: Consulta de etiquetas de tabla
- **Entrada:**
  - action: getEtiquetasTabla
  - params: { par_tab: 3 }
- **Resultado esperado:**
  - success: true
  - data: Array con objeto de etiquetas
  - message: ''

### Caso 5: Consulta de nombre de tabla
- **Entrada:**
  - action: getNombreTabla
  - params: { par_tab: 3 }
- **Resultado esperado:**
  - success: true
  - data: Array con objeto {nombre: 'Rastro'}
  - message: ''

### Caso 6: Error por acción no soportada
- **Entrada:**
  - action: 'accionInexistente'
  - params: {}
- **Resultado esperado:**
  - success: false
  - data: null
  - message: 'Acción no soportada'
