# Casos de Uso - SeccionesMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva sección

**Descripción:** Un usuario desea agregar una nueva sección al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y la sección no existe.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Agregar'.
3. Ingresa 'seccion' = 'PS', 'descripcion' = 'PUESTOS'.
4. Presiona 'Aceptar'.

**Resultado esperado:**
La sección 'PS' se agrega y aparece en la lista. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "seccion": "PS", "descripcion": "PUESTOS" }

---

## Caso de Uso 2: Modificación de descripción de sección

**Descripción:** El usuario desea actualizar la descripción de una sección existente.

**Precondiciones:**
La sección 'PS' ya existe.

**Pasos a seguir:**
1. El usuario selecciona la sección 'PS' en la tabla.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'PUESTOS SECUNDARIOS'.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción de la sección 'PS' se actualiza. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "seccion": "PS", "descripcion": "PUESTOS SECUNDARIOS" }

---

## Caso de Uso 3: Intento de alta de sección duplicada

**Descripción:** El usuario intenta agregar una sección que ya existe.

**Precondiciones:**
La sección 'PS' ya existe.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Ingresa 'seccion' = 'PS', 'descripcion' = 'DUPLICADO'.
3. Presiona 'Agregar'.

**Resultado esperado:**
Se muestra mensaje de error indicando que la sección ya existe.

**Datos de prueba:**
{ "seccion": "PS", "descripcion": "DUPLICADO" }

---

