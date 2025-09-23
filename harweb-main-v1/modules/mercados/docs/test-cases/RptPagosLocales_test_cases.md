## Casos de Prueba para RptPagosLocales

### 1. Consulta exitosa de pagos locales
- **Input:** fecha_desde=2024-06-01, fecha_hasta=2024-06-30, oficina=2
- **Acción:** POST /api/execute { action: 'getPagosLocalesReport', params: { ... } }
- **Resultado esperado:** success=true, data contiene registros, message=''

### 2. Validación de parámetros obligatorios
- **Input:** fecha_desde=2024-06-01, fecha_hasta=2024-06-30, oficina=''
- **Acción:** POST /api/execute { action: 'getPagosLocalesReport', params: { ... } }
- **Resultado esperado:** success=false, data=null, message contiene 'oficina'

### 3. Sin resultados para el filtro
- **Input:** fecha_desde=2024-01-01, fecha_hasta=2024-01-02, oficina=99 (no existe)
- **Acción:** POST /api/execute { action: 'getPagosLocalesReport', params: { ... } }
- **Resultado esperado:** success=true, data=[], message=''

### 4. Listado de recaudadoras
- **Input:** action: 'getRecaudadoras'
- **Acción:** POST /api/execute { action: 'getRecaudadoras' }
- **Resultado esperado:** success=true, data contiene lista de recaudadoras

### 5. Validación de fechas inválidas
- **Input:** fecha_desde='2024-06-31', fecha_hasta='2024-06-30', oficina=1
- **Acción:** POST /api/execute { action: 'getPagosLocalesReport', params: { ... } }
- **Resultado esperado:** success=false, data=null, message contiene 'fecha'