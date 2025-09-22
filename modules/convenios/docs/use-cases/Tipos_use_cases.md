# Casos de Uso - Tipos

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo de Convenio

**Descripción:** El usuario desea agregar un nuevo tipo de convenio para ser utilizado en otros catálogos.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos de Convenio.
2. Hace clic en 'Agregar Tipo'.
3. Ingresa el número de tipo (ej: 10) y la descripción (ej: 'CONVENIO ESPECIAL').
4. Hace clic en 'Guardar'.
5. El sistema envía la petición al backend.
6. El backend ejecuta el SP de inserción.
7. El sistema muestra mensaje de éxito y actualiza la lista.

**Resultado esperado:**
El nuevo tipo aparece en la lista y puede ser usado en otros catálogos.

**Datos de prueba:**
{ "tipo": 10, "descripcion": "CONVENIO ESPECIAL" }

---

## Caso de Uso 2: Edición de un Tipo de Convenio existente

**Descripción:** El usuario necesita corregir la descripción de un tipo de convenio ya registrado.

**Precondiciones:**
Existe al menos un tipo de convenio registrado.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos.
2. Hace clic en 'Editar' sobre el tipo deseado.
3. Modifica la descripción.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición al backend.
6. El backend ejecuta el SP de actualización.
7. El sistema muestra mensaje de éxito y actualiza la lista.

**Resultado esperado:**
La descripción del tipo se actualiza correctamente.

**Datos de prueba:**
{ "tipo": 10, "descripcion": "CONVENIO MODIFICADO" }

---

## Caso de Uso 3: Eliminación de un Tipo de Convenio

**Descripción:** El usuario desea eliminar un tipo de convenio que ya no se utiliza.

**Precondiciones:**
El tipo de convenio no tiene dependencias en otras tablas.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos.
2. Hace clic en 'Eliminar' sobre el tipo deseado.
3. Confirma la eliminación.
4. El sistema envía la petición al backend.
5. El backend ejecuta el SP de borrado.
6. El sistema muestra mensaje de éxito y actualiza la lista.

**Resultado esperado:**
El tipo de convenio desaparece de la lista.

**Datos de prueba:**
{ "tipo": 10 }

---

