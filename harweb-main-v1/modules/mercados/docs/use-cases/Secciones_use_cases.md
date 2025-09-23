# Casos de Uso - Secciones

**Categoría:** Form

## Caso de Uso 1: Alta de una nueva sección

**Descripción:** El usuario desea agregar una nueva sección al catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador. No existe una sección con la clave 'B2'.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Agregar Sección'.
3. Ingresa 'B2' como clave y 'Zona Sur' como descripción.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La sección 'B2' se agrega correctamente y aparece en la lista.

**Datos de prueba:**
{ "seccion": "B2", "descripcion": "Zona Sur" }

---

## Caso de Uso 2: Edición de una sección existente

**Descripción:** El usuario desea modificar la descripción de la sección 'A1'.

**Precondiciones:**
La sección 'A1' existe en el catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Editar' junto a la sección 'A1'.
3. Cambia la descripción a 'Zona Norte Actualizada'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
La descripción de la sección 'A1' se actualiza correctamente.

**Datos de prueba:**
{ "seccion": "A1", "descripcion": "Zona Norte Actualizada" }

---

## Caso de Uso 3: Eliminación de una sección

**Descripción:** El usuario desea eliminar la sección 'B2'.

**Precondiciones:**
La sección 'B2' existe en el catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Secciones.
2. Hace clic en 'Eliminar' junto a la sección 'B2'.
3. Confirma la eliminación.

**Resultado esperado:**
La sección 'B2' se elimina correctamente y ya no aparece en la lista.

**Datos de prueba:**
{ "seccion": "B2" }

---

