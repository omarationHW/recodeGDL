# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de clave

**Descripción:** El usuario ingresa correctamente su clave actual, una nueva clave válida y la confirmación coincide.

**Precondiciones:**
El usuario está autenticado y conoce su clave actual.

**Pasos a seguir:**
1. Ingresa la clave actual.
2. El sistema valida la clave.
3. Ingresa la nueva clave (diferente, válida).
4. Ingresa la confirmación igual a la nueva clave.
5. El sistema actualiza la clave.

**Resultado esperado:**
La clave se cambia exitosamente y el usuario recibe un mensaje de éxito.

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "xyz789", "confirm_password": "xyz789" }

---

## Caso de Uso 2: Intento con clave actual incorrecta

**Descripción:** El usuario ingresa una clave actual incorrecta.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Ingresa una clave actual incorrecta.
2. El sistema rechaza la validación.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la clave actual es incorrecta.

**Datos de prueba:**
{ "user_id": 1, "current_password": "wrongpass" }

---

## Caso de Uso 3: Nueva clave no cumple requisitos

**Descripción:** El usuario intenta poner una nueva clave que no contiene números o letras, o es igual a la actual.

**Precondiciones:**
El usuario está autenticado y la clave actual es válida.

**Pasos a seguir:**
1. Ingresa la clave actual correcta.
2. Ingresa una nueva clave inválida (por ejemplo, sólo letras, o igual a la actual).
3. El sistema rechaza la nueva clave.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando el motivo (debe contener números y letras, o no debe ser igual a la actual).

**Datos de prueba:**
{ "user_id": 1, "current_password": "abc123", "new_password": "abcdef", "confirm_password": "abcdef" }

---

