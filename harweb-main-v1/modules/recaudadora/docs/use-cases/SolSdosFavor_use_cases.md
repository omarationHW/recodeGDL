# Casos de Uso - SolSdosFavor

**Categoría:** Form

## Caso de Uso 1: Alta de Solicitud de Saldo a Favor

**Descripción:** Un usuario autorizado registra una nueva solicitud de saldo a favor para una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos. La cuenta catastral existe.

**Pasos a seguir:**
1. El usuario accede a la página de Solicitud de Saldos a Favor.
2. Llena los campos requeridos (domicilio, colonia, solicitante, etc.).
3. Selecciona los documentos entregados (checkboxes).
4. Selecciona la inconformidad y el peticionario.
5. Da clic en 'Guardar'.
6. El sistema valida y envía la petición a /api/execute con action=createSolicitud.
7. El backend crea el registro y devuelve el folio generado.

**Resultado esperado:**
La solicitud queda registrada, aparece en la lista con status 'PENDIENTE' y folio asignado.

**Datos de prueba:**
{
  "domp": "Av. Juárez 123",
  "extp": "123",
  "intp": "A",
  "colp": "Centro",
  "telefono": "3331234567",
  "codp": "44100",
  "solicitante": "Juan Pérez",
  "doctos": [1, 2, 6],
  "status": "P",
  "inconf": 1,
  "peticionario": 1
}

---

## Caso de Uso 2: Edición de Solicitud Existente

**Descripción:** Un usuario edita una solicitud de saldo a favor pendiente para corregir datos.

**Precondiciones:**
Existe una solicitud con status 'PENDIENTE'. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona una solicitud de la lista.
2. Da clic en 'Editar'.
3. Modifica los campos necesarios (ej. teléfono, observaciones).
4. Da clic en 'Actualizar'.
5. El sistema valida y envía la petición a /api/execute con action=updateSolicitud.

**Resultado esperado:**
La solicitud se actualiza y los cambios se reflejan en la lista.

**Datos de prueba:**
{
  "id_solic": 123,
  "telefono": "3337654321",
  "observaciones": "Se corrige teléfono."
}

---

## Caso de Uso 3: Cancelación de Solicitud

**Descripción:** Un usuario cancela una solicitud de saldo a favor pendiente.

**Precondiciones:**
Existe una solicitud con status 'PENDIENTE'. El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario selecciona una solicitud pendiente.
2. Da clic en 'Cancelar'.
3. El sistema solicita confirmación.
4. El usuario confirma.
5. El sistema envía la petición a /api/execute con action=cancelSolicitud.

**Resultado esperado:**
La solicitud cambia a status 'CANCELADO' y no puede ser editada.

**Datos de prueba:**
{
  "id_solic": 123
}

---

