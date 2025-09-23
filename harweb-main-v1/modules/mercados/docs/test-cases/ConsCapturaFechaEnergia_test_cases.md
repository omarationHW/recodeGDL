# Casos de Prueba: ConsCapturaFechaEnergia

## Caso 1: Consulta de Pagos Existentes
- **Entrada:** fecha_pago=2024-06-01, oficina_pago=1, caja_pago='A', operacion_pago=12345
- **Acción:** Buscar pagos
- **Resultado esperado:** Lista de pagos mostrada, success=true

## Caso 2: Consulta sin Resultados
- **Entrada:** fecha_pago=2024-06-01, oficina_pago=99, caja_pago='Z', operacion_pago=99999
- **Acción:** Buscar pagos
- **Resultado esperado:** Lista vacía, success=true

## Caso 3: Eliminación de Pagos Existentes
- **Entrada:** pagos_ids=[101,102], fecha_pago=2024-06-01, oficina_pago=1, operacion_pago=12345
- **Acción:** Borrar pagos
- **Resultado esperado:** success=true, pagos eliminados, adeudos regenerados si corresponde

## Caso 4: Eliminación de Pagos No Existentes
- **Entrada:** pagos_ids=[9999], fecha_pago=2024-06-01, oficina_pago=1, operacion_pago=12345
- **Acción:** Borrar pagos
- **Resultado esperado:** success=true, sin error, no afecta datos

## Caso 5: Carga de Cajas por Oficina
- **Entrada:** oficina=1
- **Acción:** Consultar cajas
- **Resultado esperado:** Lista de cajas asociadas a la oficina 1

## Caso 6: Validación de Permisos
- **Entrada:** Usuario sin permisos de eliminación
- **Acción:** Intentar borrar pagos
- **Resultado esperado:** success=false, mensaje de error de permisos
