# Documentación Técnica: Migración de Formulario newsfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario `newsfrm` de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (Base de datos). El formulario muestra los cambios/notas de versión del sistema y permite al usuario "aceptar" o reconocer los cambios.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 3+, componente de página independiente, sin tabs, con breadcrumbs y botón de aceptación.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  - `eRequest`: Nombre de la operación (ej: `get_news_changes`, `acknowledge_news_changes`)
  - `params`: Objeto con parámetros necesarios para la operación
- **Response:**
  - `eResponse`: Objeto con `success`, `data`, `message`

## 4. Stored Procedures
- `get_news_changes()`: Devuelve un listado de los cambios/notas de versión.
- `acknowledge_news_changes(p_user_id)`: Registra que un usuario ha leído los cambios (puede expandirse para auditoría real).

## 5. Frontend (Vue.js)
- Página independiente `/news`.
- Muestra los cambios en formato lista.
- Botón para "Aceptar Cambios" (simula registro de aceptación).
- Breadcrumb de navegación.

## 6. Seguridad
- El endpoint puede protegerse con middleware de autenticación (ej: Sanctum, JWT) si se requiere.
- El parámetro `user_id` debe obtenerse del contexto de usuario autenticado en producción.

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin crear nuevos endpoints.
- Los stored procedures pueden expandirse para registrar auditoría real, logs, etc.

## 8. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.
