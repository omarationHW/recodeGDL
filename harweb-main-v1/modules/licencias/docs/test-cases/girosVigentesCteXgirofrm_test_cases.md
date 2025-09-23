# Casos de Prueba: Giros Vigentes Cte X Giro

## Caso 1: Consulta por año y clasificación
- **Entrada:** year=2024, vigente='V', clasificacion='A', order_by='cuantos'
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: { year: 2024, vigente: 'V', clasificacion: 'A', order_by: 'cuantos' } }
- **Esperado:** Respuesta success=true, data con lista de giros vigentes año 2024, solo clasificación A, agrupados y ordenados por concurrencias.

## Caso 2: Consulta por rango de fechas y cancelados
- **Entrada:** date_from='2023-01-01', date_to='2023-03-31', vigente='C', clasificacion='', order_by='descripcion'
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: { date_from: '2023-01-01', date_to: '2023-03-31', vigente: 'C', clasificacion: '', order_by: 'descripcion' } }
- **Esperado:** Respuesta success=true, data con lista de giros cancelados en ese rango, agrupados y ordenados por descripción.

## Caso 3: Consulta sin filtros de año ni fechas
- **Entrada:** vigente='V', clasificacion='', order_by='cuantos'
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: { vigente: 'V', clasificacion: '', order_by: 'cuantos' } }
- **Esperado:** Respuesta success=true, data con todos los giros vigentes agrupados y ordenados por concurrencias.

## Caso 4: Validación de error por falta de parámetros
- **Entrada:** action='getReporteGiros', params={}
- **Acción:** POST /api/execute { action: 'getReporteGiros', params: {} }
- **Esperado:** Respuesta success=true, data con todos los giros vigentes agrupados y ordenados por concurrencias (comportamiento por defecto).

## Caso 5: Impresión del reporte
- **Entrada:** year=2022, vigente='V', clasificacion='B', order_by='cuantos'
- **Acción:** POST /api/execute { action: 'printReporteGiros', params: { year: 2022, vigente: 'V', clasificacion: 'B', order_by: 'cuantos' } }
- **Esperado:** Respuesta success=true, data igual que en getReporteGiros, o bien descarga de PDF si está implementado.
