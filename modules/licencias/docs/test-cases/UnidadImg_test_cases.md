# Casos de Prueba: UnidadImg

| Caso | Acción | Entrada | Resultado Esperado |
|------|--------|---------|--------------------|
| 1 | getUnidadImg | {"action":"getUnidadImg"} | Devuelve unidad actual o 'N' si no existe |
| 2 | setUnidadImg | {"action":"setUnidadImg", "params":{"unidad_img":"F"}} | Respuesta success=true, mensaje de éxito |
| 3 | setUnidadImg (actualizar) | {"action":"setUnidadImg", "params":{"unidad_img":"G"}} | Respuesta success=true, mensaje de éxito |
| 4 | rutaimagen | {"action":"rutaimagen", "params":{"id_tramite":500, "id_imagen":10}} | Devuelve ruta 'Ftrlic00000/10' |
| 5 | rutadir | {"action":"rutadir", "params":{"id_tramite":1500}} | Devuelve ruta 'Ftrlic01000' |
| 6 | setUnidadImg (inválido) | {"action":"setUnidadImg", "params":{}} | Respuesta success=false, mensaje de error |
| 7 | rutaimagen (sin id_tramite) | {"action":"rutaimagen", "params":{"id_imagen":1}} | Respuesta success=false, mensaje de error |
| 8 | rutadir (sin id_tramite) | {"action":"rutadir", "params":{}} | Respuesta success=false, mensaje de error |
