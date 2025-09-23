# Documentación Técnica: Consulta de Pagos (ConsPagos)

## Descripción General
Este módulo permite consultar, agregar y eliminar pagos asociados a un local específico en el sistema de mercados municipales. La migración se realizó desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), siguiendo el patrón eRequest/eResponse con un endpoint unificado `/api/execute`.

## Arquitectura
- **Backend:** Laravel Controller (`ConsPagosController`) expone un endpoint `/api/execute` que recibe acciones y parámetros en formato JSON.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs, con navegación breadcrumb y tabla de resultados.
- **Base de Datos:** Toda la lógica SQL se encapsula en stored procedures PostgreSQL.
- **API:** Todas las operaciones (consulta, alta, baja) se realizan a través de un único endpoint, usando el campo `action` para determinar la operación.

## Flujo de Datos
1. El usuario ingresa el ID del local y consulta los pagos asociados.
2. Puede agregar un nuevo pago llenando el formulario modal.
3. Puede eliminar un pago existente desde la tabla.
4. Todas las operaciones se comunican con el backend mediante `/api/execute`.

## Formato de Petición (eRequest)
```json
{
  "action": "getPagosByLocal", // o "addPago", "deletePago"
  "params": { ... } // parámetros según la acción
}
```

## Formato de Respuesta (eResponse)
```json
{
  "success": true,
  "data": [...], // o null
  "message": "Mensaje de error o éxito"
}
```

## Stored Procedures
- **sp_cons_pagos_get_by_local:** Devuelve todos los pagos de un local, con datos relacionados.
- **sp_cons_pagos_add:** Inserta un nuevo pago.
- **sp_cons_pagos_delete:** Elimina un pago por su identificador.

## Seguridad
- Validación de parámetros en backend (Laravel Validator).
- El id_usuario debe ser autenticado en producción (en el ejemplo se simula).
- El endpoint debe protegerse con autenticación JWT o similar en producción.

## Consideraciones de Migración
- Los campos y lógica de negocio se respetan según el código Delphi original.
- Los nombres de tablas y campos se mantienen para compatibilidad.
- El frontend es completamente independiente y funcional como página única.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ampliarse para lógica adicional (por ejemplo, validaciones de negocio más complejas).

## Dependencias
- Laravel 10+
- Vue.js 2/3 + Element UI (o similar)
- PostgreSQL 12+

