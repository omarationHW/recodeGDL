# Casos de Prueba para AdeudosLocGrl

## Caso 1: Consulta exitosa de adeudos por mercado
- **Entrada:** id_rec=2, num_mercado=5, axo=2024, mes=6
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:2, num_mercado:5, axo:2024, mes:6 } }
- **Esperado:** HTTP 200, success=true, data es array con campos requeridos, sin error.

## Caso 2: Consulta de todos los mercados de una recaudadora
- **Entrada:** id_rec=1, num_mercado=null, axo=2024, mes=5
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:1, num_mercado:null, axo:2024, mes:5 } }
- **Esperado:** HTTP 200, success=true, data es array con todos los mercados de la recaudadora 1.

## Caso 3: Error por recaudadora no seleccionada
- **Entrada:** id_rec=null, num_mercado=5, axo=2024, mes=6
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:null, num_mercado:5, axo:2024, mes:6 } }
- **Esperado:** HTTP 200, success=false, message indica que debe seleccionar recaudadora.

## Caso 4: Exportar Excel
- **Acción:** POST /api/execute { action: 'exportExcel', params: {...} }
- **Esperado:** HTTP 200, success=true, message indica que la exportación no está implementada.

## Caso 5: Consulta con parámetros fuera de rango
- **Entrada:** id_rec=1, num_mercado=999, axo=1900, mes=13
- **Acción:** POST /api/execute { action: 'getAdeudosLocalesGrl', params: { id_rec:1, num_mercado:999, axo:1900, mes:13 } }
- **Esperado:** HTTP 200, success=true, data vacío o error controlado.
