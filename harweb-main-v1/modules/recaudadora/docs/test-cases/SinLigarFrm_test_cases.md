# Casos de Prueba para SinLigarFrm

## Caso 1: Consulta exitosa de pagos sin ligar
- **Input:** fecha1 = '2024-05-01', fecha2 = '2024-05-31'
- **Acción:** POST /api/execute con operation 'getSinLigarPagos'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene lista de pagos, eResponse.error = null

## Caso 2: Consulta sin resultados
- **Input:** fecha1 = '2023-01-01', fecha2 = '2023-01-02'
- **Acción:** POST /api/execute con operation 'getSinLigarPagos'
- **Resultado esperado:** eResponse.success = true, eResponse.data = [], eResponse.error = null

## Caso 3: Error por parámetros faltantes
- **Input:** fecha1 = '', fecha2 = '2024-05-31'
- **Acción:** POST /api/execute con operation 'getSinLigarPagos'
- **Resultado esperado:** eResponse.success = false, eResponse.data = null, eResponse.error contiene mensaje de parámetros requeridos

## Caso 4: Error por operación no soportada
- **Input:** operation = 'unknownOperation'
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success = false, eResponse.error contiene 'Operación no soportada'

## Caso 5: Validación de formato de fecha
- **Input:** fecha1 = '2024-05-XX', fecha2 = '2024-05-31'
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success = false, eResponse.error contiene mensaje de error de formato de fecha
