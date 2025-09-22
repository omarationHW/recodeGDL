## Casos de Prueba: PagosLocGrl

### 1. Consulta exitosa de pagos
- **Entrada:** recaudadora_id=2, mercado_id=5, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'getPagosLocGrl', params: {...} }
- **Esperado:** Respuesta success=true, data es array con pagos, sin error

### 2. Exportación a Excel
- **Entrada:** recaudadora_id=2, mercado_id=5, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'exportPagosLocGrlExcel', params: {...} }
- **Esperado:** Respuesta success=true, data.url contiene URL de descarga

### 3. Validación de campos obligatorios
- **Entrada:** recaudadora_id=null, mercado_id=null, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'getPagosLocGrl', params: {...} }
- **Esperado:** Respuesta success=false, message indica error de parámetros

### 4. Consulta sin resultados
- **Entrada:** recaudadora_id=99, mercado_id=99, fecha_desde=2024-01-01, fecha_hasta=2024-03-31
- **Acción:** POST /api/execute { action: 'getPagosLocGrl', params: {...} }
- **Esperado:** Respuesta success=true, data es array vacío

### 5. Error de base de datos
- **Simulación:** Forzar error en SP (ej: pasar string en vez de int)
- **Esperado:** Respuesta success=false, message contiene mensaje de error SQL
