# Casos de Prueba Gastos Cobrados

## Caso 1: Consulta exitosa de pagos de gastos de cobranza
- **Entrada:**
  - fecha_desde: 2024-01-01
  - fecha_hasta: 2024-01-31
  - id_rec: 1
  - tipo_consulta: 'ofna'
- **Acción:** Buscar
- **Esperado:**
  - status: success
  - data: array con al menos una fila
  - message: 'Pagos de gastos de cobranza obtenidos.'

## Caso 2: Consulta sin resultados
- **Entrada:**
  - fecha_desde: 2024-03-01
  - fecha_hasta: 2024-03-31
  - id_rec: 99 (no existe)
  - tipo_consulta: 'ofna'
- **Acción:** Buscar
- **Esperado:**
  - status: success
  - data: array vacío
  - message: 'Pagos de gastos de cobranza obtenidos.'

## Caso 3: Validación de parámetros obligatorios
- **Entrada:**
  - fecha_desde: ''
  - fecha_hasta: '2024-01-31'
  - id_rec: 1
- **Acción:** Buscar
- **Esperado:**
  - status: error
  - message: 'The fecha_desde field is required.'

## Caso 4: Exportación a Excel
- **Precondición:** Consulta previa con resultados
- **Acción:** Exportar Excel
- **Esperado:**
  - Se descarga un archivo CSV con los datos de la tabla

## Caso 5: Consulta por Oficina Apremios
- **Entrada:**
  - fecha_desde: 2024-02-01
  - fecha_hasta: 2024-02-29
  - id_rec: 2
  - tipo_consulta: 'apremios'
- **Acción:** Buscar
- **Esperado:**
  - status: success
  - data: array con resultados
  - message: 'Pagos de gastos de cobranza por recaudadora obtenidos.'
