# Casos de Uso - ImpresionNva

**Categoría:** Form

## Caso de Uso 1: Carga de la página de Impresión Nueva

**Descripción:** El usuario accede a la página de Impresión Nueva y el sistema inicializa el formulario.

**Precondiciones:**
El usuario tiene acceso a la aplicación y está autenticado.

**Pasos a seguir:**
1. El usuario navega a la ruta '/impresion-nva'.
2. El componente Vue solicita los datos iniciales vía API (acción 'getFormData').
3. El backend responde con éxito.

**Resultado esperado:**
La página se muestra correctamente, sin campos, y lista para enviar.

**Datos de prueba:**
No aplica (no hay campos).

---

## Caso de Uso 2: Envío exitoso del formulario

**Descripción:** El usuario presiona el botón 'Enviar' en la página de Impresión Nueva.

**Precondiciones:**
La página de Impresión Nueva está cargada.

**Pasos a seguir:**
1. El usuario presiona 'Enviar'.
2. El componente Vue envía la acción 'submitForm' vía API.
3. El backend responde con éxito y mensaje de confirmación.

**Resultado esperado:**
Se muestra un mensaje de éxito: 'Formulario enviado correctamente.'

**Datos de prueba:**
No aplica (no hay campos).

---

## Caso de Uso 3: Error al acceder a una acción no soportada

**Descripción:** El frontend envía una acción no reconocida al endpoint.

**Precondiciones:**
El usuario está en la página de Impresión Nueva.

**Pasos a seguir:**
1. El frontend envía una acción inválida (por ejemplo, 'invalidAction') a la API.
2. El backend responde con un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje de error: 'Acción no soportada.'

**Datos de prueba:**
{ action: 'invalidAction', params: {} }

---

