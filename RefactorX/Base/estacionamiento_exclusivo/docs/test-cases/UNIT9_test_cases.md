## Casos de Prueba UNIT9 Preview

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|--------------------|
| 1 | Cargar vista previa estándar | eRequest: UNIT9_REPORT_PREVIEW | POST /api/execute | Devuelve 3 páginas de ejemplo |
| 2 | Navegar entre páginas | - | Click en botones de navegación | Cambia la página mostrada |
| 3 | Zoom a 100% | - | Click en botón 'Zoom 100%' | Ajusta el tamaño de la preview |
| 4 | Guardar reporte | eRequest: UNIT9_REPORT_SAVE, params: {filename, report_data} | POST /api/execute | Mensaje de éxito y registro en unit9_reports |
| 5 | Cargar reporte guardado | eRequest: UNIT9_REPORT_LOAD, params: {filename} | POST /api/execute | Devuelve páginas guardadas |
| 6 | Cargar reporte inexistente | eRequest: UNIT9_REPORT_LOAD, params: {filename: 'noexiste.json'} | POST /api/execute | Mensaje de error 'Archivo no encontrado' |
| 7 | Imprimir reporte | eRequest: UNIT9_REPORT_PRINT | POST /api/execute | Mensaje 'Impresión enviada correctamente' |
| 8 | Cerrar preview | - | Click en botón 'Cerrar' | Redirige a página principal |
