# Casos de Uso - observacionfrm

**Categoría:** Form

## Caso de Uso 1: Registrar una nueva observación

**Descripción:** El usuario ingresa una observación en el formulario y la guarda.

**Precondiciones:**
El usuario tiene acceso a la página de observaciones.

**Pasos a seguir:**
1. El usuario accede a la página de Observaciones.
2. Escribe el texto 'Revisión de inventario completada.' en el campo de observación.
3. Presiona el botón 'Aceptar'.

**Resultado esperado:**
La observación se guarda en la base de datos, el campo se limpia y aparece un mensaje de éxito. La observación aparece en la lista inferior.

**Datos de prueba:**
Revisión de inventario completada.

---

## Caso de Uso 2: Visualizar historial de observaciones

**Descripción:** El usuario consulta el historial de observaciones guardadas.

**Precondiciones:**
Existen observaciones previamente guardadas en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Observaciones.
2. Observa la lista de observaciones en la parte inferior de la página.

**Resultado esperado:**
Se muestra una lista con todas las observaciones guardadas, ordenadas de la más reciente a la más antigua.

**Datos de prueba:**
N/A

---

## Caso de Uso 3: Validación de campo obligatorio

**Descripción:** El usuario intenta guardar una observación vacía.

**Precondiciones:**
El usuario está en la página de Observaciones.

**Pasos a seguir:**
1. El usuario deja el campo de observación vacío.
2. Presiona el botón 'Aceptar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el campo es obligatorio y no guarda la observación.

**Datos de prueba:**


---

