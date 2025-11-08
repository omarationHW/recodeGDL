# Casos de Uso - doctosfrm

**Categoría:** Form

## Caso de Uso 1: Guardar selección de documentos para un trámite

**Descripción:** El usuario selecciona varios documentos requeridos y especifica un documento adicional en el campo 'Otro', luego guarda la selección.

**Precondiciones:**
El trámite ya existe y el usuario tiene permisos para editarlo.

**Pasos a seguir:**
- El usuario accede a la página de documentos del trámite.
- Marca las casillas de 'Fotografías de la fachada' y 'Recibo de predial'.
- Marca la casilla 'Otro' y escribe 'Carta de recomendación'.
- Da clic en 'Aceptar'.

**Resultado esperado:**
La selección se guarda en la base de datos y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "tramite_id": 123, "documentos": ["fotofachada", "recibopredial"], "otro": "Carta de recomendación" }

---

## Caso de Uso 2: Limpiar selección de documentos

**Descripción:** El usuario decide limpiar la selección de documentos para un trámite.

**Precondiciones:**
El trámite tiene documentos seleccionados previamente.

**Pasos a seguir:**
- El usuario accede a la página de documentos del trámite.
- Da clic en el botón 'Limpiar'.

**Resultado esperado:**
La selección de documentos se elimina y el formulario queda vacío.

**Datos de prueba:**
{ "tramite_id": 123 }

---

## Caso de Uso 3: Eliminar un documento específico de la selección

**Descripción:** El usuario elimina un documento específico de la selección de documentos de un trámite.

**Precondiciones:**
El trámite tiene varios documentos seleccionados.

**Pasos a seguir:**
- El usuario accede a la página de documentos del trámite.
- Deselecciona la casilla de 'Recibo de predial'.
- Da clic en 'Aceptar'.

**Resultado esperado:**
El documento 'Recibo de predial' se elimina de la selección en la base de datos.

**Datos de prueba:**
{ "tramite_id": 123, "documento": "recibopredial" }

---

