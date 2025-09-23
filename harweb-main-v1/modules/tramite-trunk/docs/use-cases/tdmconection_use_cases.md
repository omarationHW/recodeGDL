# Casos de Uso - tdmconection

**Categoría:** Form

## Caso de Uso 1: Login exitoso de usuario

**Descripción:** Un usuario registrado ingresa sus credenciales correctas y accede al sistema.

**Precondiciones:**
El usuario existe en la tabla 'users' y la contraseña es correcta.

**Pasos a seguir:**
1. El usuario accede a la página de login.
2. El sistema muestra el último usuario autenticado (si existe).
3. El usuario ingresa su nombre de usuario y contraseña correctos.
4. El usuario presiona 'Ingresar'.
5. El sistema valida las credenciales y permite el acceso.

**Resultado esperado:**
El usuario es autenticado exitosamente, se muestra mensaje de bienvenida y es redirigido a la página principal.

**Datos de prueba:**
{ "username": "jdoe", "password": "123456" }

---

## Caso de Uso 2: Login fallido por contraseña incorrecta

**Descripción:** Un usuario intenta ingresar con una contraseña incorrecta.

**Precondiciones:**
El usuario existe en la tabla 'users', pero la contraseña ingresada es incorrecta.

**Pasos a seguir:**
1. El usuario accede a la página de login.
2. Ingresa su nombre de usuario y una contraseña incorrecta.
3. Presiona 'Ingresar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando credenciales inválidas y no permite el acceso.

**Datos de prueba:**
{ "username": "jdoe", "password": "wrongpass" }

---

## Caso de Uso 3: Visualización del último usuario autenticado

**Descripción:** Al cargar la página de login, el sistema muestra el último usuario que ingresó exitosamente.

**Precondiciones:**
Al menos un usuario ha iniciado sesión previamente.

**Pasos a seguir:**
1. El usuario accede a la página de login.
2. El sistema consulta el último usuario autenticado.
3. El campo de usuario se prellena con ese valor.

**Resultado esperado:**
El campo de usuario muestra el último usuario autenticado.

**Datos de prueba:**
N/A (solo requiere que haya un usuario almacenado como último usuario)

---

