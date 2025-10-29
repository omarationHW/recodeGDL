# Casos de Prueba para Cons_Cves_operacion

| # | Acción | Entrada | Resultado Esperado |
|---|--------|---------|--------------------|
| 1 | Listar claves por Control | {action:'list', data:{order:'ctrol_operacion'}} | Lista ordenada por ctrol_operacion |
| 2 | Listar claves por Descripción | {action:'list', data:{order:'descripcion'}} | Lista ordenada por descripcion |
| 3 | Alta clave válida | {action:'create', data:{cve_operacion:'Z', descripcion:'Prueba'}} | status:success, mensaje de éxito |
| 4 | Alta clave duplicada | {action:'create', data:{cve_operacion:'A', descripcion:'Cuota Normal'}} | status:error, mensaje de duplicidad |
| 5 | Editar descripción | {action:'update', data:{ctrol_operacion:2, descripcion:'Nuevo Desc'}} | status:success, mensaje de éxito |
| 6 | Eliminar clave sin pagos | {action:'delete', data:{ctrol_operacion:99}} | status:success, mensaje de éxito |
| 7 | Eliminar clave con pagos | {action:'delete', data:{ctrol_operacion:1}} | status:error, mensaje de error |
| 8 | Exportar Excel | {action:'export_excel'} | status:success, mensaje placeholder |
| 9 | Acción inválida | {action:'foo'} | status:error, mensaje de acción no soportada |
