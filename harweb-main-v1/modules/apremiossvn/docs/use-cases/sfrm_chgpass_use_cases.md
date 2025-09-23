# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio de clave exitoso

**Descripción:** El usuario desea cambiar su clave de acceso cumpliendo todas las reglas de seguridad.

**Precondiciones:**
El usuario está autenticado y conoce su clave actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de clave.
2. Ingresa su clave actual: 'abc123'.
3. Ingresa nueva clave: 'xyz789'.
4. Ingresa confirmación: 'xyz789'.
5. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema muestra el mensaje 'Clave cambiada satisfactoriamente' y la clave es actualizada en la base de datos.

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "xyz789", "confirm_password": "xyz789" }

---

## Caso de Uso 2: Intento de cambio con clave nueva igual a la actual

**Descripción:** El usuario intenta cambiar su clave pero la nueva es igual a la actual.

**Precondiciones:**
El usuario está autenticado y conoce su clave actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de clave.
2. Ingresa su clave actual: 'abc123'.
3. Ingresa nueva clave: 'abc123'.
4. Ingresa confirmación: 'abc123'.
5. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema muestra el mensaje 'La clave nueva no debe ser igual a la actual' y no realiza el cambio.

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "abc123", "confirm_password": "abc123" }

---

## Caso de Uso 3: Intento de cambio con clave nueva inválida (sin números)

**Descripción:** El usuario intenta cambiar su clave pero la nueva no contiene números.

**Precondiciones:**
El usuario está autenticado y conoce su clave actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de clave.
2. Ingresa su clave actual: 'abc123'.
3. Ingresa nueva clave: 'abcdef'.
4. Ingresa confirmación: 'abcdef'.
5. Presiona 'Cambiar Clave'.

**Resultado esperado:**
El sistema muestra el mensaje 'La clave debe contener letras y números' y no realiza el cambio.

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "abcdef", "confirm_password": "abcdef" }

---

