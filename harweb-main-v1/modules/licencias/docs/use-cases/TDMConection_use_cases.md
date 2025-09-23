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

