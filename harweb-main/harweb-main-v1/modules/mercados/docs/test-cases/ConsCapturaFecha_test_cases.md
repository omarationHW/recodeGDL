# Casos de Prueba: Consulta de Pagos Capturados por Mercado

## Caso 1: Consulta exitosa de pagos
- **Entrada:** fecha = '2024-06-01', oficina = 2, caja = 'A', operacion = 12345
- **Acción:** Buscar pagos
- **Resultado esperado:** Lista de pagos mostrada, sin errores.

## Caso 2: Eliminación de pago y restauración de adeudo
- **Entrada:** Selección de pago con id_local=1001, axo=2024, periodo=6
- **Acción:** Borrar pago
- **Resultado esperado:** El pago desaparece de la lista y el adeudo se restaura en la base de datos.

## Caso 3: Validación de campos obligatorios
- **Entrada:** No seleccionar fecha u oficina
- **Acción:** Buscar pagos
- **Resultado esperado:** Mensaje de error indicando que los campos son obligatorios.

## Caso 4: Consulta de cajas por oficina
- **Entrada:** Selección de oficina 3
- **Acción:** Cargar cajas
- **Resultado esperado:** Se muestran solo las cajas asociadas a la oficina 3.

## Caso 5: Error de base de datos
- **Simulación:** La base de datos está caída
- **Acción:** Buscar pagos
- **Resultado esperado:** Mensaje de error amigable indicando problema de conexión.
