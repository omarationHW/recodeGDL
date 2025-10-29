## Casos de Prueba: Formulario 'Pagar hasta'

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|-------------------|
| 1 | Validación exitosa | bimestre=3, anio=2023 | Aceptar | Mensaje de éxito, datos aceptados |
| 2 | Bimestre fuera de rango | bimestre=0, anio=2023 | Aceptar | Error: 'El bimestre solo puede ser de 1 a 6.' |
| 3 | Año menor a 1970 | bimestre=2, anio=1969 | Aceptar | Error: 'El año debe estar entre 1970 y [año actual]' |
| 4 | Año mayor al actual | bimestre=2, anio=2100 | Aceptar | Error: 'El año debe estar entre 1970 y [año actual]' |
| 5 | Campos vacíos | bimestre='', anio='' | Aceptar | Error de campos obligatorios |
| 6 | Cancelar operación | N/A | Cancelar | bimestre=9, anio=9999, mensaje de cancelación |
| 7 | Bimestre no numérico | bimestre='a', anio=2023 | Aceptar | Error de validación |
| 8 | Año no numérico | bimestre=2, anio='abcd' | Aceptar | Error de validación |
