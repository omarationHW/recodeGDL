# Casos de Uso - Acceso

**Categoría:** Form

## Caso de Uso 1: Acceso exitoso al sistema

**Descripción:** Un usuario válido ingresa sus credenciales y accede correctamente al sistema.

**Precondiciones:**
El usuario existe en la tabla ta_12_passwords, está activo (estado='A') y la contraseña es correcta.

**Pasos a seguir:**
1. El usuario abre la página de login.
2. Ingresa su usuario y contraseña.
3. Presiona 'Aceptar'.
4. El sistema valida los datos y responde éxito.

**Resultado esperado:**
El usuario es autenticado, recibe un token y es redirigido a la página principal.

**Datos de prueba:**
{ "username": "admin", "password": "admin123" }

---

## Caso de Uso 2: Acceso fallido por contraseña incorrecta

**Descripción:** Un usuario válido ingresa una contraseña incorrecta.

**Precondiciones:**
El usuario existe, pero la contraseña no coincide.

**Pasos a seguir:**
1. El usuario abre la página de login.
2. Ingresa su usuario y una contraseña incorrecta.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario y/o contraseña incorrectos'.

**Datos de prueba:**
{ "username": "admin", "password": "wrongpass" }

---

## Caso de Uso 3: Acceso fallido por usuario inactivo

**Descripción:** Un usuario inactivo intenta acceder.

**Precondiciones:**
El usuario existe pero tiene estado='I'.

**Pasos a seguir:**
1. El usuario abre la página de login.
2. Ingresa su usuario y contraseña correctos.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario y/o contraseña incorrectos'.

**Datos de prueba:**
{ "username": "inactivo", "password": "inactivo123" }

---

