## Casos de Prueba para Estadístico de Pagos

### Caso 1: Consulta año completo
- **Entrada:** aso_in=2023, mes_in=1, aso_fin=2023, mes_fin=12
- **Esperado:** 12 filas, cada una con totales de cuota normal, excedente y contenedores. Suma de totales igual a la suma de pagos en la base de datos para ese año.

### Caso 2: Consulta un solo mes
- **Entrada:** aso_in=2024, mes_in=3, aso_fin=2024, mes_fin=3
- **Esperado:** 1 fila, totales correctos para marzo 2024.

### Caso 3: Periodo inválido
- **Entrada:** aso_in=2024, mes_in=5, aso_fin=2023, mes_fin=12
- **Esperado:** Error de validación, no se ejecuta consulta, mensaje de error visible.

### Caso 4: Sin resultados
- **Entrada:** aso_in=2050, mes_in=1, aso_fin=2050, mes_fin=12
- **Esperado:** Tabla vacía o mensaje 'No hay datos para el periodo seleccionado'.

### Caso 5: Validación de campos obligatorios
- **Entrada:** aso_in vacío, mes_in vacío
- **Esperado:** Error de validación, mensaje 'El campo año/mes es obligatorio'.
