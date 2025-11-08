# Casos de Prueba: Rep_a_Cobrar

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Generar reporte válido | { "mes": 5, "id_rec": 1 } | Tabla con años, mantenimiento, recargos y total |
| 2 | Obtener datos de recaudadora | { "id_rec": 1 } | Objeto con nomre, titulo, d_zona |
| 3 | Mes no enviado | { "id_rec": 1 } | Error: 'Parámetros requeridos: mes, id_rec' |
| 4 | id_rec inválido | { "mes": 3, "id_rec": 9999 } | Reporte vacío o error si no existe recaudadora |
| 5 | Acción no soportada | { "action": "foo" } | Error: 'Acción no soportada' |
| 6 | SQL error simulado | { "mes": "abc", "id_rec": 1 } | Error de SQL (tipo de dato) |
