# Documentación Técnica: Migración Formulario ConsultaJardin (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), PostgreSQL 13+
- **Frontend:** Vue.js 3 (SPA o multipágina), Bootstrap 4/5 para UI
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** Tabla `regprop` en PostgreSQL (estructura equivalente a la original)
- **Stored Procedures:** Toda la lógica de consulta encapsulada en funciones PostgreSQL

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "consulta_jardin_by_rcm|consulta_jardin_by_nombre|consulta_jardin_by_partida",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": ""
  }
  ```

## Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las acciones.
- Cada acción llama a un stored procedure/función de PostgreSQL.
- Manejo de errores y validación básica.

## Stored Procedures PostgreSQL
- Cada consulta relevante se implementa como una función SQL (`consulta_jardin_by_rcm`, `consulta_jardin_by_nombre`, `consulta_jardin_by_partida`).
- Devuelven un `TABLE` con los campos requeridos.
- Uso de `ILIKE` para búsquedas insensibles a mayúsculas/minúsculas.

## Componente Vue.js
- Página independiente, sin tabs ni pestañas.
- Permite seleccionar el tipo de consulta (RCM, Nombre, Partida).
- Formulario reactivo, validación básica.
- Muestra resultados en tabla responsive.
- Manejo de estados: cargando, error, sin resultados.
- Navegación breadcrumb.

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o session según el contexto.
- Validar y sanear todos los parámetros recibidos.

## Consideraciones de Migración
- Los nombres de campos y lógica de búsqueda se mantienen equivalentes al Delphi original.
- El frontend reproduce la experiencia de usuario (UX) del formulario Delphi, adaptada a web.
- El endpoint único permite fácil extensión para otros formularios.

## Despliegue
- Backend: Laravel + PostgreSQL, configurar variables de entorno para conexión DB.
- Frontend: Vue.js, puede ser servido por Laravel Mix o como SPA independiente.
- Documentar y versionar los stored procedures en scripts SQL.

## Pruebas
- Pruebas unitarias para el controlador y las funciones SQL.
- Pruebas de integración para el flujo completo (frontend <-> backend <-> DB).

