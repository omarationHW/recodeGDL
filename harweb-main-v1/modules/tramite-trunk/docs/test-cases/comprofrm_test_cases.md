## Casos de Prueba

### Caso 1: Consulta básica sin filtros
- **Input:**
  - fecha_desde: 2024-01-01
  - fecha_hasta: 2024-01-31
  - filtrar_movimiento: false
  - filtrar_departamento: false
  - capturista: ''
  - totales_dia: false
- **Esperado:**
  - Se listan todos los comprobantes del periodo.
  - El total de comprobantes coincide con la suma en la base de datos.

### Caso 2: Totales por día con movimiento y capturista
- **Input:**
  - fecha_desde: 2024-02-01
  - fecha_hasta: 2024-02-28
  - filtrar_movimiento: true
  - cvemov: 2
  - capturista: 'juanperez'
  - totales_dia: true
- **Esperado:**
  - Se listan los días con comprobantes capturados por 'juanperez' para el movimiento 2.
  - La columna 'cuenta_count' muestra el total por día.

### Caso 3: Filtro por departamento
- **Input:**
  - fecha_desde: 2024-03-01
  - fecha_hasta: 2024-03-31
  - filtrar_departamento: true
  - cvedepto: 5
- **Esperado:**
  - Solo se muestran comprobantes capturados por usuarios del departamento 5.

### Caso 4: Error por fechas inválidas
- **Input:**
  - fecha_desde: 2024-04-15
  - fecha_hasta: 2024-04-01
- **Esperado:**
  - El backend retorna error o lista vacía.
  - El frontend muestra mensaje de error o advertencia.

### Caso 5: Sin resultados
- **Input:**
  - fecha_desde: 2025-01-01
  - fecha_hasta: 2025-01-31
- **Esperado:**
  - La tabla de resultados está vacía.
  - Se muestra mensaje 'No hay resultados'.
