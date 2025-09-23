# Casos de Uso - loctp

**Categoría:** Form

## Caso de Uso 1: Búsqueda de Escritura Existente

**Descripción:** El usuario busca una escritura existente ingresando notaría, municipio y número de escrituras.

**Precondiciones:**
El usuario tiene acceso al sistema y existen escrituras registradas con los datos proporcionados.

**Pasos a seguir:**
- El usuario accede a la página de localización de escrituras.
- Ingresa el número de notaría, selecciona el municipio y escribe el número de escrituras.
- Presiona 'Buscar Datos'.
- El sistema muestra los actos asociados y el detalle de la cuenta.

**Resultado esperado:**
Se muestran los actos encontrados y el detalle de la cuenta correspondiente.

**Datos de prueba:**
{ "notaria": 12, "municipio": 5, "escrituras": 12345 }

---

## Caso de Uso 2: Edición de Observación de un Acto

**Descripción:** El usuario edita la observación de un acto encontrado en la búsqueda.

**Precondiciones:**
El usuario ha realizado una búsqueda y existen actos listados.

**Pasos a seguir:**
- El usuario edita el campo de observaciones en la tabla de resultados.
- Al salir del campo (blur), el sistema guarda la observación en la base de datos.

**Resultado esperado:**
La observación se actualiza correctamente en la base de datos.

**Datos de prueba:**
{ "folio": 1001, "observacion": "Nueva observación de prueba" }

---

## Caso de Uso 3: Búsqueda sin Resultados

**Descripción:** El usuario realiza una búsqueda con datos que no existen.

**Precondiciones:**
No existen escrituras con los datos proporcionados.

**Pasos a seguir:**
- El usuario ingresa datos inexistentes y presiona 'Buscar Datos'.

**Resultado esperado:**
El sistema muestra el mensaje 'No se localizó la escritura.'

**Datos de prueba:**
{ "notaria": 99, "municipio": 99, "escrituras": 99999 }

---

