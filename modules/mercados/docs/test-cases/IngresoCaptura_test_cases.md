## Casos de Prueba: Ingreso Captura

### Caso 1: Consulta exitosa
- **Entrada:**
  - num_mercado: 34
  - fecha_pago: 2024-06-01
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 12345
- **Acción:** POST /api/execute con action=getIngresoCaptura
- **Resultado esperado:**
  - success: true
  - data: array con al menos un registro con campos fecha_pago, caja_pago, operacion_pago, pagos, importe

### Caso 2: Parámetro faltante
- **Entrada:**
  - Falta operacion_pago
- **Acción:** POST /api/execute con action=getIngresoCaptura
- **Resultado esperado:**
  - success: false
  - message: 'The operacion_pago field is required.'

### Caso 3: Sin resultados
- **Entrada:**
  - num_mercado: 99
  - fecha_pago: 2024-01-01
  - oficina_pago: 9
  - caja_pago: 'Z'
  - operacion_pago: 99999
- **Acción:** POST /api/execute con action=getIngresoCaptura
- **Resultado esperado:**
  - success: true
  - data: []

### Caso 4: Error de base de datos
- **Simulación:** Forzar error en la base de datos (por ejemplo, cambiar nombre de tabla temporalmente)
- **Resultado esperado:**
  - success: false
  - message: mensaje de error SQL
