# Casos de Prueba: sqrp_publicos

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Reporte por Número | { eRequest: 'sqrp_publicos_report', params: { opc: 1 } } | Respuesta con status: success, datos ordenados por cve_numero |
| 2 | Reporte por Nombre | { eRequest: 'sqrp_publicos_report', params: { opc: 2 } } | Respuesta con status: success, datos ordenados por nombre |
| 3 | Reporte por Calle | { eRequest: 'sqrp_publicos_report', params: { opc: 3 } } | Respuesta con status: success, datos ordenados por calle |
| 4 | Reporte por Sector y Calle | { eRequest: 'sqrp_publicos_report', params: { opc: 4 } } | Respuesta con status: success, datos ordenados por cve_sector, calle |
| 5 | Reporte por Zona y Sub-Zona | { eRequest: 'sqrp_publicos_report', params: { opc: 5 } } | Respuesta con status: success, datos ordenados por zona, subzona |
| 6 | Sin resultados (estatus 'B') | { eRequest: 'sqrp_publicos_report', params: { opc: 1 } } con todos los registros estatus 'B' | status: success, data: [] |
| 7 | eRequest inválido | { eRequest: 'no_existe', params: {} } | status: error, message: 'Unknown eRequest' |
| 8 | Error de red | Desconectar backend | Error de red en frontend |
| 9 | Validación de campos calculados | { eRequest: 'sqrp_publicos_report', params: { opc: 1 } } | Los campos j1, jc1, h1, hc1, etc. reflejan correctamente la lógica del reporte |
