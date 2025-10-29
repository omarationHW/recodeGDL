# Casos de Uso - Categoria

**Categoría:** Form

## Caso de Uso 1: Alta de nueva categoría

**Descripción:** Un usuario administrador desea agregar una nueva categoría de locales.

**Precondiciones:**
El usuario está autenticado y tiene permisos de administrador.

**Pasos a seguir:**
1. El usuario accede a la página de categorías.
2. Hace clic en 'Agregar Categoría'.
3. Ingresa el número de categoría (ej: 5) y la descripción (ej: 'ALIMENTOS').
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'categoria.create'.

**Resultado esperado:**
La categoría se agrega correctamente y aparece en el listado.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS" }

---

## Caso de Uso 2: Edición de una categoría existente

**Descripción:** Un usuario desea modificar la descripción de una categoría existente.

**Precondiciones:**
Existe la categoría 5 en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de categorías.
2. Hace clic en 'Editar' sobre la categoría 5.
3. Cambia la descripción a 'ALIMENTOS Y BEBIDAS'.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'categoria.update'.

**Resultado esperado:**
La descripción de la categoría se actualiza correctamente.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS Y BEBIDAS" }

---

## Caso de Uso 3: Eliminación de una categoría

**Descripción:** Un usuario desea eliminar una categoría que ya no se utiliza.

**Precondiciones:**
Existe la categoría 5 en la base de datos y no está referenciada por otras tablas.

**Pasos a seguir:**
1. El usuario accede a la página de categorías.
2. Hace clic en 'Eliminar' sobre la categoría 5.
3. Confirma la eliminación.
4. El sistema envía la petición a /api/execute con action 'categoria.delete'.

**Resultado esperado:**
La categoría se elimina correctamente del sistema.

**Datos de prueba:**
{ "categoria": 5 }

---

