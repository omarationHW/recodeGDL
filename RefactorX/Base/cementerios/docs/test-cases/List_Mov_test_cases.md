## Casos de Prueba para List_Mov

### Caso 1: Consulta exitosa de movimientos
- **Entrada:** fecha1=2024-01-01, fecha2=2024-01-31, reca=2
- **Acción:** POST /api/execute { action: 'list_movements', params: { ... } }
- **Resultado esperado:** success=true, data=[...]

### Caso 2: Consulta sin resultados
- **Entrada:** fecha1=2023-01-01, fecha2=2023-01-02, reca=9 (sin datos en ese rango)
- **Acción:** POST /api/execute { action: 'list_movements', params: { ... } }
- **Resultado esperado:** success=true, data=[]

### Caso 3: Validación de campos obligatorios
- **Entrada:** fecha1='', fecha2='2024-01-31', reca=2
- **Acción:** POST /api/execute { action: 'list_movements', params: { ... } }
- **Resultado esperado:** success=false, errors contiene 'fecha1' requerido

### Caso 4: Generación de reporte
- **Entrada:** fecha1=2024-01-01, fecha2=2024-01-31, reca=2
- **Acción:** POST /api/execute { action: 'print_report', params: { ... } }
- **Resultado esperado:** success=true, report_data=[...], message='Reporte generado (simulado)'

### Caso 5: Acceso no autenticado
- **Entrada:** Sin token de autenticación
- **Acción:** POST /api/execute
- **Resultado esperado:** HTTP 401 Unauthorized
