# Casos de Uso - bloqueoDomiciliosfrm

**Categoría:** Form

## Caso de Uso 1: Agregar un domicilio bloqueado

**Descripción:** El usuario necesita bloquear un domicilio específico por motivo de irregularidad.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura.

**Pasos a seguir:**
1. El usuario accede a la página de Bloqueo de Domicilios.
2. Da clic en 'Agregar'.
3. Llena los campos: Calle, No. Ext., Letra ext., No. Int., Letra int., Observaciones, Capturista.
4. Da clic en 'Aceptar'.
5. El sistema valida y envía la petición a /api/execute con acción 'add'.

**Resultado esperado:**
El domicilio aparece en la lista de bloqueados con los datos capturados.

**Datos de prueba:**
{ "calle": "AV. JUAREZ", "cvecalle": 123, "num_ext": 456, "let_ext": "A", "num_int": 2, "let_int": "B", "observacion": "Irregularidad detectada", "capturista": "usuario1" }

---

## Caso de Uso 2: Eliminar un domicilio bloqueado

**Descripción:** El usuario requiere desbloquear un domicilio y registrar el motivo.

**Precondiciones:**
El domicilio existe en la lista y el usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona el domicilio en la tabla.
2. Da clic en 'Eliminar'.
3. Ingresa el motivo de eliminación.
4. Da clic en 'Eliminar' en el modal de confirmación.
5. El sistema envía la petición a /api/execute con acción 'delete'.

**Resultado esperado:**
El domicilio desaparece de la lista y se registra en el histórico con el motivo.

**Datos de prueba:**
{ "folio": 1001, "motivo": "Regularización", "usuario": "usuario1" }

---

## Caso de Uso 3: Buscar domicilios bloqueados por calle

**Descripción:** El usuario desea filtrar la lista de domicilios bloqueados por nombre de calle.

**Precondiciones:**
Existen domicilios bloqueados en la base de datos.

**Pasos a seguir:**
1. El usuario escribe parte del nombre de la calle en el campo de búsqueda.
2. El sistema envía la petición a /api/execute con acción 'search' y parámetro 'calle'.
3. La tabla se actualiza mostrando solo los domicilios coincidentes.

**Resultado esperado:**
Solo se muestran los domicilios bloqueados cuya calle contiene el texto buscado.

**Datos de prueba:**
{ "calle": "AV. JUAREZ" }

---

