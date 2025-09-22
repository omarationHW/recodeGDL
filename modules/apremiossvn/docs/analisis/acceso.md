# Documentación Técnica: Migración Formulario Acceso (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Backend**: Laravel API RESTful, endpoint único `/api/execute` que recibe eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio SQL se implementa en stored procedures.

## 2. Flujo de Autenticación
1. El usuario accede a la página de acceso (`/acceso`).
2. Ingresa usuario, contraseña y ejercicio.
3. Al hacer submit, el componente Vue envía un POST a `/api/execute` con:
   ```json
   {
     "eRequest": {
       "action": "login",
       "params": {
         "usuario": "...",
         "clave": "...",
         "ejercicio": 2024
       }
     }
   }
   ```
4. El backend Laravel recibe la petición, despacha al método correspondiente del controlador.
5. El controlador llama al stored procedure `sp_acceso_login`.
6. Si el login es exitoso, retorna los datos del usuario y un success=true.
7. El frontend guarda el usuario en localStorage y redirige al menú principal.

## 3. Endpoint Unificado `/api/execute`
- Todas las acciones del formulario de acceso se resuelven por este endpoint.
- El campo `eRequest.action` determina la operación (`login`, `logout`, `getUser`, `setUserRegistry`).
- El campo `eRequest.params` contiene los parámetros necesarios.
- La respuesta siempre es `{ "eResponse": { ... } }`.

## 4. Stored Procedures
- Toda la lógica de validación de usuario y registro se implementa en SPs.
- El SP `sp_acceso_login` valida usuario y contraseña usando `crypt()` de PostgreSQL.
- El SP `sp_acceso_get_user` retorna los datos del usuario.
- El SP `sp_acceso_set_user_registry` simula el registro local (en web, tabla de preferencias).

## 5. Seguridad
- Las contraseñas deben almacenarse usando `crypt()` o `bcrypt` en PostgreSQL.
- El endpoint `/api/execute` debe protegerse contra ataques de fuerza bruta (rate limiting).
- No se retorna nunca la contraseña ni hashes al frontend.

## 6. Manejo de Sesión
- El login exitoso puede retornar un JWT o token de sesión (no implementado aquí, pero recomendado).
- El logout simplemente limpia el estado en frontend.

## 7. Validaciones
- El controlador valida que usuario, clave y ejercicio sean enviados y correctos.
- El ejercicio debe estar entre 2001 y el año actual.

## 8. Migración de Registro de Usuario
- En Delphi se usaba el registro de Windows para recordar el usuario.
- En web, se usa localStorage (frontend) y/o una tabla `user_registry` (backend) para simular este comportamiento.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para validar el flujo completo.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la API.
- Los stored procedures pueden extenderse para más lógica de negocio.
