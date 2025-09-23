# Documentación Técnica: Migración TDMConection Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de conexión a base de datos originalmente desarrollada en Delphi (TDMConection) usando Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El flujo permite:
- Autenticación de usuario y contraseña contra la base de datos.
- Listado de bases de datos disponibles.
- Cierre de sesión/conexión (simulado, ya que la API es stateless).

## 2. Arquitectura
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs.
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** Stored Procedures en PostgreSQL para lógica de conexión y catálogo.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": "test_connection|get_databases|close_connection",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": { ... },
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures
- **sp_test_connection(user, password):** Verifica credenciales usando dblink (requiere extensión dblink).
- **sp_get_databases():** Devuelve lista de bases de datos.

## 5. Seguridad
- El procedimiento `sp_test_connection` debe ejecutarse con permisos de superusuario o con la extensión dblink instalada.
- Las credenciales no se almacenan, sólo se usan para autenticación en tiempo real.

## 6. Flujo de Usuario
1. El usuario ingresa usuario y contraseña.
2. El frontend llama a `/api/execute` con `eRequest: 'test_connection'`.
3. Si la conexión es exitosa, se muestra el mensaje y se listan las bases de datos.
4. El usuario puede cerrar la conexión (limpia el estado en frontend).

## 7. Consideraciones
- El cierre de conexión es simulado, ya que la API es stateless.
- Para ambientes productivos, se recomienda usar roles limitados y no exponer usuarios con privilegios elevados.

## 8. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+
- Extensión dblink de PostgreSQL

## 9. Instalación de dblink
```sql
CREATE EXTENSION IF NOT EXISTS dblink;
```

## 10. Rutas Laravel
Agregar en `routes/api.php`:
```php
Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
```
