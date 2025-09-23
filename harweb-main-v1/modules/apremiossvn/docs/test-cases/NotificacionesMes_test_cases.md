# Casos de Prueba: Notificaciones por Mes

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| 1 | Consulta exitosa con datos válidos | axo_pract=2024, axo_emi=2024, fecha_desde=2024-01-01, fecha_hasta=2024-03-31 | Tabla con resultados agrupados y totales correctos |
| 2 | Exportación a Excel | Resultados cargados en pantalla | Descarga de archivo CSV con los mismos datos |
| 3 | Falta campo obligatorio | axo_pract vacío | Mensaje de error de validación |
| 4 | Rango de fechas inválido | fecha_desde > fecha_hasta | Mensaje de error de validación |
| 5 | Sin resultados | axo_pract=1990, axo_emi=1990, fechas fuera de rango | Tabla vacía, sin error |
| 6 | Inyección SQL (seguridad) | axo_pract="2024; DROP TABLE ta_15_apremios;--" | Error de validación, sin ejecución de SQL |
