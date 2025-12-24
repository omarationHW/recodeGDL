# Documentación Técnica: TDMConection

## Análisis Técnico

# Documentación Técnica: Migración TDMConection Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de datos:** PostgreSQL 14+, toda la lógica SQL encapsulada en stored procedures/functions
- **Autenticación:** Token simple (puede migrarse a JWT), sesión en caché
- **Bitácora:** Uso de tabla `bitacora_lic_login` para registrar inicio y fin de sesión

## Flujo de Autenticación y Bitácora
1. **Login:**
   - El usuario ingresa usuario y contraseña.
   - Se valida contra la tabla `usuarios`.
   - Si es correcto, se ejecuta `fn_bitacora_lic_login` para registrar el inicio de sesión y se obtiene el `id_bitacora`.
   - Se genera un token de sesión y se guarda en caché junto con el id de bitácora.
2. **Logout:**
   - Se ejecuta `sp_bitacora_lic_logout` con el `id_bitacora` y la fecha/hora de fin.
   - Se elimina el token de la caché.

## API Unificada `/api/execute`
- Todas las acciones se envían como un JSON con los campos `action` y `params`.
- El controlador Laravel resuelve la acción y ejecuta la lógica correspondiente, llamando a los stored procedures si aplica.
- Ejemplo de request:
```json
{
  "action": "login",
  "params": {
    "username": "usuario",
    "password": "clave"
  }
}
```

## Vue.js
- Cada formulario es una página Vue independiente.
- El componente de conexión muestra login, información de usuario, bitácora y permite cerrar sesión.
- No se usan tabs ni componentes tabulares.
- Navegación por rutas (vue-router).

## Stored Procedures
- Toda la lógica de bitácora y usuario está en SPs/funciones PostgreSQL.
- Se recomienda encapsular toda lógica de negocio en SPs para facilitar mantenimiento y auditoría.

## Seguridad
- Contraseñas hasheadas (bcrypt o similar).
- Validación de parámetros en backend y frontend.
- Uso de tokens para sesión.

## Manejo de Errores
- Todas las respuestas siguen el patrón `{ success, message, data }`.
- Errores de validación y de base de datos se reportan en el campo `message`.

## Extensibilidad
- El endpoint `/api/execute` puede crecer para soportar más acciones (CRUD, reportes, procesos, etc).
- Los SPs pueden ampliarse para lógica de negocio adicional.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.


## Casos de Prueba


## Casos de Uso

# Casos de Uso - TDMConection

**Categoría:** Form

## Caso de Uso 1: Inicio de sesión y registro en bitácora

**Descripción:** Un usuario accede al sistema, se valida y se registra su inicio de sesión en la bitácora.

**Precondiciones:**
El usuario existe en la tabla `usuarios` y su contraseña es correcta.

**Pasos a seguir:**
1. El usuario ingresa usuario y contraseña en el formulario.
2. El frontend envía la petición a `/api/execute` con acción `login`.
3. El backend valida credenciales y ejecuta `fn_bitacora_lic_login`.
4. Se retorna token, datos de usuario y id de bitácora.

**Resultado esperado:**
El usuario ve su información, el id de bitácora y puede navegar en el sistema.

**Datos de prueba:**
{ "username": "admin", "password": "123456" }

---

## Caso de Uso 2: Cierre de sesión y registro de fin en bitácora

**Descripción:** El usuario cierra sesión y se registra la fecha/hora de fin en la bitácora.

**Precondiciones:**
El usuario está autenticado y tiene un token de sesión válido.

**Pasos a seguir:**
1. El usuario pulsa 'Cerrar sesión'.
2. El frontend envía a `/api/execute` la acción `logout` con el token.
3. El backend ejecuta `sp_bitacora_lic_logout` con el id de bitácora de la sesión.
4. El token se elimina de la caché.

**Resultado esperado:**
El usuario es desconectado y la bitácora tiene fecha de fin.

**Datos de prueba:**
{ "token": "abcdef123456" }

---

## Caso de Uso 3: Consulta de información de usuario

**Descripción:** Se consulta la información de un usuario por nombre.

**Precondiciones:**
El usuario existe en la base de datos.

**Pasos a seguir:**
1. Se envía a `/api/execute` la acción `get_user_info` con el nombre de usuario.
2. El backend ejecuta el SP correspondiente y retorna los datos.

**Resultado esperado:**
Se obtiene el registro completo del usuario.

**Datos de prueba:**
{ "username": "admin" }

---


