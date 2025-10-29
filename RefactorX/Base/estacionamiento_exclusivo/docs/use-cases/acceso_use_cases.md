# Casos de Uso - acceso

**Categoría:** Form

## Caso de Uso 1: Inicio de sesión exitoso

**Descripción:** El usuario ingresa sus credenciales correctas y accede al sistema.

**Precondiciones:**
El usuario existe en la base de datos y la contraseña es correcta.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario: 'juan', contraseña: 'abc123', ejercicio: 2024.
3. Presiona 'Aceptar'.
4. El sistema valida y permite el acceso.

**Resultado esperado:**
El usuario es autenticado, se muestra el menú principal.

**Datos de prueba:**
{ "usuario": "juan", "clave": "abc123", "ejercicio": 2024 }

---

## Caso de Uso 2: Intento de acceso con contraseña incorrecta

**Descripción:** El usuario ingresa una contraseña incorrecta.

**Precondiciones:**
El usuario existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario: 'juan', contraseña: 'mala', ejercicio: 2024.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Usuario o contraseña incorrectos'.

**Datos de prueba:**
{ "usuario": "juan", "clave": "mala", "ejercicio": 2024 }

---

## Caso de Uso 3: Validación de ejercicio fuera de rango

**Descripción:** El usuario intenta iniciar sesión con un ejercicio menor a 2001.

**Precondiciones:**
El usuario existe.

**Pasos a seguir:**
1. El usuario abre la página de acceso.
2. Ingresa usuario: 'juan', contraseña: 'abc123', ejercicio: 1999.
3. Presiona 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'El ejercicio debe estar entre 2001 y 2024'.

**Datos de prueba:**
{ "usuario": "juan", "clave": "abc123", "ejercicio": 1999 }

---

