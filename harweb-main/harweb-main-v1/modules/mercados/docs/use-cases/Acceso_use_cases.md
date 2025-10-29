# Casos de Uso - Acceso

**Categoría:** Form

## Caso de Uso 1: Acceso exitoso al sistema

**Descripción:** Un usuario válido ingresa sus credenciales y accede correctamente al sistema.

**Precondiciones:**
El usuario existe en la tabla ta_12_passwords, está activo y conoce su contraseña.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario, contraseña y ejercicio.
3. Presiona 'Aceptar'.
4. El sistema valida y permite el acceso.

**Resultado esperado:**
El usuario es autenticado y redirigido al menú principal.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "1234", "ejercicio": 2024 }

---

## Caso de Uso 2: Acceso fallido por contraseña incorrecta

**Descripción:** Un usuario ingresa una contraseña incorrecta y el sistema rechaza el acceso.

**Precondiciones:**
El usuario existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario válido y contraseña incorrecta.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error y no permite el acceso.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "erronea", "ejercicio": 2024 }

---

## Caso de Uso 3: Bloqueo tras 3 intentos fallidos

**Descripción:** Un usuario intenta acceder 3 veces con datos incorrectos y el sistema bloquea el acceso.

**Precondiciones:**
El usuario no conoce la contraseña.

**Pasos a seguir:**
1. El usuario intenta acceder 3 veces con datos incorrectos.
2. En cada intento, el sistema muestra error.
3. Tras el tercer intento, el sistema bloquea el acceso.

**Resultado esperado:**
El sistema muestra un mensaje de bloqueo y no permite más intentos.

**Datos de prueba:**
{ "usuario": "admin", "contrasena": "erronea", "ejercicio": 2024 } (repetir 3 veces)

---

