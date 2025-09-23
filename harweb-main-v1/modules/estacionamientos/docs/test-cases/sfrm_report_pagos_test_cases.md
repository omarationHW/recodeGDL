## Casos de Prueba para Reporte de Pagos

### Caso 1: Reporte de folios pagados (recaudadora específica)
- **Entrada:**
  - action: report_folios_pagados
  - params: { reca: 1, fechora: "2024-06-15" }
- **Esperado:**
  - Respuesta success=true
  - data: array con registros de folios pagados
  - message vacío

### Caso 2: Reporte de folios elaborados por usuario
- **Entrada:**
  - action: report_folios_elaborados_usuario
  - params: { fechora: "2024-06-15", vigila: 1 }
- **Esperado:**
  - Respuesta success=true
  - data: array con registros de folios elaborados por el usuario 1
  - message vacío

### Caso 3: Reporte de folios de adeudo por inspector
- **Entrada:**
  - action: report_folios_adeudo_por_inspector
  - params: { fechora: "2024-06-15" }
- **Esperado:**
  - Respuesta success=true
  - data: array con conteo de folios por inspector
  - message vacío

### Caso 4: Acción no soportada
- **Entrada:**
  - action: "accion_inexistente"
  - params: {}
- **Esperado:**
  - Respuesta success=false
  - data: null
  - message: "Acción no soportada"

### Caso 5: Parámetros inválidos
- **Entrada:**
  - action: report_folios_pagados
  - params: { reca: null, fechora: "" }
- **Esperado:**
  - Respuesta success=false
  - data: null
  - message: error de base de datos o validación

### Caso 6: Sin resultados
- **Entrada:**
  - action: report_folios_pagados
  - params: { reca: 99, fechora: "2099-01-01" }
- **Esperado:**
  - Respuesta success=true
  - data: array vacío
  - message vacío
