# Casos de Prueba: polcon

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| TC01 | Consulta exitosa para un día | date_from: '2024-06-10', date_to: '2024-06-10' | Tabla con resultados agrupados por cuenta de aplicación |
| TC02 | Consulta exitosa para rango de fechas | date_from: '2024-06-01', date_to: '2024-06-15' | Tabla con resultados del rango |
| TC03 | Rango sin resultados | date_from: '2023-01-01', date_to: '2023-01-05' | Mensaje: No se encontraron resultados |
| TC04 | Falta campo obligatorio | date_from: '', date_to: '2024-06-10' | Mensaje de error: Parámetros de fecha requeridos |
| TC05 | Formato de fecha inválido | date_from: '2024-06-XX', date_to: '2024-06-10' | Mensaje de error de validación |
| TC06 | Consulta con datos grandes | date_from: '2024-01-01', date_to: '2024-06-30' | Tabla con muchos resultados, totales correctos |
