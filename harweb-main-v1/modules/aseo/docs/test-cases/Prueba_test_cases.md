# Casos de Prueba para Formulario Prueba

## Caso 1: Consulta exitosa de contratos
- **Entrada:** parCtrol = 9
- **Acción:** POST /api/execute { action: 'prueba_query', params: { parCtrol: 9 } }
- **Resultado esperado:** status: 'success', data: array con contratos ctrol_aseo=9 y num_contrato>=2120

## Caso 2: Consulta de licencia de giro existente
- **Entrada:** p_tipo = 'O', p_numero = 2125 (asumiendo existe relación)
- **Acción:** POST /api/execute { action: 'licencia_giro_f1', params: { p_tipo: 'O', p_numero: 2125 } }
- **Resultado esperado:** status: 'success', data: [{ status_licencias: 0, concepto_licencias: 'Licencia relacionada encontrada' }]

## Caso 3: Consulta de licencia de giro inexistente
- **Entrada:** p_tipo = 'X', p_numero = 9999 (no existe relación)
- **Acción:** POST /api/execute { action: 'licencia_giro_f1', params: { p_tipo: 'X', p_numero: 9999 } }
- **Resultado esperado:** status: 'success', data: [{ status_licencias: 1, concepto_licencias: 'No existe relación de licencia para este contrato' }]

## Caso 4: Error por falta de parámetro
- **Entrada:** parCtrol = null
- **Acción:** POST /api/execute { action: 'prueba_query', params: { } }
- **Resultado esperado:** status: 'error', message: 'Falta parámetro parCtrol'

## Caso 5: Acción no soportada
- **Entrada:** action = 'no_existente'
- **Acción:** POST /api/execute { action: 'no_existente', params: { } }
- **Resultado esperado:** status: 'error', message: 'Acción no soportada: no_existente'
