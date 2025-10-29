## Casos de Prueba para Listado de Descuentos en Multa

### Caso 1: Consulta exitosa con resultados
- **Entrada:** recaud=3, fini=2024-06-01, ffin=2024-06-30
- **Acción:** Enviar eRequest con estos parámetros
- **Esperado:** Se retorna un array con al menos un registro, todos los campos presentes, y el total de pagos corresponde al número de filas.

### Caso 2: Consulta sin resultados
- **Entrada:** recaud=2, fini=2023-01-01, ffin=2023-01-31
- **Acción:** Enviar eRequest con estos parámetros
- **Esperado:** Se retorna un array vacío, la tabla muestra 'Total de pagos: 0'.

### Caso 3: Parámetros inválidos (fecha fin < fecha inicio)
- **Entrada:** recaud=1, fini=2024-07-01, ffin=2024-06-01
- **Acción:** Enviar eRequest con estos parámetros
- **Esperado:** Se retorna un mensaje de error en eResponse indicando parámetros inválidos.

### Caso 4: Falta parámetro obligatorio
- **Entrada:** recaud=3, fini=2024-06-01 (sin ffin)
- **Acción:** Enviar eRequest sin el parámetro ffin
- **Esperado:** Se retorna un mensaje de error por parámetro faltante.

### Caso 5: SQL Injection attempt
- **Entrada:** recaud="3; DROP TABLE pagos; --", fini=2024-06-01, ffin=2024-06-30
- **Acción:** Enviar eRequest con intento de inyección
- **Esperado:** El backend rechaza la petición y no ejecuta código malicioso.
