## Casos de Prueba para IngresoLib

### Caso 1: Consulta exitosa de ingresos
- **Entrada:** mes=3, anio=2024, mercado_id=1
- **Acción:** POST /api/execute { action: 'get_ingresos', params: { mes:3, anio:2024, mercado_id:1 } }
- **Resultado esperado:** Código 200, success=true, data contiene lista de ingresos.

### Caso 2: Validación de parámetros
- **Entrada:** mes=3, anio=2024, mercado_id=null
- **Acción:** POST /api/execute { action: 'get_ingresos', params: { mes:3, anio:2024, mercado_id:null } }
- **Resultado esperado:** Código 200, success=false, message indica error de validación.

### Caso 3: Consulta de totales por caja
- **Entrada:** mes=4, anio=2024, mercado_id=1
- **Acción:** POST /api/execute { action: 'get_cajas', params: { mes:4, anio:2024, mercado_id:1 } }
- **Resultado esperado:** Código 200, success=true, data contiene lista de totales por caja.

### Caso 4: Consulta de totales globales
- **Entrada:** mes=4, anio=2024, mercado_id=1
- **Acción:** POST /api/execute { action: 'get_totals', params: { mes:4, anio:2024, mercado_id:1 } }
- **Resultado esperado:** Código 200, success=true, data contiene total_pagos y total_importe.

### Caso 5: Consulta de mercados
- **Entrada:** ninguna
- **Acción:** POST /api/execute { action: 'get_mercados' }
- **Resultado esperado:** Código 200, success=true, data contiene lista de mercados tipo 'D'.
