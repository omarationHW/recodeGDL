# Casos de Prueba: RprtCATAL_EJE

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta ejecutores activos recaudadora 1 | { "id_rec": 1, "vigencia": "A" } | Tabla con ejecutores activos de recaudadora 1, total correcto |
| 2 | Consulta todos los ejecutores recaudadora 2 | { "id_rec": 2, "vigencia": "" } | Tabla con todos los ejecutores de recaudadora 2 |
| 3 | Consulta ejecutores inactivos recaudadora 1 | { "id_rec": 1, "vigencia": "I" } | Tabla con ejecutores inactivos de recaudadora 1 |
| 4 | Consulta sin resultados | { "id_rec": 999, "vigencia": "A" } | Mensaje de 'No se encontraron ejecutores...' |
| 5 | Consulta con parámetro de vigencia nulo | { "id_rec": 1 } | Tabla con todos los ejecutores de recaudadora 1 |
| 6 | Error por parámetro faltante | { "vigencia": "A" } | Error indicando que falta 'id_rec' |
| 7 | Error por tipo de dato incorrecto | { "id_rec": "abc", "vigencia": "A" } | Error de validación o mensaje de error en eResponse |
