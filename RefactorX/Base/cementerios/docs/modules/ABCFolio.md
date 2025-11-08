# Documentación Técnica - Migración ABCFolio Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio crítica en stored procedures.
- **Patrón de integración**: eRequest/eResponse (entrada y salida JSON estructurado).

## 2. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ "eRequest": { "action": "get|update|delete|getAdicional|updateAdicional|deleteAdicional", ...params } }`
- **Salida**: `{ "eResponse": { "success": bool, "message": string, "data": object|null } }`

### Acciones soportadas
- `get`: Obtener todos los datos de un folio (incluye adicionales y adeudos)
- `update`: Modificar datos principales del folio
- `delete`: Baja lógica del folio
- `getAdicional`: Obtener datos adicionales
- `updateAdicional`: Modificar/insertar datos adicionales
- `deleteAdicional`: Eliminar datos adicionales

## 3. Stored Procedures
- Toda la lógica de actualización, baja, y consulta está en SPs PostgreSQL.
- Los SPs devuelven errores mediante excepciones o mensajes controlados.
- Se utiliza un SP de histórico (`sp_13_historia`) para registrar cambios.

## 4. Frontend Vue.js
- Página independiente para ABCFolio (NO tabs, NO componentes compartidos con otros formularios).
- Formulario reactivo, validación básica en frontend.
- Navegación simple, sin breadcrumbs (puede agregarse si se requiere).
- Adeudos mostrados en tabla de solo lectura.
- Botón de baja lógica (no elimina físicamente).

## 5. Seguridad
- El endpoint requiere autenticación (Laravel Sanctum/JWT recomendado).
- El ID de usuario se obtiene del token y se pasa a los SPs para auditoría.

## 6. Manejo de errores
- Todos los errores de validación y de base de datos se devuelven en el campo `message` de la respuesta.
- El frontend muestra los errores en pantalla.

## 7. Consideraciones de migración
- Los nombres de campos y tablas se mantienen para compatibilidad.
- Las operaciones de modificación y baja actualizan el histórico automáticamente.
- Los datos adicionales se insertan o actualizan según existencia previa.

## 8. Pruebas y QA
- Casos de uso y pruebas detalladas en la sección correspondiente.

---
