# Casos de Prueba: PadronLocales

## Caso 1: Consulta exitosa de padrón
- **Entrada:** recaudadora = 1
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { recaudadora: 1 } }
- **Esperado:** success=true, data es array con locales, cada uno con campo 'renta' calculado

## Caso 2: Exportación a Excel
- **Entrada:** recaudadora = 2, format = 'excel'
- **Acción:** POST /api/execute { action: 'exportPadronLocales', params: { recaudadora: 2, format: 'excel' } }
- **Esperado:** success=true, data.format='excel', data.data es array de locales

## Caso 3: Error por parámetro faltante
- **Entrada:** recaudadora = null
- **Acción:** POST /api/execute { action: 'getPadronLocales', params: { } }
- **Esperado:** success=false, message='Debe especificar la recaudadora'

## Caso 4: Validación de recaudadoras
- **Acción:** POST /api/execute { action: 'getRecaudadoras' }
- **Esperado:** success=true, data es array de recaudadoras

## Caso 5: Exportación a TXT
- **Entrada:** recaudadora = 1, format = 'txt'
- **Acción:** POST /api/execute { action: 'exportPadronLocales', params: { recaudadora: 1, format: 'txt' } }
- **Esperado:** success=true, data.format='txt', data.data es array de locales
