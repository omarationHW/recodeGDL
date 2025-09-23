# Casos de Prueba: Consulta Individual de Requerimientos

## Caso 1: Consulta exitosa de requerimiento
- **Entrada:** id_local=1001, modulo=11, folio=12345
- **Acción:** POST /api/execute { action: 'getRequerimientos', params: { modulo: 11, folio: 12345, control_otr: 1001 } }
- **Resultado esperado:** success: true, data contiene los campos del requerimiento

## Caso 2: Consulta con folio inexistente
- **Entrada:** id_local=1001, modulo=11, folio=99999
- **Acción:** POST /api/execute { action: 'getRequerimientos', params: { modulo: 11, folio: 99999, control_otr: 1001 } }
- **Resultado esperado:** success: false, message: 'Requerimiento no encontrado'

## Caso 3: Validación de campos obligatorios
- **Entrada:** id_local=1001, modulo=11, folio=""
- **Acción:** POST /api/execute { action: 'getRequerimientos', params: { modulo: 11, folio: "", control_otr: 1001 } }
- **Resultado esperado:** HTTP 422, success: false, message: 'modulo, folio y control_otr requeridos'

## Caso 4: Consulta de periodos asociados
- **Entrada:** control_otr=1001
- **Acción:** POST /api/execute { action: 'getPeriodos', params: { control_otr: 1001 } }
- **Resultado esperado:** success: true, data contiene lista de periodos

## Caso 5: Consulta de local inexistente
- **Entrada:** id_local=9999
- **Acción:** POST /api/execute { action: 'getLocales', params: { id_local: 9999 } }
- **Resultado esperado:** success: false, message: 'Local no encontrado'
