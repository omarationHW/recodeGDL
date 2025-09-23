## Casos de Prueba para RptPrenomina

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Reporte completo todas las zonas | fec1=2024-01-01, fec2=2024-01-31, recaud=1, recaud1=9 | Respuesta OK, filas con datos, totales correctos |
| 2 | Reporte recaudadora específica | fec1=2024-02-01, fec2=2024-02-28, recaud=3, recaud1=3 | Respuesta OK, solo datos de recaudadora 3, totales correctos |
| 3 | Parámetros insuficientes | fec1=2024-03-01, fec2=, recaud=1, recaud1=9 | Respuesta ERROR, mensaje de parámetros insuficientes |
| 4 | Periodo sin datos | fec1=2020-01-01, fec2=2020-01-31, recaud=1, recaud1=9 | Respuesta OK, filas vacías, totales en cero |
| 5 | Fechas invertidas | fec1=2024-04-01, fec2=2024-03-01, recaud=1, recaud1=9 | Respuesta OK, filas vacías, totales en cero |
| 6 | Recaudadora fuera de rango | fec1=2024-01-01, fec2=2024-01-31, recaud=99, recaud1=100 | Respuesta OK, filas vacías, totales en cero |
| 7 | Validación de tipos | fec1='texto', fec2='2024-01-31', recaud=1, recaud1=9 | Respuesta ERROR, mensaje de parámetros insuficientes o inválidos |
