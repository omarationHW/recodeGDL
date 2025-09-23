# Casos de Prueba para RptFact_Merc

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| 1 | Consulta exitosa con datos existentes | rec=5, fol1=1000, fol2=1010 | Tabla con registros correspondientes |
| 2 | Consulta sin resultados | rec=99, fol1=99999, fol2=100000 | Mensaje 'No se encontraron resultados' |
| 3 | Parámetros insuficientes | rec=null, fol1=1000, fol2=1010 | Mensaje de error 'Parámetros insuficientes' |
| 4 | Folio inicial mayor que final | rec=5, fol1=2000, fol2=1000 | Mensaje 'No se encontraron resultados' o validación |
| 5 | Zona no numérica | rec='abc', fol1=1000, fol2=1010 | Mensaje de error de validación |
| 6 | Folios no numéricos | rec=5, fol1='x', fol2='y' | Mensaje de error de validación |
| 7 | Consulta con gran rango de folios | rec=5, fol1=1, fol2=100000 | Tabla con todos los registros del rango (performance) |
