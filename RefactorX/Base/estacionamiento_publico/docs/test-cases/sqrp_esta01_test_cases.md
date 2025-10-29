# Casos de Prueba: sqrp_esta01

| # | Escenario | Datos de entrada | Acción | Resultado esperado |
|---|-----------|------------------|--------|-------------------|
| 1 | Consulta sin filtros | { axo_from: null, axo_to: null } | Consultar | Lista de todos los años/infracciones con totales |
| 2 | Consulta por rango válido | { axo_from: 2021, axo_to: 2022 } | Consultar | Solo años 2021 y 2022 aparecen |
| 3 | Consulta fuera de rango | { axo_from: 1999, axo_to: 1999 } | Consultar | Mensaje de 'No hay datos...' |
| 4 | Consulta con solo axo_from | { axo_from: 2022, axo_to: null } | Consultar | Solo años >= 2022 aparecen |
| 5 | Consulta con solo axo_to | { axo_from: null, axo_to: 2021 } | Consultar | Solo años <= 2021 aparecen |
| 6 | Error de base de datos | (Simular caída de DB) | Consultar | Mensaje de error técnico |
| 7 | Error de API (eRequest inválido) | { eRequest: 'no_existente' } | Consultar | Mensaje de 'Unknown eRequest' |
