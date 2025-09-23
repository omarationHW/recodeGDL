# Casos de Uso - frmobserva

**Categoría:** Form

## Caso de Uso 1: Consulta de Observación de Comprobante

**Descripción:** El usuario desea consultar la observación del comprobante actual de una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y conoce el número de cuenta catastral.

**Pasos a seguir:**
- Accede a la página de Observaciones de Comprobante.
- Ingresa el número de cuenta o accede desde el listado.
- El sistema muestra los datos del comprobante y la observación actual.

**Resultado esperado:**
Se visualizan correctamente los datos del comprobante y la observación.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

## Caso de Uso 2: Actualización de Observación de Comprobante

**Descripción:** El usuario edita la observación del comprobante y la guarda.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
- Accede a la página de Observaciones de Comprobante.
- Edita el campo de observación.
- Presiona el botón 'Actualizar'.
- El sistema actualiza la observación en la base de datos y en el histórico.

**Resultado esperado:**
La observación se actualiza correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 12345, "observacion": "NUEVA OBSERVACION DE PRUEBA" }

---

## Caso de Uso 3: Consulta de Histórico de Comprobante

**Descripción:** El usuario consulta el histórico de un comprobante específico.

**Precondiciones:**
El usuario está autenticado y conoce los identificadores del comprobante.

**Pasos a seguir:**
- Accede a la funcionalidad de histórico.
- Ingresa cvecuenta, axocomp, nocomp y feccap.
- El sistema muestra el registro histórico correspondiente.

**Resultado esperado:**
Se visualiza el registro histórico con la observación correspondiente.

**Datos de prueba:**
{ "cvecuenta": 12345, "axocomp": 2024, "nocomp": 1001, "feccap": "2024-06-01" }

---

