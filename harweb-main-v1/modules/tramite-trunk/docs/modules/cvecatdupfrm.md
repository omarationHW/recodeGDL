# Documentación Técnica: Módulo Claves Catastrales Duplicadas (cvecatdup)

## Descripción General
Este módulo permite la gestión de claves catastrales duplicadas en el sistema de Catastro, migrado desde Delphi a una arquitectura Laravel + Vue.js + PostgreSQL. Incluye:
- API RESTful unificada con endpoint `/api/execute` (patrón eRequest/eResponse)
- Controlador Laravel para la lógica de negocio
- Componente Vue.js como página independiente
- Stored Procedures en PostgreSQL para operaciones CRUD y consulta

## Arquitectura
- **Backend:** Laravel 10+, PHP 8+, PostgreSQL
- **Frontend:** Vue.js 3+, Vue Router
- **API:** Un único endpoint `/api/execute` que recibe `{ action, params }` y responde `{ success, data, message }`
- **Base de Datos:** Tabla `cvecatdup` con campos `recaud`, `urbrus`, `cuenta`, `cvecatnva`

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getCveCatDupList", // o addCveCatDup, deleteCveCatDup
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## Acciones soportadas
- `getCveCatDupList`: Lista registros, puede filtrar por clave catastral
- `addCveCatDup`: Agrega un registro
- `deleteCveCatDup`: Elimina un registro

## Stored Procedures
- `sp_get_cvecatdup_list(p_cvecatnva)`
- `sp_add_cvecatdup(p_recaud, p_urbrus, p_cuenta, p_cvecatnva)`
- `sp_delete_cvecatdup(p_recaud, p_urbrus, p_cuenta, p_cvecatnva)`

## Seguridad
- Validación de parámetros en backend
- Respuestas de error claras
- El endpoint puede protegerse con middleware de autenticación si se requiere

## Frontend
- Página Vue.js independiente, sin tabs
- Tabla con acciones de agregar y eliminar
- Modal para agregar
- Mensajes de éxito/error
- Breadcrumb para navegación

## Integración
- El componente Vue.js se integra como una ruta independiente en el router
- El controlador Laravel debe estar registrado en `routes/api.php` con:
  ```php
  Route::post('/execute', [CveCatDupController::class, 'execute']);
  ```

## Pruebas
- Casos de uso y pruebas incluidas al final de este documento
