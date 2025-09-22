## Casos de Prueba para Consulta de Transmisiones Patrimoniales

### Caso 1: Consulta por folio existente
- **Entrada:** folio = 12345
- **Acción:** Buscar
- **Esperado:** Se muestra una fila con los datos completos del folio 12345.

### Caso 2: Consulta por folio inexistente
- **Entrada:** folio = 999999
- **Acción:** Buscar
- **Esperado:** Se muestra mensaje de error 'No se encontraron resultados' o tabla vacía.

### Caso 3: Consulta por rango de fechas con resultados (detalle)
- **Entrada:** desde = '2024-01-01', hasta = '2024-01-31', tipo = 'folioxfolio'
- **Acción:** Buscar
- **Esperado:** Se muestran varias filas con detalle de transmisiones y el total de folios.

### Caso 4: Consulta por rango de fechas sin resultados
- **Entrada:** desde = '2050-01-01', hasta = '2050-01-31', tipo = 'folioxfolio'
- **Acción:** Buscar
- **Esperado:** Tabla vacía y total de folios = 0.

### Caso 5: Consulta de totales por día
- **Entrada:** desde = '2024-01-01', hasta = '2024-01-31', tipo = 'totalesxdia'
- **Acción:** Buscar
- **Esperado:** Se muestra tabla con fechas y totales, y total general.

### Caso 6: Validación de fechas
- **Entrada:** desde = '', hasta = ''
- **Acción:** Buscar
- **Esperado:** Mensaje de error 'Debe ingresar ambas fechas.'

### Caso 7: Validación de folio vacío
- **Entrada:** folio = ''
- **Acción:** Buscar
- **Esperado:** Mensaje de error 'Debe ingresar un folio válido.'
