# Casos de Prueba: Adeudo Global con Accesorios

## Caso 1: Consulta exitosa de locales con adeudo
- **Entrada:** office_id=1, market_id=14, year=2024, month=6
- **Acción:** Buscar
- **Resultado esperado:** Lista de locales con adeudo y accesorios, campos: oficina, mercado, categoria, seccion, local, nombre, adeudo, recargos, multa, gastos.

## Caso 2: Consulta sin resultados
- **Entrada:** office_id=1, market_id=99, year=2024, month=6 (mercado inexistente)
- **Acción:** Buscar
- **Resultado esperado:** Tabla vacía, mensaje 'No hay resultados'.

## Caso 3: Exportar a Excel
- **Precondición:** Hay resultados en la tabla
- **Acción:** Click en 'Excel 1'
- **Resultado esperado:** Descarga de archivo Excel con los mismos datos de la tabla.

## Caso 4: Consulta de locales sin adeudo pero con accesorios
- **Entrada:** market_id=14, year=2024, month=6
- **Acción:** Click en 'Locales sin Adeudo con Accesorios'
- **Resultado esperado:** Tabla con locales sin adeudo pero con accesorios.

## Caso 5: Validación de campos obligatorios
- **Entrada:** No seleccionar oficina o mercado
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'Seleccione oficina y mercado'.
