## Casos de Prueba

### Caso 1: Reporte por Clasificación y Número de Exclusivo
- **Entrada:**
  - operation: get_reportes_exec
  - params: { order_by: 'clasificacion', group_by: 'no_exclusivo' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con columnas: clasificacion, no_exclusivo, propietario, etc.

### Caso 2: Estado de Cuenta por No. Exclusivo
- **Entrada:**
  - operation: get_estado_cuenta
  - params: { no_exclusivo: 1234 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene solo el exclusivo 1234

### Caso 3: Reporte de Adeudos
- **Entrada:**
  - operation: get_adeudos_exec
  - params: { }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene columnas: adeudo_axo, adeudo_mes, adeudo_anterior, adeudo_actual, adeudo_proyec

### Caso 4: Error por parámetro faltante
- **Entrada:**
  - operation: get_estado_cuenta
  - params: { }
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message contiene 'no_exclusivo es requerido'

### Caso 5: Operación no soportada
- **Entrada:**
  - operation: 'no_existente'
  - params: { }
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message contiene 'Operación no soportada'
