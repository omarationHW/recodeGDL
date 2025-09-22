# Documentación Técnica: Prenómina de Ejecutores

## Descripción General
Este módulo permite generar el reporte de prenómina de ejecutores, mostrando el total de gastos y folios pagados por ejecutor en un rango de fechas y recaudadoras. La migración Delphi → Laravel + Vue.js + PostgreSQL se implementa usando un endpoint API unificado y stored procedures para la lógica de negocio.

## Arquitectura
- **Frontend**: Vue.js SPA, página independiente `/prenomina`.
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos**: PostgreSQL, lógica en stored procedures.

## Flujo de Datos
1. El usuario accede a la página Prenómina.
2. Selecciona fechas y recaudadora (todas o una específica).
3. El frontend envía un POST a `/api/execute` con `action` y `params`.
4. El backend ejecuta el stored procedure correspondiente y retorna los datos.
5. El frontend muestra el reporte tabular.

## API
- **POST /api/execute**
  - **action**: `getPrenominaReport` | `getRecaudadoras`
  - **params**: parámetros según acción
  - **Respuesta**: `{ success, data, message }`

## Stored Procedures
- `sp_get_recaudadoras()`: Catálogo de recaudadoras.
- `sp_prenomina_report(fecha_desde, fecha_hasta, recaudadora_desde, recaudadora_hasta)`: Reporte de prenómina.

## Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación Laravel.

## Consideraciones
- El frontend es desacoplado y puede integrarse en cualquier SPA Vue.js.
- El backend es extensible para otras acciones.
- El reporte puede exportarse a Excel desde el frontend si se requiere.

## Migración SQL
- Todas las consultas Delphi se migran a stored procedures PostgreSQL.
- El reporte principal usa agregaciones y joins para obtener los datos requeridos.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ampliarse para nuevos reportes.
