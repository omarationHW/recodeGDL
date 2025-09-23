# Casos de Prueba: Reasignación de Ejecutor

## Caso 1: Reasignación masiva exitosa
- **Entrada:**
  - folioDesde: 1000
  - folioHasta: 1010
  - recaudadora: 1
  - modulo: 16
  - nuevoEjecutor: 45
  - fechaEntrega2: '2024-06-10'
- **Acción:** Buscar folios, seleccionar todos, reasignar
- **Esperado:** Todos los folios se actualizan correctamente en la base de datos

## Caso 2: Validación de rango incorrecto
- **Entrada:**
  - folioDesde: 1050
  - folioHasta: 1040
- **Acción:** Buscar folios
- **Esperado:** Mensaje de error: 'Error: Folio Desde no puede ser mayor que Folio Hasta'

## Caso 3: Reasignación parcial
- **Entrada:**
  - folios seleccionados: [2001, 2003]
  - nuevoEjecutor: 50
  - fechaEntrega2: '2024-06-15'
- **Acción:** Buscar folios, seleccionar algunos, reasignar
- **Esperado:** Solo los folios seleccionados son actualizados

## Caso 4: Error de base de datos
- **Simulación:** Forzar error en la base de datos (por ejemplo, id_control inexistente)
- **Esperado:** El sistema hace rollback y muestra mensaje de error

## Caso 5: Sin folios encontrados
- **Entrada:**
  - folioDesde: 99999
  - folioHasta: 99999
- **Acción:** Buscar folios
- **Esperado:** Mensaje: 'No se encontraron folios para los criterios seleccionados.'
