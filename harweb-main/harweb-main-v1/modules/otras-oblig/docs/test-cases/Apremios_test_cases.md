# Casos de Prueba: Apremios

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta de apremio existente | eRequest: get_apremios, params: {par_modulo:1, par_control:1} | Retorna datos del apremio y success=true |
| 2 | Consulta de periodos por control | eRequest: get_periodos_by_control, params: {id_control:1} | Retorna lista de periodos requeridos |
| 3 | Creación de apremio válido | eRequest: create_apremio, params: {...datos válidos...} | Retorna nuevo apremio creado, success=true |
| 4 | Actualización de apremio | eRequest: update_apremio, params: {id_control:3, ...} | Retorna apremio actualizado, success=true |
| 5 | Eliminación de apremio | eRequest: delete_apremio, params: {id_control:3} | success=true, apremio marcado como no vigente |
| 6 | Consulta de apremio inexistente | eRequest: get_apremios, params: {par_modulo:99, par_control:99} | Retorna data vacía, success=true |
| 7 | Creación con datos faltantes | eRequest: create_apremio, params: {falta campo requerido} | success=false, mensaje de error |
| 8 | SQL Injection en campo texto | eRequest: create_apremio, params: {observaciones: "'; DROP TABLE ta_15_apremios; --"} | success=false, sin efectos colaterales |
