# Casos de Uso - unAcceso

**Categoría:** Form

## Caso de Uso 1: Inicio de sesión exitoso

**Descripción:** Un usuario válido ingresa sus credenciales y accede al sistema.

**Precondiciones:**
El usuario y contraseña existen en la tabla usuarios y la contraseña está correctamente cifrada.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario y contraseña válidos.
3. Presiona 'Aceptar'.
4. El sistema valida y muestra el menú principal.

**Resultado esperado:**
El usuario es autenticado y redirigido al menú principal. El usuario queda guardado en localStorage.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "admin123" }

---

## Caso de Uso 2: Intento de acceso con contraseña incorrecta

**Descripción:** Un usuario existente ingresa una contraseña incorrecta.

**Precondiciones:**
El usuario existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario válido y contraseña incorrecta.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra mensaje de error 'Usuario y/o contraseña incorrectos'.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "wrongpass" }

---

## Caso de Uso 3: Recuperación de usuario desde localStorage

**Descripción:** El sistema recuerda el último usuario usado.

**Precondiciones:**
El usuario ha iniciado sesión previamente y su usuario está en localStorage.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. El campo usuario se autocompleta con el último usuario usado.

**Resultado esperado:**
El campo usuario muestra el valor guardado en localStorage.

**Datos de prueba:**
{ "usuarioSistema": "admin" }

---

