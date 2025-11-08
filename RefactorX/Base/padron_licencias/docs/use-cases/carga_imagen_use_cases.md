# Casos de Uso - carga_imagen

**Categoría:** Form

## Caso de Uso 1: Subir un documento escaneado a un trámite

**Descripción:** El usuario necesita asociar un documento escaneado (por ejemplo, comprobante de domicilio) al trámite 1234.

**Precondiciones:**
El usuario está autenticado y tiene permisos para modificar el trámite.

**Pasos a seguir:**
1. El usuario accede a la página de documentos del trámite 1234.
2. Hace clic en 'Agregar documento'.
3. Selecciona 'Comprobante de domicilio' como tipo de documento.
4. Selecciona el archivo 'comprobante.jpg' desde su computadora.
5. Hace clic en 'Subir'.
6. El sistema valida y guarda el documento.

**Resultado esperado:**
El documento aparece en la lista de documentos asociados al trámite. Puede ser visualizado y eliminado.

**Datos de prueba:**
tramite_id: 1234, document_type_id: 2, file: comprobante.jpg

---

## Caso de Uso 2: Visualizar un documento previamente cargado

**Descripción:** El usuario desea ver el documento 'INE.jpg' asociado al trámite 1234.

**Precondiciones:**
El documento ya fue cargado y está asociado al trámite.

**Pasos a seguir:**
1. El usuario accede a la página de documentos del trámite 1234.
2. En la lista, localiza el documento 'INE'.
3. Hace clic en 'Ver'.

**Resultado esperado:**
Se abre una ventana modal mostrando la imagen escaneada.

**Datos de prueba:**
tramite_id: 1234, id_imagen: 888

---

## Caso de Uso 3: Eliminar un documento asociado por error

**Descripción:** El usuario subió por error un documento equivocado y desea eliminarlo.

**Precondiciones:**
El usuario tiene permisos de eliminación y el documento no está bloqueado.

**Pasos a seguir:**
1. El usuario accede a la página de documentos del trámite 1234.
2. En la lista, localiza el documento equivocado.
3. Hace clic en 'Eliminar'.
4. Confirma la eliminación.

**Resultado esperado:**
El documento desaparece de la lista y ya no puede ser visualizado.

**Datos de prueba:**
tramite_id: 1234, id_imagen: 777

---

