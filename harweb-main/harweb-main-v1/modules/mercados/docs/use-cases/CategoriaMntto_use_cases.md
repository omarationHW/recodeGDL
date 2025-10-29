# Casos de Uso - CategoriaMntto

**Categoría:** Form

## Caso de Uso 1: Alta de nueva categoría

**Descripción:** El usuario desea agregar una nueva categoría de mercado.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos de administrador.

**Pasos a seguir:**
1. Ingresa a la página de Mantenimiento de Categorías.
2. Completa el campo 'Categoría' con el valor 5.
3. Completa el campo 'Descripción' con 'ALIMENTOS'.
4. Presiona el botón 'Agregar'.

**Resultado esperado:**
La categoría 5 con descripción 'ALIMENTOS' se agrega a la lista y aparece en la tabla.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS" }

---

## Caso de Uso 2: Modificación de descripción de categoría existente

**Descripción:** El usuario desea modificar la descripción de una categoría existente.

**Precondiciones:**
La categoría 5 ya existe en la base de datos.

**Pasos a seguir:**
1. En la tabla, ubica la fila de la categoría 5.
2. Haz clic en 'Editar'.
3. Cambia la descripción a 'ALIMENTOS Y BEBIDAS'.
4. Presiona 'Actualizar'.

**Resultado esperado:**
La descripción de la categoría 5 se actualiza a 'ALIMENTOS Y BEBIDAS'.

**Datos de prueba:**
{ "categoria": 5, "descripcion": "ALIMENTOS Y BEBIDAS" }

---

## Caso de Uso 3: Eliminación de una categoría

**Descripción:** El usuario desea eliminar una categoría que no tiene dependencias.

**Precondiciones:**
La categoría 12 existe y no está referenciada por otras tablas.

**Pasos a seguir:**
1. En la tabla, ubica la fila de la categoría 12.
2. Haz clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
La categoría 12 es eliminada de la base de datos y desaparece de la tabla.

**Datos de prueba:**
{ "categoria": 12 }

---

