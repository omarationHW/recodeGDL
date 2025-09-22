# Casos de Prueba

## Caso 1: Búsqueda exitosa por placa
- **Entrada**: placa = 'ABC1234', opcion = 0
- **Acción**: Buscar folios
- **Esperado**: Se listan todos los folios asociados a 'ABC1234'.

## Caso 2: Búsqueda por placa y folio inexistente
- **Entrada**: placa = 'ZZZ9999', folio = 9999, opcion = 1
- **Acción**: Buscar folios
- **Esperado**: Se muestra mensaje 'No se encontraron registros.'

## Caso 3: Aplicar pago a folios seleccionados
- **Entrada**: Seleccionar folios [201, 202], fecha = '2024-06-10', recaudadora = 2, caja = '02', oper = '54321', usuario = 'admin'
- **Acción**: Aplicar pago
- **Esperado**: Mensaje de éxito y folios actualizados como pagados.

## Caso 4: Intentar aplicar pago sin seleccionar folios
- **Entrada**: Ningún folio seleccionado
- **Acción**: Aplicar pago
- **Esperado**: Mensaje 'Debe seleccionar al menos un folio.'

## Caso 5: Error en base de datos al aplicar pago
- **Simulación**: Forzar error en stored procedure (por ejemplo, folio inexistente)
- **Acción**: Aplicar pago
- **Esperado**: Mensaje de error y ningún folio actualizado.
