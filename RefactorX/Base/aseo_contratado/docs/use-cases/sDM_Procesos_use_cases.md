# Casos de Uso - sDM_Procesos

**Categoría:** Form

## Caso de Uso 1: Crear un nuevo proceso

**Descripción:** El usuario desea registrar un nuevo proceso en el sistema.

**Precondiciones:**
El usuario tiene acceso a la página de procesos y permisos para crear.

**Pasos a seguir:**
1. El usuario hace clic en 'Nuevo Proceso'.
2. Ingresa el nombre y la descripción del proceso.
3. Hace clic en 'Guardar'.

**Resultado esperado:**
El proceso es creado y aparece en la lista de procesos.

**Datos de prueba:**
{ "nombre": "Proceso de Prueba", "descripcion": "Este es un proceso de prueba." }

---

## Caso de Uso 2: Editar un proceso existente

**Descripción:** El usuario necesita modificar los datos de un proceso ya registrado.

**Precondiciones:**
Existe al menos un proceso registrado.

**Pasos a seguir:**
1. El usuario localiza el proceso en la lista.
2. Hace clic en 'Editar'.
3. Modifica el nombre o la descripción.
4. Hace clic en 'Actualizar'.

**Resultado esperado:**
Los cambios se guardan y se reflejan en la lista.

**Datos de prueba:**
{ "id": 1, "nombre": "Proceso Modificado", "descripcion": "Descripción actualizada." }

---

## Caso de Uso 3: Eliminar un proceso

**Descripción:** El usuario desea eliminar un proceso que ya no es necesario.

**Precondiciones:**
Existe al menos un proceso registrado.

**Pasos a seguir:**
1. El usuario localiza el proceso en la lista.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El proceso es eliminado y desaparece de la lista.

**Datos de prueba:**
{ "id": 1 }

---

