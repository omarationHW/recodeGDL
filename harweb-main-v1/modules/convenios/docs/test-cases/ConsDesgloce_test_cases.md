# Casos de Prueba: Consulta Desgloce de Cuentas

## Caso 1: Consulta exitosa de desgloce
- **Entrada:** id_adeudo = 12345
- **Acción:** POST /api/execute con `{ eRequest: { action: 'getDesgloce', params: { id_adeudo: 12345 } } }`
- **Resultado esperado:** HTTP 200, eResponse.success = true, eResponse.data contiene arreglo de desgloce

## Caso 2: Consulta con ID de adeudo inexistente
- **Entrada:** id_adeudo = 999999
- **Acción:** POST /api/execute con `{ eRequest: { action: 'getDesgloce', params: { id_adeudo: 999999 } } }`
- **Resultado esperado:** HTTP 200, eResponse.success = true, eResponse.data = []

## Caso 3: Consulta de catálogo de cuentas de aplicación
- **Entrada:** year = 2024
- **Acción:** POST /api/execute con `{ eRequest: { action: 'getCuentasAplicacion', params: { year: 2024 } } }`
- **Resultado esperado:** HTTP 200, eResponse.success = true, eResponse.data contiene arreglo de cuentas

## Caso 4: Parámetro faltante
- **Entrada:** Sin id_adeudo
- **Acción:** POST /api/execute con `{ eRequest: { action: 'getDesgloce', params: { } } }`
- **Resultado esperado:** HTTP 200, eResponse.success = false, eResponse.message indica parámetro requerido

## Caso 5: Acción no soportada
- **Entrada:** action = 'noExiste'
- **Acción:** POST /api/execute con `{ eRequest: { action: 'noExiste', params: {} } }`
- **Resultado esperado:** HTTP 200, eResponse.success = false, eResponse.message indica acción no soportada
