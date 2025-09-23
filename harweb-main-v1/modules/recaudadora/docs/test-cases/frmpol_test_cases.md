# Casos de Prueba para frmpol (Reporte de Póliza por Recaudadora)

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Consulta exitosa de reporte | fecha: 2024-06-01, recaud: '003' | Tabla con resultados y totales mostrados correctamente |
| TC02 | Consulta sin recaudadora | fecha: 2024-06-01, recaud: '' | Mensaje de error: 'Parámetros requeridos: fecha, recaud' |
| TC03 | Consulta sin resultados | fecha: 2024-01-01, recaud: '001' | Mensaje: 'No se encontraron resultados para los criterios seleccionados.' |
| TC04 | Consulta con recaudadora inexistente | fecha: 2024-06-01, recaud: '999' | Mensaje: 'No se encontraron resultados para los criterios seleccionados.' |
| TC05 | Consulta con fecha inválida | fecha: 'invalid-date', recaud: '003' | Mensaje de error de validación |
| TC06 | Carga de catálogo de recaudadoras | - | Lista de recaudadoras mostrada en el select |
