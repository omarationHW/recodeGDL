# Documentación Técnica: Consulta de Pagos Capturados por Mercado (ConsCapturaFecha)

## Descripción General
Este módulo permite consultar y administrar los pagos capturados en mercados municipales, filtrando por fecha, oficina, caja y operación. Permite visualizar los pagos, seleccionar uno o varios y eliminarlos, restaurando el adeudo correspondiente si aplica.

## Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute` con patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA (Single Page Application), página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Comunicación:** JSON, API unificada

## Flujo de Datos
1. El usuario accede a la página y selecciona los filtros (fecha, oficina, caja, operación).
2. El frontend consulta las oficinas y cajas disponibles.
3. Al buscar, se llama al endpoint `/api/execute` con acción `getPagosByFecha`.
4. El backend ejecuta el stored procedure `sp_get_pagos_by_fecha` y retorna los pagos.
5. El usuario puede seleccionar pagos y eliminarlos. Al confirmar, se llama a la acción `deletePagos`.
6. El backend ejecuta `sp_delete_pago_local` para cada pago seleccionado, restaurando el adeudo si corresponde.

## API (Laravel Controller)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  - `eRequest.action`: Acción a ejecutar (`getPagosByFecha`, `deletePagos`, `getOficinas`, `getCajasByOficina`)
  - `eRequest.params`: Parámetros específicos de la acción
- **Salida:**
  - `eResponse.success`: true/false
  - `eResponse.data`: Datos de respuesta
  - `eResponse.message`: Mensaje de error o información

## Stored Procedures
- `sp_get_pagos_by_fecha(fecha, oficina, caja, operacion)`
- `sp_delete_pago_local(id_local, axo, periodo, usuario)`
- `sp_get_oficinas()`
- `sp_get_cajas_by_oficina(oficina)`

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel, según configuración).
- El usuario debe tener permisos para eliminar pagos.

## Validaciones
- Todos los campos de filtro son obligatorios.
- Solo se pueden borrar pagos seleccionados.
- Al borrar, se restaura el adeudo si no existe ya para ese periodo/local.

## Manejo de Errores
- Errores de validación y de base de datos se retornan en `eResponse.message`.
- El frontend muestra mensajes amigables al usuario.

## Consideraciones
- El borrado es lógico/físico según la política de la tabla (en este caso, físico, pero puede adaptarse).
- El frontend es reactivo y muestra el estado de carga y errores.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures encapsulan la lógica y pueden ser reutilizados por otros módulos.

## Integración
- El componente Vue puede integrarse en cualquier SPA o router Vue.
- El backend puede ser extendido para auditar operaciones o agregar logs.

