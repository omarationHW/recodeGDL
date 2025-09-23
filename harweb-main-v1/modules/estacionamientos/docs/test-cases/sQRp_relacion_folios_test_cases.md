# Casos de Prueba: Relación de Folios

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta exitosa por fecha de folio | opcion: 1, fecha: 2024-06-01 | Tabla con folios de esa fecha |
| 2 | Consulta exitosa por fecha de alta | opcion: 2, fecha: 2024-05-15 | Tabla con folios dados de alta ese día |
| 3 | Consulta exitosa por fecha de baja (pago) | opcion: 3, fecha: 2024-04-10 | Tabla con folios pagados ese día |
| 4 | Consulta exitosa por fecha de baja (cancelación) | opcion: 4, fecha: 2024-03-20 | Tabla con folios cancelados ese día |
| 5 | Consulta sin resultados | opcion: 1, fecha: 1999-01-01 | Mensaje 'No hay datos para mostrar.' |
| 6 | Validación de campos requeridos | opcion: '', fecha: '' | Error de validación en frontend y backend |
| 7 | Validación de opción inválida | opcion: 99, fecha: 2024-06-01 | Error de validación en backend |
| 8 | Error de formato de fecha | opcion: 1, fecha: 'no-es-fecha' | Error de validación en backend |
| 9 | Prueba de rendimiento con muchos registros | opcion: 1, fecha: fecha con >1000 folios | Tabla con todos los registros, sin errores |
