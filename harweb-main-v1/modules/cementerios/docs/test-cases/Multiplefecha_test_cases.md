## Casos de Prueba para Consulta Multiplefecha

### Caso 1: Consulta exitosa de pagos y títulos
- **Entrada:** fecha=2024-06-01, rec=1, caja='A'
- **Acción:** POST /api/execute { action: 'getPagosByFecha', params: { fecha: '2024-06-01', rec: 1, caja: 'A' } }
- **Esperado:** Respuesta success=true, data contiene array de registros, cada uno con tipopag, fecing, recing, etc.

### Caso 2: Consulta detalle individual
- **Entrada:** control_rcm=12345
- **Acción:** POST /api/execute { action: 'getPagoDetalle', params: { control_rcm: 12345 } }
- **Esperado:** Respuesta success=true, data contiene un objeto con todos los campos del pago.

### Caso 3: Consulta sin resultados
- **Entrada:** fecha=2024-01-01, rec=1, caja='A'
- **Acción:** POST /api/execute { action: 'getPagosByFecha', params: { fecha: '2024-01-01', rec: 1, caja: 'A' } }
- **Esperado:** Respuesta success=true, data es array vacío.

### Caso 4: Validación de parámetros faltantes
- **Entrada:** rec=1, caja='A' (sin fecha)
- **Acción:** POST /api/execute { action: 'getPagosByFecha', params: { rec: 1, caja: 'A' } }
- **Esperado:** Respuesta success=false, message indica que falta el parámetro fecha.

### Caso 5: Error de base de datos
- **Simulación:** Forzar error en SP (por ejemplo, tipo de dato incorrecto)
- **Esperado:** Respuesta success=false, message contiene el error de la base de datos.
