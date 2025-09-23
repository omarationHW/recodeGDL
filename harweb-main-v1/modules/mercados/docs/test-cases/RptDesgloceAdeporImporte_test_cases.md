## Casos de Prueba para RptDesgloceAdeporImporte

| #  | Descripción | Entrada | Resultado Esperado |
|----|-------------|---------|-------------------|
| 1  | Consulta exitosa con datos | year=2023, period=6, amount=1000 | Tabla con resultados y totales |
| 2  | Consulta sin resultados | year=2023, period=6, amount=1000000 | Mensaje de 'No se encontraron resultados...' |
| 3  | Parámetro año faltante | year=null, period=6, amount=1000 | Mensaje de error 'Parámetros insuficientes' |
| 4  | Parámetro periodo fuera de rango | year=2023, period=13, amount=1000 | Mensaje de error o validación frontend |
| 5  | Importe negativo | year=2023, period=6, amount=-500 | Mensaje de error o validación frontend |
| 6  | Consulta con caracteres no numéricos | year='abcd', period=6, amount=1000 | Mensaje de error de validación |
| 7  | Consulta con todos los campos en cero | year=0, period=0, amount=0 | Mensaje de error o sin resultados |
| 8  | Consulta con año futuro | year=2100, period=1, amount=1000 | Tabla vacía o sin resultados |

### Notas:
- Todos los casos deben probarse tanto en frontend (validación de formulario) como en backend (respuesta de la API).
- Los casos 4, 5, 6 y 7 deben ser bloqueados por validación en el frontend, pero si llegan al backend, deben retornar error adecuado.
