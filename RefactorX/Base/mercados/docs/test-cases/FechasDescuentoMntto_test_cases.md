## Casos de Prueba para FechasDescuentoMntto

### Caso 1: Consulta de todas las fechas
- **Acción:** POST /api/execute { "action": "getAll" }
- **Resultado esperado:** 12 registros, uno por cada mes, con fechas válidas.

### Caso 2: Consulta por mes
- **Acción:** POST /api/execute { "action": "getByMes", "data": { "mes": 5 } }
- **Resultado esperado:** Un registro para el mes 5 (mayo).

### Caso 3: Actualización exitosa
- **Acción:** POST /api/execute { "action": "update", "data": { "mes": 5, "fecha_descuento": "2024-05-15", "fecha_recargos": "2024-05-23", "id_usuario": 2 } }
- **Resultado esperado:** success=true, message='Actualización exitosa'.
- **Verificación:** Consultar nuevamente y ver que las fechas cambiaron.

### Caso 4: Validación de mes incorrecto
- **Acción:** POST /api/execute { "action": "update", "data": { "mes": 5, "fecha_descuento": "2024-06-01", "fecha_recargos": "2024-05-23", "id_usuario": 2 } }
- **Resultado esperado:** success=false, message='La fecha de descuento y recargos debe corresponder al mes seleccionado.'

### Caso 5: Usuario no autenticado
- **Acción:** POST /api/execute sin sesión válida
- **Resultado esperado:** HTTP 401 Unauthorized

### Caso 6: SQL Injection
- **Acción:** POST /api/execute { "action": "update", "data": { "mes": "5; DROP TABLE ta_11_fecha_desc;--", ... } }
- **Resultado esperado:** Error de validación, sin ejecución de SQL malicioso.
