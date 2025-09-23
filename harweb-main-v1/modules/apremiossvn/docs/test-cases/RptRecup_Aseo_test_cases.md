# Casos de Prueba: RptRecup_Aseo

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta exitosa de reporte | folio1=1000, folio2=1010, ofna=5 | Lista de adeudos y recaudadora mostrada |
| TC02 | Falta parámetro folio1 | folio1='', folio2=1010, ofna=5 | Error: Parámetros requeridos |
| TC03 | Rango sin resultados | folio1=999999, folio2=999999, ofna=5 | Mensaje: No se encontraron registros |
| TC04 | Parámetro oficina inválido | folio1=1000, folio2=1010, ofna='abc' | Error: Parámetros requeridos |
| TC05 | Consulta con folio1 > folio2 | folio1=1010, folio2=1000, ofna=5 | Lista vacía o mensaje de advertencia |
| TC06 | Consulta con fecha a letras | fecha='2024-06-01' | '1 de Junio de 2024' |

**Notas:**
- Todos los errores deben retornar en `eResponse.message`.
- El frontend debe manejar correctamente los estados de carga, error y éxito.
