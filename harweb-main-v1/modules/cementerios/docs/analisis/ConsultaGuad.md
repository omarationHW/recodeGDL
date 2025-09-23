# Documentación Técnica: Migración Formulario ConsultaGuad (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de consulta encapsulada en stored procedures.
- **Patrón de integración:** eRequest/eResponse (el frontend envía `{action, params}` y recibe `{success, data, message}`).

## 2. API Backend
- **Ruta:** `POST /api/execute`
- **Controlador:** `ConsultaGuadController`
- **Acciones soportadas:**
  - `consulta_por_rcm`: Consulta por clase, sección y línea.
  - `consulta_por_nombre`: Consulta por nombre (LIKE).
  - `consulta_por_partida`: Consulta por partida de pago (ppago LIKE).
- **Parámetros:**
  - Para RCM: `{clase, seccion, linea}`
  - Para nombre: `{nombre}`
  - Para partida: `{partida}`
- **Respuesta:**
  - `success`: boolean
  - `data`: array de resultados
  - `message`: mensaje de error o vacío

## 3. Stored Procedures PostgreSQL
- Cada consulta se implementa como una función SQL (`RETURNS TABLE`) para máxima eficiencia y seguridad.
- Todas las funciones devuelven los mismos campos que el grid original Delphi.
- Uso de `ILIKE` para búsquedas insensibles a mayúsculas/minúsculas.

## 4. Frontend Vue.js
- **Página independiente:** `ConsultaGuadPage.vue`
- **Navegación:** No usa tabs, cada formulario es una ruta/página.
- **UI:**
  - Radio buttons para elegir tipo de consulta.
  - Inputs dinámicos según tipo de consulta.
  - Tabla de resultados con todos los campos relevantes.
  - Mensajes de error y loading.
- **Integración API:**
  - Llama a `/api/execute` con `{action, params}`.
  - Muestra resultados en tabla.

## 5. Seguridad
- Todas las consultas usan parámetros (no SQL injection).
- El endpoint puede protegerse con middleware de autenticación Laravel si se requiere.

## 6. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden evolucionar sin cambiar el frontend.

## 7. Migración de Queries
- Todas las queries Delphi se migran a funciones PostgreSQL.
- Los nombres de campos y tablas deben coincidir con la estructura original (`regprop`).

## 8. Consideraciones de UI/UX
- Validaciones mínimas en frontend (ej: clase entre 1 y 3).
- Mensajes claros de error y loading.
- Responsive y accesible.

## 9. Pruebas
- Casos de uso y pruebas detalladas incluidas (ver secciones abajo).

## 10. Despliegue
- Backend: Laravel migraciones, seeders y configuración de conexión PostgreSQL.
- Frontend: Vue.js build estándar, integración con backend vía fetch/Axios.
- DB: Crear funciones SQL antes de exponer el API.
