## Casos de Prueba para Formulario 'Pagar hasta'

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Bimestre y año válidos | bimestre: 4, año: 2022 | Validación exitosa. |
| 2 | Bimestre fuera de rango | bimestre: 0, año: 2022 | Bimestre inválido! |
| 3 | Bimestre fuera de rango | bimestre: 7, año: 2022 | Bimestre inválido! |
| 4 | Año menor a 1970 | bimestre: 2, año: 1960 | Año inválido! |
| 5 | Año mayor al actual | bimestre: 2, año: 2099 | El año no puede ser mayor al año actual |
| 6 | Campos vacíos | bimestre: '', año: '' | Mensaje de error de campos obligatorios |
| 7 | Cancelación | bimestre: 9, año: 9999 | Operación cancelada. |
| 8 | Bimestre no numérico | bimestre: 'a', año: 2022 | Mensaje de error de formato |
| 9 | Año no numérico | bimestre: 2, año: 'abcd' | Mensaje de error de formato |
