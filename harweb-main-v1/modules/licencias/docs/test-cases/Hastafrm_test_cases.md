## Casos de Prueba para Formulario 'Pagar hasta'

| #  | Descripción                                 | Entrada                | Acción         | Resultado Esperado                         |
|----|---------------------------------------------|------------------------|----------------|--------------------------------------------|
| 1  | Bimestre y año válidos                      | bimestre=3, año=2022   | Aceptar        | Validación exitosa, mensaje de éxito       |
| 2  | Bimestre fuera de rango (0)                 | bimestre=0, año=2022   | Aceptar        | Error: 'Bimestre inválido'                 |
| 3  | Bimestre fuera de rango (7)                 | bimestre=7, año=2022   | Aceptar        | Error: 'Bimestre inválido'                 |
| 4  | Año menor a 1970                            | bimestre=2, año=1969   | Aceptar        | Error: 'Año inválido'                      |
| 5  | Año mayor al actual                         | bimestre=2, año=2099   | Aceptar        | Error: 'Año inválido'                      |
| 6  | Campos vacíos                               | bimestre= , año=       | Aceptar        | Error: campos obligatorios                 |
| 7  | Cancelación                                 | (cualquier valor)      | Cancelar       | bimestre=9, año=9999, mensaje de cancelación|
| 8  | Bimestre válido, año vacío                  | bimestre=2, año=       | Aceptar        | Error: 'Año es obligatorio'                |
| 9  | Año válido, bimestre vacío                  | bimestre= , año=2022   | Aceptar        | Error: 'Bimestre es obligatorio'           |
| 10 | Bimestre y año en el límite inferior        | bimestre=1, año=1970   | Aceptar        | Validación exitosa                         |
| 11 | Bimestre y año en el límite superior        | bimestre=6, año=(actual)| Aceptar       | Validación exitosa                         |
