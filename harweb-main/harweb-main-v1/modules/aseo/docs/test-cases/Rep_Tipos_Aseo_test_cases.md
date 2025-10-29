# Casos de Prueba: Rep_Tipos_Aseo

## Caso 1: Consulta por Control
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 1 } }
- **Resultado esperado:** HTTP 200, success: true, data: array ordenada por ctrol_aseo ascendente.

## Caso 2: Consulta por Tipo
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 2 } }
- **Resultado esperado:** HTTP 200, success: true, data: array ordenada por tipo_aseo ascendente.

## Caso 3: Consulta por Descripción
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 3 } }
- **Resultado esperado:** HTTP 200, success: true, data: array ordenada por descripcion ascendente.

## Caso 4: Parámetro inválido
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 99 } }
- **Resultado esperado:** HTTP 200, success: false, message: 'Acción no soportada' o error de parámetro.

## Caso 5: Sin datos
- **Input:** POST /api/execute { action: 'getTiposAseoReport', params: { order: 1 } } (con tabla vacía)
- **Resultado esperado:** HTTP 200, success: true, data: []

## Caso 6: Seguridad
- **Input:** POST /api/execute sin autenticación
- **Resultado esperado:** HTTP 401 Unauthorized
