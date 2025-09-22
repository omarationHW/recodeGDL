## Casos de Prueba para DetallePagosDiversos

### Caso 1: Consulta exitosa de pagos diversos
- **Entrada:** id_conv_resto = 12345
- **Acción:** POST /api/execute { action: 'getPagosDiversosDetalle', params: { id_conv_resto: 12345 } }
- **Resultado esperado:**
  - HTTP 200, success=true
  - data: array de pagos con campos completos
  - Totales correctos (sumatoria de pagos, recargos, intereses)

### Caso 2: Consulta de desgloce de cuentas
- **Entrada:** id_adeudo = 555
- **Acción:** POST /api/execute { action: 'getDesgloceCuentas', params: { id_adeudo: 555 } }
- **Resultado esperado:**
  - HTTP 200, success=true
  - data: array con cuentas_apl, descripcion, importe

### Caso 3: Consulta de totales
- **Entrada:** id_conv_resto = 12345
- **Acción:** POST /api/execute { action: 'getResumenTotales', params: { id_conv_resto: 12345 } }
- **Resultado esperado:**
  - HTTP 200, success=true
  - data: { total_pagado, total_recargos, total_intereses }

### Caso 4: Error por parámetro faltante
- **Entrada:** POST /api/execute { action: 'getPagosDiversosDetalle', params: {} }
- **Resultado esperado:**
  - HTTP 200, success=false
  - message: 'Parámetro id_conv_resto requerido'

### Caso 5: Error por convenio inexistente
- **Entrada:** id_conv_resto = 999999
- **Acción:** POST /api/execute { action: 'getPagosDiversosDetalle', params: { id_conv_resto: 999999 } }
- **Resultado esperado:**
  - HTTP 200, success=true
  - data: [] (vacío)

### Caso 6: Visualización en frontend
- **Acción:** El usuario ingresa un ID válido, ve la tabla, totales y puede abrir el modal de desgloce
- **Resultado esperado:**
  - La tabla muestra los pagos
  - Los totales se muestran correctamente
  - El modal de desgloce muestra las cuentas asociadas al pago seleccionado
