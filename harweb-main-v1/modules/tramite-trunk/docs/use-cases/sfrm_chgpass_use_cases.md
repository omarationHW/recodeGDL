# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de clave

**Descripción:** Un usuario desea cambiar su clave cumpliendo todas las reglas.

**Precondiciones:**
El usuario existe y conoce su clave actual.

**Pasos a seguir:**
1. Ingresa su usuario y clave actual.
2. Ingresa una nueva clave válida (diferente a la actual, contiene letras y números, 3 primeros caracteres distintos).
3. Confirma la nueva clave correctamente.
4. Envía el formulario.

**Resultado esperado:**
La clave es cambiada exitosamente. El usuario recibe mensaje de éxito.

**Datos de prueba:**
{ "username": "juan", "current_password": "abc123", "new_password": "xyz789", "confirm_password": "xyz789" }

---

## Caso de Uso 2: Intento de cambio con clave actual incorrecta

**Descripción:** El usuario intenta cambiar su clave pero ingresa mal la clave actual.

**Precondiciones:**
El usuario existe pero ingresa mal la clave actual.

**Pasos a seguir:**
1. Ingresa su usuario y una clave actual incorrecta.
2. Intenta validar la clave actual.

**Resultado esperado:**
El sistema rechaza la operación y muestra mensaje de error.

**Datos de prueba:**
{ "username": "juan", "current_password": "wrongpass" }

---

## Caso de Uso 3: Intento de nueva clave inválida (igual a la actual)

**Descripción:** El usuario intenta poner como nueva clave la misma que la actual.

**Precondiciones:**
El usuario existe y la clave actual es conocida.

**Pasos a seguir:**
1. Ingresa usuario y clave actual correcta.
2. Ingresa como nueva clave la misma que la actual.
3. Intenta validar la nueva clave.

**Resultado esperado:**
El sistema rechaza la nueva clave y muestra mensaje de error.

**Datos de prueba:**
{ "username": "juan", "current_password": "abc123", "new_password": "abc123" }

---

