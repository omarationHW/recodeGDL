# Casos de Prueba: RptPagosContratosDecsDev

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta exitosa con colonia existente y datos | { "colonia": 5 } | success=true, data contiene lista de contratos, message="" |
| 2 | Consulta con colonia existente pero sin datos | { "colonia": 99 } | success=true, data=[], message="" |
| 3 | Consulta con parámetro colonia faltante | { } | success=false, data=null, message contiene "colonia es requerido" |
| 4 | Consulta con parámetro colonia no numérico | { "colonia": "abc" } | success=false, data=null, message contiene "colonia es requerido" |
| 5 | Consulta con colonia que genera error en BD | { "colonia": -1 } | success=false, data=null, message contiene error de BD |
| 6 | Consulta con colonia válida, verificar totales | { "colonia": 5 } | El total de importe en el pie de tabla es igual a la suma de los importes de los registros |
