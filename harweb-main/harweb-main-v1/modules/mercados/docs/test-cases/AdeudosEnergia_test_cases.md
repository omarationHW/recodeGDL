# Casos de Prueba: Adeudos de Energía Eléctrica

## Caso 1: Consulta exitosa
- **Entrada:** Año=2024, Oficina=5
- **Acción:** Buscar
- **Resultado esperado:** Tabla con datos de adeudos, sin errores.

## Caso 2: Año fuera de rango
- **Entrada:** Año=1990, Oficina=1
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'Año fuera de rango'.

## Caso 3: Oficina no seleccionada
- **Entrada:** Año=2024, Oficina=''
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error 'Debe seleccionar una oficina'.

## Caso 4: Exportar Excel sin datos
- **Entrada:** Sin realizar búsqueda
- **Acción:** Presionar 'Excel'
- **Resultado esperado:** Mensaje de error 'No hay datos para exportar'.

## Caso 5: Imprimir sin datos
- **Entrada:** Sin realizar búsqueda
- **Acción:** Presionar 'Imprimir'
- **Resultado esperado:** Mensaje de error 'No hay datos para imprimir'.

## Caso 6: Consulta con datos inexistentes
- **Entrada:** Año=2099, Oficina=9
- **Acción:** Buscar
- **Resultado esperado:** Tabla vacía, mensaje 'No hay datos para los filtros seleccionados.'
