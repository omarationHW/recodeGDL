# Casos de Prueba: Gen_PgosBanorte

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|--------------------|
| 1 | Consulta de último periodo | - | GET /api/execute {operation: get_periodo} | Retorna fechas válidas de inicio y fin |
| 2 | Ejecución de remesa con registros | axo=2024, fec_ini=2024-06-11, fec_fin=2024-06-11 | POST /api/execute {operation: ejecutar_remesa} | Retorna remesa, obs, count > 0, success=true |
| 3 | Ejecución de remesa sin registros | axo=2024, fec_ini=2024-01-01, fec_fin=2024-01-01 | POST /api/execute {operation: ejecutar_remesa} | Retorna remesa, obs, count=0, success=true |
| 4 | Generar archivo con registros | remesa=remesa_id_valido | POST /api/execute {operation: generar_archivo} | Retorna filename, download_url, count>0, success=true |
| 5 | Generar archivo sin registros | remesa=remesa_id_sin_registros | POST /api/execute {operation: generar_archivo} | Retorna success=false, mensaje de no hay registros |
| 6 | Descargar archivo existente | filename=remesa_R20240611120000.txt | GET /api/remesas/download/filename | Descarga exitosa del archivo |
| 7 | Descargar archivo inexistente | filename=remesa_inexistente.txt | GET /api/remesas/download/filename | Retorna 404 archivo no encontrado |
| 8 | Validación de fechas inválidas | fec_ini > fec_fin | POST /api/execute {operation: ejecutar_remesa} | Retorna error de validación |
