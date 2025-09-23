# Casos de Prueba UNIT9

| Caso | Acción | Parámetros | Resultado Esperado |
|------|--------|------------|--------------------|
| 1 | Navegar a primera página | { eRequest: 'UNIT9_PREVIEW_NAVIGATE', params: { action: 'first' } } | Respuesta con page=1 y contenido de primera página |
| 2 | Navegar a siguiente página | { eRequest: 'UNIT9_PREVIEW_NAVIGATE', params: { action: 'next' } } | Respuesta con page=3 y contenido de página siguiente |
| 3 | Cargar desde archivo | { eRequest: 'UNIT9_PREVIEW_LOAD', params: { file_path: '/tmp/reporte1.rep' } } | Respuesta con file='/tmp/reporte1.rep' y contenido simulado |
| 4 | Guardar a archivo | { eRequest: 'UNIT9_PREVIEW_SAVE', params: { file_path: '/tmp/reporte2.rep' } } | Respuesta con saved=true y file='/tmp/reporte2.rep' |
| 5 | Imprimir | { eRequest: 'UNIT9_PREVIEW_PRINT' } | Respuesta con printed=true |
| 6 | Vista de una página | { eRequest: 'UNIT9_PREVIEW_ONEPAGE' } | Respuesta con view='onepage' |
| 7 | Zoom 100% | { eRequest: 'UNIT9_PREVIEW_ZOOM', params: { zoom: 100 } } | Respuesta con zoom=100 |
| 8 | Ancho de página | { eRequest: 'UNIT9_PREVIEW_PAGEWIDTH' } | Respuesta con view='pagewidth' |
| 9 | Cerrar modal | { eRequest: 'UNIT9_MODAL_OK' } | Respuesta con modalResult='ok' |
