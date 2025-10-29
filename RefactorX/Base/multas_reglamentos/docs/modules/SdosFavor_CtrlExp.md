# Documentación Técnica: Migración de SdosFavor_CtrlExp (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta, filtrado y asignación de folios de solicitudes de saldos a favor (tabla `solic_sdosfavor`) según su estatus. El formulario original en Delphi se migró a una arquitectura moderna usando Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador único (`SdosFavorCtrlExpController`) con endpoint `/api/execute` que implementa el patrón eRequest/eResponse.
- **Frontend:** Vue.js 3 SPA, componente de página independiente (`SdosFavorCtrlExp.vue`).
- **Base de datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "status": "success|error",
    "data": ...
  }
  ```

### Acciones soportadas
- `getStatusOptions`: Devuelve los estatus posibles para filtrar folios.
- `searchFolios`: Devuelve los folios filtrados por estatus.
- `assignFolios`: Asigna un nuevo estatus a una lista de folios.
- `getTotalFolios`: Devuelve el total de folios para un estatus.

## 4. Stored Procedures
Toda la lógica SQL se encapsula en stored procedures para:
- Consultar folios (`sp_sdosfavor_search_folios`)
- Asignar folios (`sp_sdosfavor_assign_folios`)
- Contar folios (`sp_sdosfavor_total_folios`)

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar estatus, buscar folios, seleccionar múltiples folios y asignarles un nuevo estatus.
- Muestra el total de folios encontrados.
- Navegación breadcrumb incluida.
- Uso de Axios para consumir el endpoint `/api/execute`.

## 6. Seguridad
- El endpoint requiere autenticación (middleware Laravel, si aplica).
- Validación de parámetros en backend.

## 7. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales propietarios; en Vue.js se usan controles HTML estándar.
- La lógica de filtrado y asignación se centraliza en el backend.
- El acceso a la base de datos se realiza exclusivamente vía stored procedures.

## 8. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- El frontend puede extenderse fácilmente para nuevas operaciones.

## 9. Pruebas y QA
- Se proveen casos de uso y escenarios de prueba para QA manual y automatizado.

