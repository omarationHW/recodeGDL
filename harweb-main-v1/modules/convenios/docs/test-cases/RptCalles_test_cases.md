# Casos de Prueba para RptCalles

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|-------------------|
| 1 | Consulta exitosa con datos | axo = 2023 | POST /api/execute { action: 'RptCalles.getCallesByAxo', data: { axo: 2023 } } | eResponse.status = 'success', eResponse.data contiene registros, cada uno con campos colonia, calle, desc_calle, descripcion, descripcion_1, descripcion_2, estado ('VIGENTE'/'CANCELADA') |
| 2 | Consulta sin datos | axo = 2099 | POST /api/execute { action: 'RptCalles.getCallesByAxo', data: { axo: 2099 } } | eResponse.status = 'success', eResponse.data = [] |
| 3 | Error por parámetro faltante | axo = null | POST /api/execute { action: 'RptCalles.getCallesByAxo', data: { } } | eResponse.status = 'error', eResponse.message indica que el parámetro axo es requerido |
| 4 | Error por acción no soportada | action = 'RptCalles.unknownAction' | POST /api/execute { action: 'RptCalles.unknownAction', data: {} } | eResponse.status = 'error', eResponse.message indica acción no soportada |
| 5 | Validación de campo calculado | axo = 2023, con registros vigencia_obra='A' y 'C' | POST /api/execute { action: 'RptCalles.getCallesByAxo', data: { axo: 2023 } } | eResponse.data contiene campo estado con valores 'VIGENTE' para 'A' y 'CANCELADA' para otros |
