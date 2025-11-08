# Documentación Técnica: Migración Formulario Acceso (unAcceso) Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend:** Vue.js SPA (Single Page Application)
- **Backend:** Laravel API RESTful
- **Base de Datos:** PostgreSQL
- **Comunicación:** API unificada vía endpoint `/api/execute` usando patrón eRequest/eResponse
- **Autenticación:** Basada en stored procedure `sp_login_usuario` (puede extenderse a JWT)

## 2. Flujo de Autenticación
1. El usuario ingresa usuario y contraseña en el formulario Vue.js.
2. El componente Vue envía un POST a `/api/execute` con `{ eRequest: { action: 'login', params: { usuario, contrasena } } }`.
3. Laravel recibe la petición, ejecuta el stored procedure `sp_login_usuario`.
4. Si la autenticación es exitosa, retorna datos del usuario; si no, retorna error.
5. El frontend guarda el usuario en localStorage (simulando el registry de Windows) y redirige al menú principal.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "login",
      "params": {
        "usuario": "usuario",
        "contrasena": "password"
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "status": "ok|error",
      "message": "...",
      "data": { ... }
    }
  }
  ```

## 4. Stored Procedure de Autenticación
- **Nombre:** `sp_login_usuario`
- **Entradas:** `usuario`, `contrasena`
- **Salida:**
  - `autenticado` (boolean)
  - `usuario`, `nombre`, `nivel`, `id_usuario`
- **Notas:**
  - La contraseña debe estar almacenada con `crypt()` en PostgreSQL para seguridad.
  - Si el usuario existe y la contraseña es correcta, retorna los datos; si no, retorna autenticado=false.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Recupera el último usuario usado desde localStorage.
- Muestra mensajes de error y de conexión.
- Al login exitoso, redirige a la página principal.

## 6. Backend (Laravel)
- Controlador único `AccesoController` con método `execute`.
- Valida parámetros y ejecuta el stored procedure.
- Puede extenderse para manejar más acciones (logout, recuperación de usuario, etc).

## 7. Seguridad
- El SP nunca retorna la contraseña.
- Se recomienda implementar JWT para sesiones en producción.

## 8. Extensibilidad
- El endpoint `/api/execute` puede manejar otras acciones agregando más casos en el switch.
- El frontend puede extenderse para recordar más preferencias del usuario.

## 9. Consideraciones de Migración
- El registry de Windows se simula con localStorage en el navegador.
- El control de intentos fallidos puede implementarse en el frontend o backend según política.
- El diseño visual puede adaptarse a la identidad institucional.
