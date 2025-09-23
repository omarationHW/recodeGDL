# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de contraseña

**Descripción:** El usuario desea cambiar su contraseña por una nueva válida.

**Precondiciones:**
El usuario está autenticado y conoce su contraseña actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de contraseña.
2. Ingresa su contraseña actual, la nueva y la confirmación.
3. Presiona 'Cambiar Clave'.
4. El sistema valida y actualiza la contraseña.

**Resultado esperado:**
La contraseña se actualiza y el usuario recibe el mensaje 'Clave cambiada exitosamente'.

**Datos de prueba:**
{ "username": "jdoe", "current_password": "abc123", "new_password": "xyz789", "confirm_password": "xyz789" }

---

## Caso de Uso 2: Intento de cambio con clave nueva igual a la actual

**Descripción:** El usuario intenta poner la misma clave como nueva.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa la misma clave en 'actual' y 'nueva'.
2. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema rechaza el cambio y muestra 'La nueva clave no debe ser igual a la actual'.

**Datos de prueba:**
{ "username": "jdoe", "current_password": "abc123", "new_password": "abc123", "confirm_password": "abc123" }

---

## Caso de Uso 3: Intento de cambio con clave nueva inválida (sin números)

**Descripción:** El usuario intenta poner una clave nueva que no cumple las reglas.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa una clave nueva sólo con letras.
2. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema rechaza el cambio y muestra 'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres'.

**Datos de prueba:**
{ "username": "jdoe", "current_password": "abc123", "new_password": "abcdef", "confirm_password": "abcdef" }

---

