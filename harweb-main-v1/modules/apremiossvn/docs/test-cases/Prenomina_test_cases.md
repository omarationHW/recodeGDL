# Casos de Prueba Prenómina

## Caso 1: Reporte para todas las recaudadoras
- **Entrada**: fecha_desde=2024-06-01, fecha_hasta=2024-06-30, recaudadora_tipo='todas'
- **Acción**: POST /api/execute { action: 'getPrenominaReport', params: {...} }
- **Esperado**: Respuesta success=true, data es array con filas de ejecutores, sin error.

## Caso 2: Reporte para recaudadora específica
- **Entrada**: fecha_desde=2024-05-01, fecha_hasta=2024-05-31, recaudadora_tipo='determinada', recaudadora=3
- **Acción**: POST /api/execute { action: 'getPrenominaReport', params: {...} }
- **Esperado**: Respuesta success=true, data solo contiene ejecutores de recaudadora 3.

## Caso 3: Validación de fechas vacías
- **Entrada**: fecha_desde='', fecha_hasta='', recaudadora_tipo='todas'
- **Acción**: POST /api/execute { action: 'getPrenominaReport', params: {...} }
- **Esperado**: Respuesta success=false, message indica error de validación.

## Caso 4: Catálogo de recaudadoras
- **Entrada**: action: 'getRecaudadoras'
- **Acción**: POST /api/execute { action: 'getRecaudadoras' }
- **Esperado**: Respuesta success=true, data es array de recaudadoras.

## Caso 5: Fechas fuera de rango (sin datos)
- **Entrada**: fecha_desde=2000-01-01, fecha_hasta=2000-01-31, recaudadora_tipo='todas'
- **Acción**: POST /api/execute { action: 'getPrenominaReport', params: {...} }
- **Esperado**: Respuesta success=true, data es array vacío.
