# Casos de Uso - ServiciosMntto

**Categoría:** Form

## Caso de Uso 1: Alta de un nuevo Servicio de Obra Pública

**Descripción:** El usuario desea registrar un nuevo servicio en el catálogo.

**Precondiciones:**
El usuario tiene permisos de administrador y está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Servicios de Obra Pública.
2. Hace clic en 'Agregar Servicio'.
3. Completa el formulario: Servicio=101, Descripción='ALUMBRADO PÚBLICO', Obra 1994=12.
4. Hace clic en 'Guardar'.
5. El sistema valida y envía la petición a /api/execute con action=servicios_create.

**Resultado esperado:**
El nuevo servicio aparece en la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "servicio": 101, "descripcion": "ALUMBRADO PÚBLICO", "serv_obra94": 12 }

---

## Caso de Uso 2: Edición de un Servicio existente

**Descripción:** El usuario edita la descripción de un servicio existente.

**Precondiciones:**
Existe el servicio 101 en la base de datos.

**Pasos a seguir:**
1. El usuario localiza el servicio 101 en la tabla.
2. Hace clic en 'Editar'.
3. Cambia la descripción a 'ALUMBRADO Y ELECTRIFICACIÓN'.
4. Hace clic en 'Guardar'.
5. El sistema envía la petición a /api/execute con action=servicios_update.

**Resultado esperado:**
La descripción del servicio se actualiza y se muestra en la tabla.

**Datos de prueba:**
{ "servicio": 101, "descripcion": "ALUMBRADO Y ELECTRIFICACIÓN", "serv_obra94": 12 }

---

## Caso de Uso 3: Eliminación de un Servicio

**Descripción:** El usuario elimina un servicio del catálogo.

**Precondiciones:**
Existe el servicio 101 en la base de datos.

**Pasos a seguir:**
1. El usuario localiza el servicio 101 en la tabla.
2. Hace clic en 'Eliminar'.
3. Confirma la eliminación.
4. El sistema envía la petición a /api/execute con action=servicios_delete.

**Resultado esperado:**
El servicio desaparece de la tabla y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "servicio": 101 }

---

