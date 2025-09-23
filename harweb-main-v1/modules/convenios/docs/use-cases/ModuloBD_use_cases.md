# Casos de Uso - ModuloBD

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Tipo

**Descripción:** El usuario desea agregar un nuevo registro al catálogo de Tipos.

**Precondiciones:**
El usuario tiene permisos de acceso y la sesión está activa.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos.
2. Da clic en 'Agregar Tipo'.
3. Ingresa la descripción 'Tipo de Prueba'.
4. Da clic en 'Guardar'.
5. El sistema envía la petición al backend y recibe confirmación.

**Resultado esperado:**
El nuevo tipo aparece en la lista con la descripción ingresada.

**Datos de prueba:**
{ descripcion: 'Tipo de Prueba' }

---

## Caso de Uso 2: Edición de un Tipo existente

**Descripción:** El usuario edita la descripción de un tipo ya existente.

**Precondiciones:**
Existe al menos un tipo en el catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos.
2. Da clic en 'Editar' sobre el tipo con ID 1.
3. Cambia la descripción a 'Tipo Editado'.
4. Da clic en 'Actualizar'.

**Resultado esperado:**
La descripción del tipo con ID 1 se actualiza correctamente.

**Datos de prueba:**
{ tipo: 1, descripcion: 'Tipo Editado' }

---

## Caso de Uso 3: Eliminación de un Tipo

**Descripción:** El usuario elimina un tipo del catálogo.

**Precondiciones:**
Existe al menos un tipo en el catálogo.

**Pasos a seguir:**
1. El usuario accede a la página de Tipos.
2. Da clic en 'Eliminar' sobre el tipo con ID 2.
3. Confirma la eliminación.

**Resultado esperado:**
El tipo con ID 2 ya no aparece en la lista.

**Datos de prueba:**
{ tipo: 2 }

---

