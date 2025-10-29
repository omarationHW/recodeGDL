# Casos de Prueba: RptAdeudosEnergia

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta exitosa de adeudos para año y oficina válidos | { "axo": 2023, "oficina": 1 } | Respuesta con success=true, data con lista de adeudos, totales correctos |
| 2 | Etiquetas correctas para año <= 2002 | { "axo": 2002, "oficina": 2 } | Etiquetas 'Cuota Bim.' y 'Bimestre de Adeudo', columna cuota visible |
| 3 | Etiquetas correctas para oficina 5 | { "axo": 2024, "oficina": 5 } | Columna cuota NO visible, etiquetas ajustadas |
| 4 | Error por falta de parámetros | { "axo": null, "oficina": 1 } | success=false, mensaje de error 'Parámetros axo y oficina requeridos' |
| 5 | Consulta de meses de adeudo por id_energia | { "eRequest": "RptAdeudosEnergia.getMeses", "params": { "id_energia": 123, "axo": 2023 } } | Lista de periodos e importes para ese id_energia y año |
| 6 | Consulta con año/oficina sin datos | { "axo": 1999, "oficina": 1 } | success=true, data vacía |
