# Casos de Prueba: Estadísticas de Contratos

## Caso 1: Consulta exitosa
- **Entrada:** year=2023, fondo=16
- **Acción:** POST /api/execute { eRequest: { operation: 'getEstadisticasContratos', params: { year: 2023, fondo: 16 } } }
- **Esperado:** eResponse.success=true, eResponse.data contiene array de resultados, sin error.

## Caso 2: Exportación
- **Entrada:** year=2022, fondo=15
- **Acción:** POST /api/execute { eRequest: { operation: 'exportEstadisticasContratos', params: { year: 2022, fondo: 15 } } }
- **Esperado:** eResponse.success=true, eResponse.data contiene array o URL de archivo, sin error.

## Caso 3: Consulta sin resultados
- **Entrada:** year=1990, fondo=99
- **Acción:** POST /api/execute { eRequest: { operation: 'getEstadisticasContratos', params: { year: 1990, fondo: 99 } } }
- **Esperado:** eResponse.success=true, eResponse.data es array vacío, sin error.

## Caso 4: Error de parámetros
- **Entrada:** year=null, fondo=null
- **Acción:** POST /api/execute { eRequest: { operation: 'getEstadisticasContratos', params: { } } }
- **Esperado:** eResponse.success=false, eResponse.message indica error de parámetros.

## Caso 5: Operación no soportada
- **Entrada:** operation='unknownOp'
- **Acción:** POST /api/execute { eRequest: { operation: 'unknownOp' } }
- **Esperado:** eResponse.success=false, eResponse.message='Operación no soportada.'
