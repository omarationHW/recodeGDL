# Casos de Prueba para Estadística de Notificaciones por Folio

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Consulta exitosa con datos válidos | modu=11, rec=1, fol1=1000, fol2=2000 | Tabla con datos agrupados por vigencia y clave_practicado, sumatorias correctas |
| 2 | Consulta de oficina recaudadora existente | reca=2 | Datos de recaudadora y zona mostrados correctamente |
| 3 | Consulta sin datos en rango | modu=11, rec=1, fol1=999999, fol2=999999 | Tabla vacía o mensaje 'No hay datos' |
| 4 | Falta parámetro obligatorio | (omitir fol1) | Error en frontend y mensaje de error en API |
| 5 | Parámetros fuera de rango | modu=99, rec=999, fol1=1, fol2=2 | Tabla vacía o mensaje 'No hay datos' |
| 6 | Consulta con caracteres no numéricos | fol1='abc' | Validación frontend impide envío, no se consulta API |
| 7 | Consulta de recaudadora inexistente | reca=9999 | No se muestra información de oficina |
