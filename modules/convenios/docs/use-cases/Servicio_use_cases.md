# Casos de Uso - Servicio

**Categoría:** Form

## Caso de Uso 1: Alta de nuevo servicio de obra pública

**Descripción:** Un usuario desea registrar un nuevo servicio de obra pública en el catálogo.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para agregar servicios.

**Pasos a seguir:**
1. El usuario accede a la página de Servicios.
2. Hace clic en 'Agregar Servicio'.
3. Llena el formulario con la descripción 'Construcción de puente' y deja 'Obra 1994' vacío.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El servicio es creado y aparece en la lista. Se muestra mensaje 'Guardado correctamente'.

**Datos de prueba:**
{ "descripcion": "Construcción de puente", "serv_obra94": null }

---

## Caso de Uso 2: Edición de un servicio existente

**Descripción:** Un usuario edita la descripción de un servicio existente.

**Precondiciones:**
Existe un servicio con servicio=5, descripción='Alumbrado público'.

**Pasos a seguir:**
1. El usuario accede a la página de Servicios.
2. Ubica el servicio #5 y hace clic en 'Editar'.
3. Cambia la descripción a 'Alumbrado público LED'.
4. Hace clic en 'Guardar'.

**Resultado esperado:**
El servicio #5 se actualiza con la nueva descripción.

**Datos de prueba:**
{ "servicio": 5, "descripcion": "Alumbrado público LED", "serv_obra94": null }

---

## Caso de Uso 3: Eliminación de un servicio

**Descripción:** Un usuario elimina un servicio del catálogo.

**Precondiciones:**
Existe un servicio con servicio=10.

**Pasos a seguir:**
1. El usuario accede a la página de Servicios.
2. Ubica el servicio #10 y hace clic en 'Eliminar'.
3. Confirma la eliminación.

**Resultado esperado:**
El servicio #10 es eliminado y ya no aparece en la lista.

**Datos de prueba:**
{ "servicio": 10 }

---

