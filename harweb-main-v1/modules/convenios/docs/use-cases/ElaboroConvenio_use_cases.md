# Casos de Uso - ElaboroConvenio

**Categoría:** Form

## Caso de Uso 1: Alta de nuevo registro de quien elaboró convenio

**Descripción:** Un usuario administrativo desea registrar quién elaboró un nuevo convenio, indicando recaudadora, titular y quien elaboró.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de escritura.

**Pasos a seguir:**
1. El usuario accede a la página 'Quien elaboró convenio'.
2. Hace clic en 'Agregar'.
3. Llena los campos: Recaudadora, ID Usuario Titular, Iniciales Titular, ID Usuario Elaboró, Iniciales Elaboró.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la petición a /api/execute con action 'create'.
6. El backend ejecuta el SP y retorna el nuevo registro.

**Resultado esperado:**
El registro aparece en la tabla y el usuario ve un mensaje de éxito.

**Datos de prueba:**
{ "id_rec": 2, "id_usu_titular": 101, "iniciales_titular": "JPG", "id_usu_elaboro": 202, "iniciales_elaboro": "MGA" }

---

## Caso de Uso 2: Modificación de registro existente

**Descripción:** Un usuario necesita corregir las iniciales del titular en un registro existente.

**Precondiciones:**
Debe existir al menos un registro y el usuario debe tener permisos de edición.

**Pasos a seguir:**
1. El usuario selecciona un registro de la tabla.
2. Hace clic en 'Modificar'.
3. Cambia el campo 'Iniciales Titular'.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action 'update'.

**Resultado esperado:**
El registro se actualiza y se muestra el cambio en la tabla.

**Datos de prueba:**
{ "id_control": 5, "id_rec": 2, "id_usu_titular": 101, "iniciales_titular": "JPGX", "id_usu_elaboro": 202, "iniciales_elaboro": "MGA" }

---

## Caso de Uso 3: Eliminación de registro

**Descripción:** Un usuario desea eliminar un registro de quien elaboró convenio.

**Precondiciones:**
Debe existir el registro y el usuario debe tener permisos de eliminación.

**Pasos a seguir:**
1. El usuario selecciona un registro de la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.
4. El sistema envía la petición a /api/execute con action 'delete'.

**Resultado esperado:**
El registro desaparece de la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "id_control": 5 }

---

