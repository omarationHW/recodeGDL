# Casos de Uso - sfrm_aspecto

**Categoría:** Form

## Caso de Uso 1: Cambio de aspecto visual por el usuario

**Descripción:** El usuario desea cambiar el aspecto visual de la aplicación a un tema diferente.

**Precondiciones:**
El usuario está autenticado y tiene acceso a la página de configuración de aspecto.

**Pasos a seguir:**
1. El usuario navega a la página 'Cambiar Aspecto'.
2. El sistema muestra la lista de aspectos disponibles.
3. El usuario selecciona 'SkinDark' en el combo.
4. El usuario confirma el cambio (evento onChange).
5. El sistema envía la petición al backend.
6. El backend ejecuta el stored procedure para cambiar el aspecto.
7. El frontend muestra mensaje de éxito y actualiza el aspecto actual.

**Resultado esperado:**
El aspecto visual de la aplicación cambia a 'SkinDark' y se muestra un mensaje de confirmación.

**Datos de prueba:**
{ "aspecto": "SkinDark" }

---

## Caso de Uso 2: Visualización del aspecto actual

**Descripción:** El usuario quiere saber cuál es el aspecto visual actualmente seleccionado.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de aspecto.
2. El sistema consulta el aspecto actual vía API.
3. El frontend muestra el nombre del aspecto actual.

**Resultado esperado:**
El usuario ve el nombre del aspecto actual (por ejemplo, 'SkinBlue').

**Datos de prueba:**
{}

---

## Caso de Uso 3: Intento de cambio de aspecto con valor inválido

**Descripción:** El usuario intenta cambiar el aspecto a un valor que no existe.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario manipula el frontend para enviar un aspecto inexistente ('SkinAlien').
2. El sistema recibe la petición y valida el valor.
3. El backend responde con error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el aspecto no es válido.

**Datos de prueba:**
{ "aspecto": "SkinAlien" }

---

