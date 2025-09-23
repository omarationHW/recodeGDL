# Casos de Prueba: RptReq_Aseo

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta exitosa de adeudos | folio1=1000, folio2=1010, ofna=5 | Lista de adeudos y datos de recaudadora mostrados correctamente |
| TC02 | Consulta sin resultados | folio1=999999, folio2=1000000, ofna=5 | Mensaje de 'No se encontraron registros' |
| TC03 | Parámetro faltante (folio1) | folio1=null, folio2=1010, ofna=5 | Error de validación: 'Missing parameters' |
| TC04 | Parámetro no numérico | folio1='abc', folio2=1010, ofna=5 | Error de validación: 'Missing parameters' |
| TC05 | Consulta con recaudadora inexistente | folio1=1000, folio2=1010, ofna=9999 | Lista de adeudos vacía y recaudadora vacía |
| TC06 | Consulta con folio1 > folio2 | folio1=1010, folio2=1000, ofna=5 | Lista de adeudos vacía |
| TC07 | Consulta con todos los campos vacíos | folio1=null, folio2=null, ofna=null | Error de validación: 'Missing parameters' |
