# Casos de Uso - frmImpLicenciaReglamentada

**Categoría:** Form

## Caso de Uso 1: Alta de una nueva Licencia Reglamentada

**Descripción:** Un usuario desea registrar una nueva licencia reglamentada en el sistema.

**Precondiciones:**
El usuario tiene acceso a la página de Licencias Reglamentadas y conoce los datos requeridos.

**Pasos a seguir:**
1. El usuario hace clic en 'Nueva Licencia'.
2. Completa los campos 'Nombre', 'Descripción' y 'Usuario ID'.
3. Hace clic en 'Guardar'.
4. El sistema envía la solicitud a /api/execute con eRequest 'createLicenciaReglamentada'.
5. El backend crea la licencia y retorna la información creada.
6. El frontend muestra la nueva licencia en el listado.

**Resultado esperado:**
La licencia se crea correctamente y aparece en el listado.

**Datos de prueba:**
{ "nombre": "Licencia Prueba", "descripcion": "Licencia de prueba para test", "usuario_id": 1 }

---

## Caso de Uso 2: Edición de una Licencia Reglamentada existente

**Descripción:** Un usuario necesita modificar los datos de una licencia reglamentada ya registrada.

**Precondiciones:**
Existe al menos una licencia registrada.

**Pasos a seguir:**
1. El usuario localiza la licencia en el listado.
2. Hace clic en 'Editar'.
3. Modifica los campos requeridos.
4. Hace clic en 'Actualizar'.
5. El sistema envía la solicitud a /api/execute con eRequest 'updateLicenciaReglamentada'.
6. El backend actualiza la licencia y retorna la información actualizada.
7. El frontend actualiza el listado.

**Resultado esperado:**
La licencia se actualiza correctamente y los cambios se reflejan en el listado.

**Datos de prueba:**
{ "id": 1, "nombre": "Licencia Modificada", "descripcion": "Descripción actualizada", "usuario_id": 2 }

---

## Caso de Uso 3: Eliminación de una Licencia Reglamentada

**Descripción:** Un usuario desea eliminar una licencia reglamentada del sistema.

**Precondiciones:**
Existe al menos una licencia registrada.

**Pasos a seguir:**
1. El usuario localiza la licencia en el listado.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.
4. El sistema envía la solicitud a /api/execute con eRequest 'deleteLicenciaReglamentada'.
5. El backend elimina la licencia y retorna confirmación.
6. El frontend elimina la licencia del listado.

**Resultado esperado:**
La licencia es eliminada correctamente y desaparece del listado.

**Datos de prueba:**
{ "id": 1 }

---

