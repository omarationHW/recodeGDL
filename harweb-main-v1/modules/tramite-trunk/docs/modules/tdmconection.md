# Documentación Técnica: Migración de Formulario tdmconection (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la migración del formulario de conexión y autenticación de usuario desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Se centraliza la autenticación y gestión de usuario en un endpoint API único siguiendo el patrón eRequest/eResponse.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, componente de página independiente para login.
- **Base de Datos:** PostgreSQL, procedimientos almacenados para lógica de autenticación.
- **Sesión:** Laravel Session (puede usarse Redis/Cache para persistencia de último usuario).

## 3. Flujo de Autenticación
1. El usuario accede a la página de login (Vue.js).
2. El frontend consulta el último usuario autenticado (`eRequest: get_last_user`).
3. El usuario ingresa credenciales y envía el formulario.
4. El frontend llama a `/api/execute` con `eRequest: login` y las credenciales.
5. El backend ejecuta el stored procedure `sp_login` en PostgreSQL.
6. Si la autenticación es exitosa, se almacena la sesión y se actualiza el último usuario (`eRequest: set_last_user`).
7. El usuario es redirigido a la página principal.

## 4. Endpoint API Unificado
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "login|get_last_user|set_last_user|logout",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 5. Stored Procedure: sp_login
- **Entradas:**
  - `p_username` (TEXT)
  - `p_password` (TEXT)
- **Salida:**
  - `success` (BOOLEAN)
  - `username` (TEXT)
  - `fullname` (TEXT)
- **Descripción:** Valida usuario y contraseña. Retorna TRUE y datos del usuario si es correcto, FALSE en caso contrario.

## 6. Manejo de Último Usuario
- Se almacena en cache (Redis, archivo, o base de datos) el último usuario autenticado para prellenar el campo de usuario en el login.

## 7. Seguridad
- El procedimiento de login debe usar hash seguro de contraseñas (ejemplo usa texto plano por simplicidad, reemplazar en producción).
- El endpoint API valida y limita intentos de login por sesión.

## 8. Migración de Lógica Delphi
- **Registro de Windows:** Se reemplaza por almacenamiento en cache/archivo/base de datos.
- **Manejo de intentos:** Se maneja por sesión Laravel.
- **Formularios:** Cada formulario Delphi es una página Vue.js independiente.

## 9. Extensibilidad
- El endpoint `/api/execute` puede extenderse para otros formularios y operaciones usando el patrón eRequest/eResponse.

## 10. Dependencias
- Laravel 10+, PHP 8+
- Vue.js 2/3
- PostgreSQL 12+

