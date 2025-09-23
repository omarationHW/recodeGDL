# CargaPagDiversos - Documentación Técnica

## Descripción General
Este módulo permite consultar y cargar pagos diversos (no asociados a convenios prediales) provenientes de la recaudadora, para posteriormente asociarlos a contratos/convenios existentes. El proceso consta de dos fases principales:

1. **Consulta de pagos diversos pendientes**: Filtra por rango de fechas y recaudadora, mostrando los pagos que aún no han sido cargados a convenios.
2. **Carga de pagos seleccionados**: Permite seleccionar uno o varios pagos y grabarlos en la tabla de pagos, validando la existencia del contrato destino.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Componente Vue.js como página independiente.
- **Base de datos**: PostgreSQL, lógica encapsulada en stored procedures.
- **Seguridad**: Solo usuarios con nivel 1 pueden cargar pagos de otras recaudadoras.

## API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "buscarPagosDiversos|grabarPagosDiversos|getRecaudadoras",
    "params": { ... }
  }
  ```
- **Autenticación**: JWT o Sanctum (Laravel Auth)

### Acciones soportadas
- `buscarPagosDiversos`: Busca pagos pendientes por fecha y recaudadora.
- `grabarPagosDiversos`: Graba los pagos seleccionados.
- `getRecaudadoras`: Devuelve catálogo de recaudadoras.

## Stored Procedures
- `sp_buscar_pagos_diversos`: Devuelve pagos pendientes de cargar.
- `sp_grabar_pago_diverso`: Inserta un pago diverso, validando contrato.

## Validaciones
- Fechas y recaudadora requeridas para búsqueda.
- Solo usuarios autorizados pueden cargar pagos de otras recaudadoras.
- Al grabar, se valida que el contrato destino exista.
- Si algún pago falla, se revierte toda la transacción.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario de búsqueda (fechas, recaudadora).
- Tabla de resultados con checkboxes para seleccionar pagos.
- Botón para grabar pagos seleccionados.
- Mensajes de éxito/error.

## Seguridad
- El backend valida el nivel del usuario y la recaudadora seleccionada.
- Todas las operaciones de grabado se ejecutan en transacción.

## Errores comunes
- Si no existe el contrato destino, el pago no se graba y se muestra el error.
- Si el usuario no tiene permisos, se rechaza la operación.

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas.
- Los stored procedures pueden ser reutilizados por otros módulos.
