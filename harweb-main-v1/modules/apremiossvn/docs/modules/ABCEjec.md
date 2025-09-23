# Documentación Técnica: Catálogo de Ejecutores (ABCEjec)

## Descripción General
Este módulo permite la administración del catálogo de ejecutores fiscales, incluyendo alta, modificación, consulta y cambio de vigencia (baja/reactivación). La migración se realizó desde Delphi a una arquitectura Laravel + Vue.js + PostgreSQL, usando un endpoint API unificado y stored procedures para toda la lógica de negocio.

## Arquitectura
- **Backend:** Laravel (PHP), con un único controlador y endpoint `/api/execute`.
- **Frontend:** Vue.js (SPA), cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica en stored procedures.
- **API:** Patrón eRequest/eResponse, endpoint único.

## API Endpoint
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "list|get|create|update|toggle_vigencia",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "result": [ ... ],
      "error": null
    }
  }
  ```

## Acciones soportadas
- `list`: Lista todos los ejecutores de una recaudadora (`id_rec`)
- `get`: Obtiene un ejecutor específico (`cve_eje`, `id_rec`)
- `create`: Alta de ejecutor (campos obligatorios)
- `update`: Modificación de ejecutor
- `toggle_vigencia`: Cambia la vigencia (baja/reactiva)

## Stored Procedures
Toda la lógica de negocio y validación reside en stored procedures PostgreSQL. El controlador Laravel solo enruta y valida parámetros básicos.

## Frontend
- Página Vue.js independiente para ejecutores.
- Tabla de ejecutores filtrada por recaudadora.
- Formulario modal para alta/edición.
- Botón para baja/reactivación.
- Navegación breadcrumb.

## Seguridad
- Validación de datos en backend y frontend.
- Solo usuarios autenticados pueden acceder (middleware Laravel).
- Cambios de vigencia y edición requieren confirmación.

## Auditoría
- (Opcional) Cada cambio puede registrarse en una tabla de historial mediante el SP `sp_ejecutores_historia_insert`.

## Consideraciones de Migración
- Todos los queries Delphi se migraron a stored procedures.
- El endpoint es unificado y desacoplado de la UI.
- El frontend es desacoplado, sin tabs ni componentes tabulares.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ser versionados y auditados.
