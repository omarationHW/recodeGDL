# Casos de Uso - sfrm_deudagrupo

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo grupo de deuda

**Descripción:** El usuario desea registrar un nuevo grupo de deuda en el sistema.

**Precondiciones:**
El usuario tiene acceso a la página de Deuda Grupo.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo Grupo'.
2. Completa el campo 'Nombre' y opcionalmente 'Descripción'.
3. Hace clic en 'Guardar'.

**Resultado esperado:**
El grupo es creado y aparece en la lista. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "nombre": "Grupo Prueba", "descripcion": "Grupo de prueba funcional" }

---

## Caso de Uso 2: Edición de un grupo de deuda existente

**Descripción:** El usuario necesita modificar el nombre y descripción de un grupo de deuda ya registrado.

**Precondiciones:**
Existe al menos un grupo de deuda en la base de datos.

**Pasos a seguir:**
1. El usuario localiza el grupo en la tabla y hace clic en 'Editar'.
2. Modifica los campos 'Nombre' y/o 'Descripción'.
3. Hace clic en 'Actualizar'.

**Resultado esperado:**
El grupo es actualizado y los cambios se reflejan en la lista. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "id": 1, "nombre": "Grupo Editado", "descripcion": "Descripción actualizada" }

---

## Caso de Uso 3: Eliminación de un grupo de deuda

**Descripción:** El usuario desea eliminar un grupo de deuda que ya no es necesario.

**Precondiciones:**
Existe al menos un grupo de deuda en la base de datos.

**Pasos a seguir:**
1. El usuario localiza el grupo en la tabla y hace clic en 'Eliminar'.
2. Confirma la eliminación en el cuadro de diálogo.

**Resultado esperado:**
El grupo es eliminado de la base de datos y desaparece de la lista. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "id": 1 }

---

