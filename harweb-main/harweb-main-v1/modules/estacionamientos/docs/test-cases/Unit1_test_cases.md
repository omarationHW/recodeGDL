# Casos de Prueba para Reporte Unit1

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Generar reporte con datos válidos | fechora = '2024-06-01T10:00' | Tabla con registros correspondientes |
| TC02 | Generar reporte sin fecha/hora | fechora = '' | Mensaje de error: 'Missing parameter: fechora' |
| TC03 | Generar reporte para fecha/hora sin registros | fechora = '2023-01-01T00:00' | Mensaje: 'No se encontraron resultados para la fecha/hora seleccionada.' |
| TC04 | Envío de parámetro con formato incorrecto | fechora = 'texto-invalido' | Mensaje de error de formato o validación |
| TC05 | Prueba de inyección SQL en parámetro | fechora = "2024-06-01T10:00'; DROP TABLE ta_14_folios; --" | El sistema debe rechazar el parámetro y no ejecutar código malicioso |
