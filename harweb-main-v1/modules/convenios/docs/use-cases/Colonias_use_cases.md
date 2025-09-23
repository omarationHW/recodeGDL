# Casos de Uso - Colonias

**Categoría:** Form

## Caso de Uso 1: Alta de nueva colonia

**Descripción:** Un usuario administrativo desea agregar una nueva colonia al catálogo.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de alta.

**Pasos a seguir:**
1. El usuario accede a la página de Colonias.
2. Hace clic en 'Agregar Colonia'.
3. Llena el formulario con los datos requeridos.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la petición a /api/execute con acción 'colonias.create'.
6. El backend ejecuta el SP y retorna el resultado.

**Resultado esperado:**
La colonia se agrega correctamente y aparece en la tabla.

**Datos de prueba:**
{
  "colonia": 123,
  "descripcion": "Colonia Jardines",
  "id_rec": 2,
  "id_zona": 5,
  "col_obra94": 1,
  "id_usuario": 1
}

---

## Caso de Uso 2: Edición de colonia existente

**Descripción:** Un usuario desea modificar la descripción y zona de una colonia existente.

**Precondiciones:**
La colonia debe existir. El usuario debe tener permisos de edición.

**Pasos a seguir:**
1. El usuario localiza la colonia en la tabla.
2. Hace clic en 'Editar'.
3. Modifica la descripción y zona.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con acción 'colonias.update'.

**Resultado esperado:**
La colonia se actualiza y los cambios se reflejan en la tabla.

**Datos de prueba:**
{
  "colonia": 123,
  "descripcion": "Colonia Jardines del Sur",
  "id_rec": 2,
  "id_zona": 7,
  "col_obra94": 1,
  "id_usuario": 1
}

---

## Caso de Uso 3: Eliminación de colonia

**Descripción:** Un usuario desea eliminar una colonia que ya no es válida.

**Precondiciones:**
La colonia debe existir y no estar referenciada en otras tablas.

**Pasos a seguir:**
1. El usuario localiza la colonia en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.
4. El sistema envía la petición a /api/execute con acción 'colonias.delete'.

**Resultado esperado:**
La colonia se elimina y desaparece de la tabla.

**Datos de prueba:**
{
  "colonia": 123
}

---

