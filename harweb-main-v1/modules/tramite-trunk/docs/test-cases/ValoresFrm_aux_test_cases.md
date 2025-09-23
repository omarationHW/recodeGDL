# Casos de Prueba para Valores Auxiliares

| # | Caso | Entrada | Acción | Resultado Esperado |
|---|------|---------|--------|--------------------|
| 1 | Crear registro válido | axoefec=2024, bimefec=1, valfiscal=10000, tasa=0.015 | Crear | Registro creado y visible en la tabla |
| 2 | Crear registro con campos obligatorios vacíos | axoefec=, bimefec=, valfiscal=, tasa= | Crear | Error de validación, no se crea registro |
| 3 | Editar registro existente | id=1, valfiscal=12000 | Editar y Actualizar | Registro actualizado en la tabla |
| 4 | Eliminar registro existente | id=1 | Eliminar | Registro eliminado de la tabla |
| 5 | Buscar registro por ID inexistente | id=9999 | Buscar | Respuesta vacía o error "no encontrado" |
| 6 | Crear registro con valores extremos | axoefec=2100, bimefec=12, valfiscal=99999999, tasa=1.0 | Crear | Registro creado correctamente |
| 7 | Intentar eliminar registro sin ID | id= | Eliminar | Error de validación |
| 8 | Crear registro con texto largo en observación | observacion='Texto muy largo...' | Crear | Registro creado y texto visible |
