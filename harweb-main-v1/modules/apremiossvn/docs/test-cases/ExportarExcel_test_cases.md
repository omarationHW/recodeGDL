## Casos de Prueba ExportarExcel

### Caso 1: Consulta exitosa de folios pagos
- **Entrada:** prec=1, pmod=11, pfold=100, pfolh=200, pfemi=2024-06-01, pfpagd=2024-06-01, pfpagh=2024-06-30
- **Acción:** POST /api/execute con action=getFoliosPagos
- **Resultado esperado:** status=success, data contiene lista de folios, message='Folios pagos consultados'

### Caso 2: Exportación a Excel
- **Precondición:** Se realizó una consulta exitosa y hay datos en la tabla
- **Acción:** Click en 'Exportar Excel'
- **Resultado esperado:** Se descarga un archivo Excel con los datos mostrados

### Caso 3: Validación de parámetros obligatorios
- **Entrada:** prec=1, pmod=11, pfold=null, pfolh=200, pfemi=2024-06-01, pfpagd=2024-06-01, pfpagh=2024-06-30
- **Acción:** POST /api/execute con action=getFoliosPagos
- **Resultado esperado:** status=error, message indica que 'pfold' es obligatorio

### Caso 4: Consulta sin resultados
- **Entrada:** prec=1, pmod=11, pfold=99999, pfolh=99999, pfemi=2024-06-01, pfpagd=2024-06-01, pfpagh=2024-06-30
- **Acción:** POST /api/execute con action=getFoliosPagos
- **Resultado esperado:** status=success, data=[], message='Folios pagos consultados'

### Caso 5: Consulta de recaudadoras
- **Acción:** POST /api/execute con action=getRecaudadoras
- **Resultado esperado:** status=success, data contiene lista de recaudadoras
