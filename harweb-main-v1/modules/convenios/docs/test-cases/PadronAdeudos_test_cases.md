# Casos de Prueba: Padrón de Adeudos

## Caso 1: Consulta exitosa de padrón
- **Entrada:** rec_id = 1
- **Acción:** POST /api/execute { action: 'getPadronAdeudos', params: { rec_id: 1 } }
- **Resultado esperado:** Código 200, success: true, data: [ ... ] (lista no vacía)

## Caso 2: Exportación a Excel
- **Entrada:** rec_id = 2
- **Acción:** POST /api/execute { action: 'exportPadronAdeudosExcel', params: { rec_id: 2 } }
- **Resultado esperado:** Código 200, success: true, file: base64, filename: 'padron_adeudos.xlsx'

## Caso 3: Parámetro inválido
- **Entrada:** rec_id = ''
- **Acción:** POST /api/execute { action: 'getPadronAdeudos', params: { rec_id: '' } }
- **Resultado esperado:** Código 422, success: false, message: 'Parámetros inválidos'

## Caso 4: Recaudadora sin convenios vigentes
- **Entrada:** rec_id = 99 (no existe)
- **Acción:** POST /api/execute { action: 'getPadronAdeudos', params: { rec_id: 99 } }
- **Resultado esperado:** Código 200, success: true, data: []

## Caso 5: Error de red
- **Simulación:** El backend no responde
- **Acción:** POST /api/execute
- **Resultado esperado:** El frontend muestra 'Error de red al consultar padrón'
