# Casos de Prueba: Padrón Global de Locales

## Caso 1: Consulta de Locales Vigentes
- **Entrada:** year=2024, month=6, status='A'
- **Acción:** POST /api/execute { action: 'getPadronGlobal', params: { year:2024, month:6, status:'A' } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: Array de locales con leyenda 'Local al Corriente de Pagos' o 'Local con Adeudo'
  - No errores

## Caso 2: Exportación a Excel
- **Entrada:** year=2024, month=6, status='T'
- **Acción:** POST /api/execute { action: 'exportPadronGlobalExcel', params: { year:2024, month:6, status:'T' } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - message: 'Exportación a Excel generada (simulada)'

## Caso 3: Reporte PDF
- **Entrada:** year=2024, month=6, status='B'
- **Acción:** POST /api/execute { action: 'getPadronGlobalReport', params: { year:2024, month:6, status:'B' } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - message: 'Reporte PDF generado (simulado)'

## Caso 4: Parámetros Inválidos
- **Entrada:** year='abc', month=13, status='Z'
- **Acción:** POST /api/execute { action: 'getPadronGlobal', params: { year:'abc', month:13, status:'Z' } }
- **Resultado esperado:**
  - HTTP 422
  - success: false
  - errors: Detalle de validación

## Caso 5: Acción No Soportada
- **Entrada:** action='unknownAction'
- **Acción:** POST /api/execute { action: 'unknownAction', params: {} }
- **Resultado esperado:**
  - HTTP 400
  - success: false
  - message: 'Acción no soportada.'
