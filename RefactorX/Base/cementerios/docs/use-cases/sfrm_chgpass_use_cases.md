# Casos de Uso - sfrm_chgpass

**Categoría:** Form

## Caso de Uso 1: Cambio exitoso de clave de acceso

**Descripción:** Un usuario autenticado desea cambiar su clave de acceso cumpliendo todas las reglas de seguridad.

**Precondiciones:**
El usuario está autenticado y conoce su clave actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de clave.
2. Ingresa su clave actual y la valida.
3. Ingresa una nueva clave válida (mínimo 6 caracteres, letras y números, diferente a la actual y con los 3 primeros caracteres distintos).
4. Ingresa la confirmación igual a la nueva clave.
5. Envía el formulario.
6. El sistema valida y actualiza la clave.

**Resultado esperado:**
La clave es cambiada exitosamente. El usuario recibe un mensaje de éxito y es redirigido.

**Datos de prueba:**
{
  "current_password": "abc123",
  "new_password": "xyz789",
  "confirm_password": "xyz789"
}

---

## Caso de Uso 2: Intento de cambio con clave actual incorrecta

**Descripción:** El usuario intenta cambiar su clave pero ingresa una clave actual incorrecta.

**Precondiciones:**
El usuario está autenticado pero no recuerda bien su clave actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de clave.
2. Ingresa una clave actual incorrecta.
3. Intenta validar la clave actual.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la clave actual es incorrecta. No permite avanzar.

**Datos de prueba:**
{
  "current_password": "wrongpass"
}

---

## Caso de Uso 3: Intento de cambio con nueva clave inválida

**Descripción:** El usuario ingresa una nueva clave que no cumple las reglas de seguridad.

**Precondiciones:**
El usuario está autenticado y valida correctamente su clave actual.

**Pasos a seguir:**
1. El usuario accede a la página de cambio de clave.
2. Ingresa su clave actual correcta.
3. Ingresa una nueva clave inválida (por ejemplo, menos de 6 caracteres o sólo números).
4. Intenta avanzar.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando la regla que no se cumple (ejemplo: 'La clave debe ser mayor a 5 dígitos', 'La clave debe contener números y letras', etc).

**Datos de prueba:**
{
  "current_password": "abc123",
  "new_password": "12345",
  "confirm_password": "12345"
}

---

